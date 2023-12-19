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

variable "cookie_behavior" {
  description = "Specifies how CloudFront handles cookies."
  type        = string
  default     = "none"
}

variable "cookies" {
  description = "A list of cookies that you want CloudFront to forward to the origin for this cache behavior."
  type        = list(string)
  default     = []
}

variable "header_behavior" {
  description = "Specifies how CloudFront handles query strings."
  type        = string
  default     = "none"
}

variable "headers" {
  description = "A list of HTTP header names that you want CloudFront to forward to the origin for this cache behavior."
  type        = list(string)
  default     = []
}

variable "query_string_behavior" {
  description = "Specifies how CloudFront handles query strings."
  type        = string
  default     = "none"
}

variable "query_strings" {
  description = "A list of query string names that you want CloudFront to forward to the origin for this cache behavior."
  type        = list(string)
  default     = []
}
