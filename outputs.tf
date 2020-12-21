output "kong_endpoint" {
  description = "The endpoint where Kong is reachable on"
  value       = cloudfoundry_route.kong.endpoint
}

output "kong_api_endpoint" {
  description = "The API endpoint where Kong admin API reachable on"
  value       = cloudfoundry_route.kong_api_route[0] ? cloudfoundry_route.kong_api_route[0].endpoint : ""
}

output "kong_api_username" {
  description = "The API username"
  value       = random_id.id.hex
}

output "kong_api_password" {
  description = "The API password"
  value       = random_password.password.result
}
