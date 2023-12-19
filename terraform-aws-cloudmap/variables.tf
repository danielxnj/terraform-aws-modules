variable "namespace_name" {
  description = "The name of the namespace"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC where the namespace is associated"
  type        = string
}

variable "service_names" {
  description = "The names of the services to create"
  type        = map(any)
  default     = {}
}

variable "create_private_dns_namespace" {
  description = "Whether to create a private DNS namespace"
  type        = bool
  default     = true
}

variable "tags" {
  description = "The tags to associate with the namespace"
  type        = map(string)
  default     = {}
}
