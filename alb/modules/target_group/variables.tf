variable "create" {
    description = "Determines if is created"
    type        = bool
    default     = true
}

variable "target_group_name" {
  description = "Name to use on target group created"
  type        = string
  default     = null
}

variable "target_group_port" {
  description = "Port to use on target group created"
  type        = number
  default     = 80
}

variable "target_group_protocol" {
  description = "Protocol to use on target group created"
  type        = string
  default     = "HTTP"
}

variable "target_group_health_check" {
  description = "Health check configuration for the target group"
  type        = map(any)
  default = {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }
}

variable "target_group_stickiness" {
  description = "Stickiness configuration for the target group"
  type        = map(any)
  default     = {}
}

variable "target_group_tags" {
  description = "A map of additional tags to add to the target group created"
  type        = map(string)
  default     = {}
}

variable "target_type" {
  description = "The type of target that you must specify when registering targets with this target group. The possible values are `instance` (targets are specified by instance ID) or `ip` (targets are specified by IP address). The default is `ip`"
  type        = string
  default     = null
}

variable "deregistration_delay" {
  description = "The amount of time for Elastic Load Balancing to wait before changing the state of a deregistering target from draining to unused. The range is 0-3600 seconds. The default value is 300 seconds"
  type        = number
  default     = null
}

variable "listener_rule_port" {
  description = "Port to use on listener rule created"
  type        = number
  default     = null
}


variable "listener_rules" {
  description = "List of listener rules to create on the load balancer"
  type        = map(any)
  default     = {}
}

variable "load_balancer_arn" {
  description = "The ARN of the load balancer to attach the listener rule to"
  type        = string
}

variable "listener_port" {
  description = "Port to use on listener created"
  type        = number
  default     = null
}

variable "listener_protocol" {
  description = "Protocol to use on listener created"
  type        = string
  default     = null
}

variable "listener_certificate_arn" {
  description = "Certificate ARN to use on listener created"
  type        = string
  default     = null
}

variable "listener_tags" {
  description = "A map of additional tags to add to the listener created"
  type        = map(string)
  default     = {}
}

variable "vpc_name" {
  description = "Name of the VPC to use"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC to use"
  type        = string
  default     = null
}