output "kong_endpoints" {
  description = "The endpoint where Kong is reachable on"
  value       = [for k, v in cloudfoundry_route.kong : v.endpoint]
}

output "kong_api_endpoint" {
  description = "The API endpoint where Kong admin API reachable on"
  value       = join("", cloudfoundry_route.kong_api_route.*.endpoint)
}

output "kong_api_username" {
  description = "The API username"
  value       = random_pet.deploy.id
}

output "kong_api_password" {
  description = "The API password"
  value       = join("", random_password.password.*.result)
}

output "kong_app_id" {
  description = "The Kong app id"
  value       = cloudfoundry_app.kong.id_bg
}
