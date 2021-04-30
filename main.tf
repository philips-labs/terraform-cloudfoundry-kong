resource "random_id" "id" {
  byte_length = 8
}

data "cloudfoundry_org" "org" {
  name = var.cf_org
}

data "cloudfoundry_space" "space" {
  org  = data.cloudfoundry_org.org.id
  name = var.cf_space
}

data "cloudfoundry_domain" "domain" {
  name = var.cf_domain
}

data "cloudfoundry_domain" "internal_domain" {
  name = "apps.internal"
}

data "cloudfoundry_service" "rds" {
  name = var.db_broker
}

resource "cloudfoundry_app" "kong" {
  name         = "kong"
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.kong_image
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }
  health_check_type = "process"
  command           = "/docker-entrypoint.sh /usr/local/bin/kong migrations bootstrap && /docker-entrypoint.sh /usr/local/bin/kong migrations up && /docker-entrypoint.sh kong docker-start"
  environment = merge(var.environment,
    {
      "KONG_DATABASE"          = "postgres"
      "KONG_PG_USER"           = cloudfoundry_service_key.database_key[0].credentials.username
      "KONG_PG_PASSWORD"       = cloudfoundry_service_key.database_key[0].credentials.password
      "KONG_PG_HOST"           = cloudfoundry_service_key.database_key[0].credentials.hostname
      "KONG_PG_DATABASE"       = cloudfoundry_service_key.database_key[0].credentials.db_name
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
}

resource "cloudfoundry_app" "konga" {
  count        = var.enable_konga ? 1 : 0
  name         = "konga"
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


resource "cloudfoundry_service_instance" "database" {
  count        = var.enable_postgres ? 1 : 0
  name         = "kong-rds"
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.rds.service_plans[var.db_plan]
  json_params  = var.db_json_params
}


resource "cloudfoundry_service_key" "database_key" {
  count            = var.enable_postgres ? 1 : 0
  name             = "key"
  service_instance = cloudfoundry_service_instance.database[0].id
}

resource "cloudfoundry_route" "kong" {
  domain   = data.cloudfoundry_domain.domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.name_postfix == "" ? "kong-${random_id.id.hex}" : "kong-${var.name_postfix}"
}

resource "cloudfoundry_route" "kong_internal" {
  domain   = data.cloudfoundry_domain.internal_domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.name_postfix == "" ? "kong-${random_id.id.hex}" : "kong-${var.name_postfix}"
}

resource "cloudfoundry_route" "konga_internal" {
  count    = var.enable_konga ? 1 : 0
  domain   = data.cloudfoundry_domain.internal_domain.id
  space    = data.cloudfoundry_space.space.id
  hostname = var.name_postfix == "" ? "konga-${random_id.id.hex}" : "konga-${var.name_postfix}"
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
