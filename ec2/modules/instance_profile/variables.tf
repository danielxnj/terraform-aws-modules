variable "create" {
  type        = bool
  description = "Whether to create this resource or not"
  default     = true
}

variable "name" {
  type        = string
  description = "The name of the instance profile"
}

variable "path" {
  type        = string
  description = "The path to the instance profile"
  default     = "/"
}

variable "role" {
  type        = string
  description = "The role name to attach to the instance profile"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

