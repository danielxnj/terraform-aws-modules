# locals {
#   listener_domain_combinations = flatten([
#     for port, listener in var.aws_lb_listeners :
#     [for certificate in listener.additional_certificates : {
#       port            = port
#       certificate_arn = certificate.certificate_arn
#       domain_name     = certificate.domain_name
#     }]
#   ])
# }

variable "enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable the ALB module"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources"
  default     = {}
}

variable "vpc_id" {
  type        = string
  description = "VPC ID to associate with ALB"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to associate with ALB"
  default     = null
}

variable "security_group_names" {
  type        = list(string)
  default     = []
  description = "A list of additional security group names to allow access to ALB"
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "A list of additional security group ids to allow access to ALB"
}

variable "internal" {
  type        = bool
  default     = false
  description = "A boolean flag to determine whether the ALB should be internal"
}

variable "access_logs" {
  type        = map(any)
  default     = {}
  description = "A boolean flag to enable/disable access_logs"
}


variable "cross_zone_load_balancing_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable cross zone load balancing"
}

variable "http2_enabled" {
  type        = bool
  default     = true
  description = "A boolean flag to enable/disable HTTP/2"
}

variable "idle_timeout" {
  type        = number
  default     = 60
  description = "The time in seconds that the connection is allowed to be idle"
}

variable "ip_address_type" {
  type        = string
  default     = "ipv4"
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`."
}

variable "deletion_protection_enabled" {
  type        = bool
  default     = false
  description = "A boolean flag to enable/disable deletion protection for ALB"
}

variable "drop_invalid_header_fields" {
  type        = bool
  default     = false
  description = "Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false)."
}

variable "create_security_group" {
  type        = bool
  description = "Enables the security group"
  default     = false
}

variable "load_balancer_name" {
  type        = string
  default     = ""
  description = "The name for the default load balancer, uses a module label name if left empty"
}

variable "load_balancer_name_max_length" {
  type        = number
  default     = 32
  description = "The max length of characters for the load balancer."
}

variable "preserve_host_header" {
  type        = bool
  default     = false
  description = "Indicates whether the Application Load Balancer should preserve the Host header in the HTTP request and send it to the target without any change."
}

variable "xff_header_processing_mode" {
  type        = string
  default     = "append"
  description = "Determines how the load balancer modifies the X-Forwarded-For header in the HTTP request before sending the request to the target. The possible values are append, preserve, and remove. Only valid for Load Balancers of type application. The default is append"
}

variable "vpc_name" {
  type        = string
  description = "The name for the default vpc, uses a module label name if left empty"
  default     = ""
}

variable "subnet_names" {
  type        = list(any)
  description = "The names for the default subnets, uses a module label name if left empty"
  default     = null
}

variable "security_group_name" {
  type        = string
  default     = null
  description = "Name of the security group to be associated with the replication group"
}

variable "security_group_description" {
  type        = string
  default     = null
  description = "Description of the security group to be associated with the replication group"
}

variable "security_group_tags" {
  type        = map(string)
  description = "Additional tags for the security group to create for the DocumentDB cluster"
  default     = {}
}

variable "security_group_rules" {
  description = "Map of security group rules"
  type = map(object({
    cidr_blocks = list(string)
    protocol    = string
    type        = string
    description = optional(string)
    from_port   = optional(number)
    to_port     = optional(number)
  }))
  default = null
}

variable "aws_lb_listeners" {
  description = "A map of listener configurations where the key is the port number"
  type = any
  # type = map(object({
  #   port : number
  #   protocol : string
  #   ssl_policy : optional(string)
  #   certificate_arn : optional(string)
  #   # additional_certificates : optional(list(object({
  #   #   certificate_arn : string
  #   #   domain_name : string
  #   # })))
  #   # listener_fixed_response : optional(list(object({
  #   #   content_type : optional(string)
  #   #   message_body : optional(string)
  #   #   status_code : optional(string)
  #   # })))
  #   # listener_redirect : optional(list(map(string)))
  #   default_action : optional(object({
  #     type : string
  #     target_group_arn : optional(string)
  #   }))
  #   tags : optional(map(string))
  # }))
  default = []
}

variable "load_balancer_type" {
  type        = string
  description = "The type of load balancer to create. Possible values are `application` or `network`"
}

variable "enable_xff_client_port" {
  type        = bool
  default     = null
  description = "Enables the X-Forwarded-For, X-Forwarded-Proto, and X-Forwarded-Port headers"
}
