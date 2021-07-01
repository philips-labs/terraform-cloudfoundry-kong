module "kong" {
  source = "../../"

  cf_domain    = "eu-west.philips-healthsuite.com"
  cf_space     = "my-space"
  cf_org       = "abc-eu"
  name_postfix = "default"
}
