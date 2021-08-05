variable "cf_api_url" {
  description = "Cloudfoundry API url. When empty will use the auto-discovery based on cf_region"
  type        = string
  default     = ""
}

variable "cf_username" {
  description = "Cloudfoundry username"
  type        = string
}

variable "cf_password" {
  description = "Cloudfoundry password"
  type        = string
}

variable "cf_org_name" {
  description = "The Cloudfoundry ORG to deploy in"
  type        = string
}

variable "cf_space_name" {
  description = "The Cloudfoundry SPACE to deploy in"
  type        = string
}

variable "name_postfix" {
  description = "The postfix string to append to names"
  type        = string
  default     = "default"
}

variable "cf_region" {
  description = "The HSDP region to deploy into"
  type        = string
  default     = "eu-west"
}
