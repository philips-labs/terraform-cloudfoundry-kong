module "kong" {
  source = "../../"

  cf_space_name = "my-space"
  cf_org_name   = "abc-eu"
  name_postfix  = "default"
}
