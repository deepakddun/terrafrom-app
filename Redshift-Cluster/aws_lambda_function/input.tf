variable "security_group_id" {
  type = string
  default = "sg-0b57b04af571dd653"
}

variable "sns_queue" {
  type = string
  default = "terraform-redshift-sns-topic"
}