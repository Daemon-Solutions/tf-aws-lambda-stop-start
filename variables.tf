variable "name" {
  description = "This value will be added as a name prefix to the resources this module creates"
  type        = "string"
}

variable "envname" {
  description = "This value will be added after 'name' to further distinguish the resources this module creates"
  type        = "string"
}

variable "region" {
  description = "AWS region name"
  type        = "string"
  default     = "eu-west-1"
}

variable "enabled" {
  description = "Whether or not to enable or disable the scheduled start stop. This allows the flexibility to enable or disable resources per environment"
  type        = "string"
  default     = 0
}

variable "cron_start_schedule" {
  description = "Cron expression stating the start schedule time"
  type        = "string"
  default     = "cron(0 7 * * ? *)"
}

variable "cron_stop_schedule" {
  description = "Cron expression stating the stop schedule time"
  type        = "string"
  default     = "cron(0 17 * * ? *)"
}
