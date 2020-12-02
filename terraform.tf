terraform {
  required_version = ">= 0.13.4"

  required_providers {
    cloudfoundry = {
      source  = "philips-labs/cloudfoundry"
      version = ">= 0.1206.0"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">= 0.5.0"
    }
  }
}
