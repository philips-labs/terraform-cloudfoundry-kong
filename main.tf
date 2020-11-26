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

data "cloudfoundry_service" "rds" {
  name = var.db_broker
}

resource "cloudfoundry_app" "kong" {
  name         = "kong"
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.kong_image
  environment = merge(var.environment,
    {
      "KONG_DATABASE"     = "postgres"
      "KONG_PG_USER"      = cloudfoundry_service_key.database_key[0].credentials.username
      "KONG_PG_PASSWORD"  = cloudfoundry_service_key.database_key[0].credentials.password
      "KONG_PG_HOST"      = cloudfoundry_service_key.database_key[0].credentials.hostname
      "KONG_PG_DATABASE"  = cloudfoundry_service_key.database_key[0].credentials.db_name
      "KONG_PLUGINS"      = "bundled"
      "KONG_PROXY_LISTEN" = "0.0.0.0:8080 reuseport backlog=16384"
    }
  )
  routes {
    route = cloudfoundry_route.kong.id
  }
}

resource "cloudfoundry_app" "konga" {
  count        = var.enable_konga ? 1 : 0
  name         = "konga"
  space        = data.cloudfoundry_space.space.id
  memory       = var.memory
  disk_quota   = var.disk
  docker_image = var.kong_image
  environment = merge(var.environment,
    {
      "DB_ADAPTER"   = "postgres"
      "DB_USER"      = cloudfoundry_service_key.database_key[0].credentials.username
      "DB_PASSWORD"  = cloudfoundry_service_key.database_key[0].credentials.password
      "DB_HOST"      = cloudfoundry_service_key.database_key[0].credentials.hostname
      "DB_DATABASE"  = cloudfoundry_service_key.database_key[0].credentials.db_name
      "DB_PG_SCHEMA" = "konga"
      "NODE_ENV"     = "development"
    }
  )

  routes {
    route = cloudfoundry_route.kong.id
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
  hostname = var.name_postfix == "" ? "kong" : "kong-${var.name_postfix}"
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
