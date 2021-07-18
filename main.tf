locals {
  postfix = var.name_postfix != "" ? var.name_postfix : random_id.id.hex
  domain = var.cf_domain_name == "" ? data.hsdp_config.cf[0].domain : var.cf_domain_name
}

resource "random_id" "id" {
  byte_length = 4
}

data "hsdp_config" "cf" {
  count = var.cf_domain_name == "" ? 1 : 0
  service = "cf"
}

data "cloudfoundry_org" "org" {
  name = var.cf_org_name
}

data "cloudfoundry_space" "space" {
  org  = data.cloudfoundry_org.org.id
  name = var.cf_space_name
}

data "cloudfoundry_domain" "domain" {
  name = local.domain
}

data "cloudfoundry_domain" "internal_domain" {
  name = "apps.internal"
}

resource "cloudfoundry_app" "kong" {
  name         = "tf-kong-${local.postfix}"
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.kong_image
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }
  lifecycle {
    ignore_changes = [instances]
  }
  health_check_type = "process"
  command           = "/docker-entrypoint.sh /usr/local/bin/kong migrations bootstrap && /docker-entrypoint.sh /usr/local/bin/kong migrations up && /docker-entrypoint.sh kong docker-start"
  environment = merge(var.environment,
    {
      "KONG_DATABASE"          = "postgres"
      "KONG_PG_USER"           = module.postgres[0].credentials.username
      "KONG_PG_PASSWORD"       = module.postgres[0].credentials.password
      "KONG_PG_HOST"           = module.postgres[0].credentials.hostname
      "KONG_PG_DATABASE"       = module.postgres[0].credentials.db_name
      "KONG_PLUGINS"           = join(",", var.kong_plugins)
      "KONG_TRUSTED_IPS"       = "0.0.0.0/0"
      "KONG_REAL_IP_HEADER"    = "X-Forwarded-For"
      "KONG_REAL_IP_RECURSIVE" = "on"
      "KONG_PROXY_LISTEN"      = "0.0.0.0:8080 reuseport backlog=16384,0.0.0.0:8000 reuseport backlog=16384,0.0.0.0:8443 http2 ssl reuseport backlog=16384,0.0.0.0:8444 http2 ssl reuseport backlog=16384"
      "KONG_ADMIN_LISTEN"      = "0.0.0.0:8001"
    }
  )
  routes {
    route = cloudfoundry_route.kong.id
  }
  routes {
    route = cloudfoundry_route.kong_internal.id
  }

  labels = {
    "variant.tva/exporter" = true,
  }
  annotations = {
    "prometheus.exporter.instance_name" = "${data.cloudfoundry_org.org.name}.${data.cloudfoundry_space.space.name}.kong-${local.postfix}-$${1}"
    "prometheus.exporter.port"          = "8001"
    "prometheus.exporter.path"          = "/metrics"
  }
}

resource "cloudfoundry_app" "konga" {
  count        = var.enable_konga ? 1 : 0
  name         = "tf-konga-${local.postfix}"
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.konga_image
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }
  environment = merge(var.konga_environment,
    {
      "NO_AUTH"  = "true"
      "NODE_ENV" = "production"
    }
  )

  routes {
    route = cloudfoundry_route.konga_internal[0].id
  }
}

module "postgres" {
  count       = var.enable_postgres ? 1 : 0
  source      = "philips-labs/postgres-service/hsdp"
  version     = "0.0.3"
  cf_space_id = data.cloudfoundry_space.space.id
  plan        = var.db_plan
}

resource "cloudfoundry_route" "kong" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = "tf-kong-${local.postfix}"
}

resource "cloudfoundry_route" "kong_internal" {
  domain   = data.cloudfoundry_domain.internal_domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = "tf-kong-${local.postfix}"
}

resource "cloudfoundry_route" "konga_internal" {
  count    = var.enable_konga ? 1 : 0
  domain   = data.cloudfoundry_domain.internal_domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = "tf-konga-${local.postfix}"
}

resource "cloudfoundry_network_policy" "konga_internal" {
  count = var.enable_konga ? 1 : 0

  policy {
    source_app      = cloudfoundry_app.konga[0].id
    destination_app = cloudfoundry_app.kong.id
    protocol        = "tcp"
    port            = "8001"
  }
}

resource "cloudfoundry_network_policy" "kong" {
  count = length(var.network_policies) > 0 ? 1 : 0

  dynamic "policy" {
    for_each = [for p in var.network_policies : {
      destination_app = p.destination_app
      port            = p.port
      protocol        = p.protocol
    }]
    content {
      source_app      = cloudfoundry_app.kong.id
      destination_app = policy.value.destination_app
      protocol        = policy.value.protocol == "" ? "tcp" : policy.value.protocol
      port            = policy.value.port
    }
  }
}
