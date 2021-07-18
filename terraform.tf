terraform {
  required_version = ">= 0.13.4"

  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry-community/cloudfoundry"
      version = ">= 0.14.1"
    }
    hsdp = {
      source = "philips-software/hsdp"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = ">= 0.5.0"
    }
  }
}
