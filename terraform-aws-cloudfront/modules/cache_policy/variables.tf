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

variable "default_ttl" {
  type        = number
  description = "The default amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request in the absence of an Cache-Control max-age or Expires header. Defaults to 86400. Valid values are between 0 and 31536000."
  default     = 86400
}

variable "max_ttl" {
  type        = number
  description = "The maximum amount of time (in seconds) that an object is in a CloudFront cache before CloudFront forwards another request to your origin to determine whether the object has been updated. Defaults to 31536000. Valid values are between 0 and 31536000."
  default     = 31536000
}

variable "min_ttl" {
  type        = number
  description = "The minimum amount of time that you want objects to stay in CloudFront caches before CloudFront queries your origin to see whether the object has been updated. Defaults to 0. Valid values are between 0 and 31536000."
  default     = 0
}

variable "cookie_behavior" {
  type        = string
  description = "Specifies how CloudFront handles cookies. Valid values are none, whitelist, all. Defaults to none."
  default     = "none"
}

variable "cookies" {
  type        = list(string)
  description = "A list of cookies that you want CloudFront to forward to your origin. Defaults to []"
  default     = []
}

variable "header_behavior" {
  type        = string
  description = "Specifies how CloudFront handles query strings and headers. Valid values are none, whitelist, all. Defaults to none."
  default     = "none"
}

variable "headers" {
  type        = list(string)
  description = "A list of header names that you want CloudFront to forward to your origin. Defaults to []"
  default     = []
}

variable "query_string_behavior" {
  type        = string
  description = "Specifies how CloudFront handles query strings and headers. Valid values are none, whitelist, all. Defaults to none."
  default     = "none"
}

variable "query_strings" {
  type        = list(string)
  description = "A list of query string names that you want CloudFront to forward to your origin. Defaults to []"
  default     = []
}

variable "enable_accept_encoding_brotli" {
  type        = bool
  description = "Indicates whether you want CloudFront to automatically compress certain files for this cache policy using the Brotli compression format. Defaults to false."
  default     = false
}

variable "enable_accept_encoding_gzip" {
  type        = bool
  description = "Indicates whether you want CloudFront to automatically compress certain files for this cache policy using gzip. Defaults to false."
  default     = false
}
