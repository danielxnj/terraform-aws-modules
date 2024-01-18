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

variable "repository" {
  description = "The name of the repository."
  type = string
}

variable "repository_policy_document" {
    description = "The policy document."
    type = string
    default = null
}

variable "domain_policy_domain_owner" {
    description = "The account number of the domain owner."
    type = string
    default = null
}

variable "domain_policy_revision" {
    description = "The current revision of the policy."
    type = string
    default = null
}

variable "description" {
  description = "The description of the repository."
  type = string
  default = null
}

variable "repository_domain_owner" {
    description = "The account number of the repository owner."
    type = string
    default = null
}

variable "external_connections" {
    description = "A list of external connections for the repository."
    type = list(string)
    default = []
}

variable "upstreams" {
    description = "A list of upstream repositories to associate with the repository."
    type = list(string)
    default = []
}

variable "repository_tags" {
    description = "A map of tags to assign to the resource."
    type = map(string)
    default = {}
}

variable "repository_policy_domain_owner" {
    description = "The account number of the repository owner."
    type = string
    default = null
}

variable "repository_policy_revision" {
    description = "The current revision of the policy."
    type = string
    default = null
}
