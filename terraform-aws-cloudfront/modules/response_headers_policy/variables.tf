variable "enabled" {
  description = "Set to false to prevent the module from creating any resources."
  type        = bool
  default     = true
}

variable "name" {
  description = "The name of the cache policy."
  type        = string
}

variable "comment" {
  description = "The comment for the cache policy."
  type        = string
  default     = ""
}

variable "cors_config" {
  description = "The CORS policy for this cache policy."
  type        = list(any)
  default     = []
}

variable "custom_headers_config" {
  description = "The custom headers for this cache policy."
  type        = list(any)
  default     = []
}

variable "remove_headers_config" {
  description = "The headers to remove from this cache policy."
  type        = list(any)
  default     = []
}

variable "server_timing_headers_config" {
  description = "The server timing headers for this cache policy."
  type        = list(any)
  default     = []
}

variable "security_headers_config" {
  description = "The security headers for this cache policy."
  type        = list(any)
  default     = []
}

