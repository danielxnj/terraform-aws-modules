variable "create" {
  description = "Whether to create this resource or not"
  type        = bool
  default     = true
}


################################################################################
# Registry Pull Through Cache Rule
################################################################################

variable "registry_pull_through_cache_rules" {
  description = "List of pull through cache rules to create"
  type        = map(map(string))
  default     = {}
}
