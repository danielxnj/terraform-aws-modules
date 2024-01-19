variable "enabled" {
  description = "Whether or not to create the resource."
  type = bool
  default = true
}

variable "domain" {
  description = "The name of the domain."
  type = string
}

variable "encryption_key" {
  description = "The encryption key for the domain."
  type = string
  default = null
}

variable "encryption_key_alias" {
  description = "The encryption key alias for the domain."
  type = string
  default = null
}

variable "domain_policy_domain_owner" {
    description = "The account number of the domain owner."
    type = string
    default = null
}


variable "tags" {
  description = "A map of tags to assign to the resource."
  type = map(string)
  default = {}
}

variable "domain_policy_document" {
    description = "The policy document."
    type = string
    default = null
}

variable "repositories" {
  description = "A list of repositories to create in the domain."
  type = object({
    description = optional(string)
    external_connections = optional(list(object({
      external_connection_name = optional(string)
      package_format = optional(string)
      status = optional(string)
    })))
    upstreams = optional(list(object({
      repository_name = string
    })))
    tags = optional(map(string))
    policy_document = optional(string)
  })
  default = null
}