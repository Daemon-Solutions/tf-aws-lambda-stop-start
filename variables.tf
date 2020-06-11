variable "name" {
  type        = string
  description = "This value will be added as a name prefix to the resources this module creates"
}

variable "envname" {
  type        = string
  description = "This value will be added after 'name' to further distinguish the resources this module creates"
}

variable "region" {
  type        = string
  description = "AWS region name"
  default     = "eu-west-1"
}

variable "enabled" {
  type        = bool
  description = "Whether or not to enable or disable the scheduled start stop. This allows the flexibility to enable or disable resources per environment"
  default     = false
}

variable "cron_start_schedule" {
  type        = string
  description = "Cron expression stating the start schedule time"
  default     = "cron(0 7 * * ? *)"
}

variable "cron_stop_schedule" {
  type        = string
  description = "Cron expression stating the stop schedule time"
  default     = "cron(0 17 * * ? *)"
}
