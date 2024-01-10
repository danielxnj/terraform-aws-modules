variable "create" {
  description = "Whether to create this resource or not"
  type        = bool
  default     = true
}

variable "registry_policy" {
  description = "The policy document. This is a JSON formatted string"
  type        = string
  default     = null
}
