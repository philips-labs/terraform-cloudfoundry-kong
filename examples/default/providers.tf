provider "cloudfoundry" {
  api_url             = var.cf_api_url == "" ? data.hsdp_config.cf.url : var.cf_api_url
  user                = var.cf_username
  password            = var.cf_password
  skip_ssl_validation = false
}

provider "hsdp" {
  region = var.cf_region
}
