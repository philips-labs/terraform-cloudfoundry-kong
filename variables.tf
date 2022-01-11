variable "kong_image" {
  type        = string
  description = "Kong Docker image to use"
  default     = "kong/kong:2.6.0"
}

variable "kong_plugins" {
  type        = list(string)
  description = "List of plugins to load"
  default     = ["bundled"]
}

variable "cf_org_name" {
  type        = string
  description = "The CF Org to deploy under"
}
variable "cf_space_name" {
  type        = string
  description = "The CF Space to deploy in"
}
variable "cf_domain_name" {
  type        = string
  description = "The CF domain to use for Kong"
  default     = ""
}

variable "hostnames" {
  type        = list(string)
  description = "The list of hostnames to use for the gateway"
  default     = []
}

variable "name_postfix" {
  type        = string
  description = "The postfix string to append to the hostname, prevents namespace clashes"
  default     = ""
}

variable "environment" {
  type        = map(any)
  description = "Environment variables for Kong app"
  default     = {}
}

variable "kong_declarative_config_string" {
  type        = string
  description = "Declarative configuration json for Kong. To be provided while running in db less declarative mode"
  default     = "{\"_format_version\":\"1.1\", \"services\":[{\"host\":\"go-hello-world.eu-west.philips-healthsuite.com\",\"port\":443,\"protocol\":\"https\", \"routes\":[{\"paths\":[\"/\"]}]}],\"plugins\":[{\"name\":\"prometheus\"}]}"
}

variable "kong_nginx_worker_processes" {
  type        = number
  description = "Number of worker processes to use. When increase this, also increase memory allocation"
  default     = 4
}

variable "network_policies" {
  description = "The container-to-container network policies to create with Kong as the source app"
  type = list(object({
    destination_app = string
    protocol        = string
    port            = string
  }))
  default = []
}

variable "memory" {
  type        = number
  description = "The amount of RAM to allocate for Kong (MB)"
  default     = 1024
}

variable "disk" {
  type        = number
  description = "The amount of Disk space to allocate for Kong (MB)"
  default     = 1024
}

variable "db_plan" {
  type        = string
  description = "The Database plan to use"
  default     = "postgres-micro-dev"
}

variable "db_json_params" {
  type        = string
  description = "Optional DB JSON params"
  default     = "{}"
}

variable "enable_postgres" {
  type        = bool
  description = "Enable or disables postgres persistence"
  default     = false
}

variable "enable_protected_admin_api" {
  type        = bool
  description = "Enables the ADMIN API for use by e.g. Kong provider"
  default     = false
}

variable "strategy" {
  type        = string
  description = "Deployment strategy, 'none' or 'blue-green', default is 'none'"
  default     = "none"
}

variable "docker_username" {
  type        = string
  description = "Docker registry username"
  default     = ""
}

variable "docker_password" {
  type        = string
  description = "Docker registry password"
  default     = ""
}
