variable "name" {}

variable "envname" {}

variable "cron_start_schedule" {
  default = "cron(0 8 * * ? *)"
}

variable "cron_stop_schedule" {
  default = "cron(0 19 * * ? *)"
}
