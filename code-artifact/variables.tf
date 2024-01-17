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
