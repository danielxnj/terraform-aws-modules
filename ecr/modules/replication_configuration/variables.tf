################################################################################
# Registry Replication Configuration
################################################################################

variable "registry_replication_rules" {
  description = "The replication rules for a replication configuration. A maximum of 10 are allowed"
  type        = any
  default     = []
}

variable "create" {
  description = "Whether to create this resource or not"
  type        = bool
  default     = true
}
