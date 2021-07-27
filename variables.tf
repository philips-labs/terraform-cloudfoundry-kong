variable "kong_image" {
  type        = string
  description = "Kong Docker image to use"
  default     = "kong/kong:2.5.0"
}

variable "konga_image" {
  type        = string
  description = "Konga dashboard image to use"
  default     = "pantsel/konga"
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

variable "konga_environment" {
  type        = map(any)
  description = "Environment variables for Kong app"
  default     = {}
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
  default     = true
}

variable "enable_konga" {
  type        = bool
  description = "Enable or disables Konga dashboard"
  default     = true
}

variable "enable_protected_admin_api" {
  type        = bool
  description = "Enables the ADMIN API for use by e.g. Kong provider"
  default     = true
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
