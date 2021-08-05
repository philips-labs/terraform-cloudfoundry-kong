output "kong_endpoint" {
  value = "https://${module.kong.kong_endpoint}"
}
