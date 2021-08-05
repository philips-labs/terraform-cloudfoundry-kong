module "kong" {
  source = "../../"

  cf_space_name = var.cf_space_name
  cf_org_name   = var.cf_org_name
  name_postfix  = var.name_postfix
}
