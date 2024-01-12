variable "create" {
    description = "Determines if is created"
    type        = bool
    default     = true
}


variable "listener_rules" {
  description = "List of listener rules to create on the load balancer"
  type        = map(any)
  default     = {}
}

variable "listener_arn" {
  description = "The ARN of the listener to which to attach the rule"
  type        = string
} 