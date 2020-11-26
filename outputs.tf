output "kong_endpoint" {
  description = "The endpoint where Kong is reachable on"
  value       = cloudfoundry_route.kong.endpoint
}
