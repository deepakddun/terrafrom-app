variable "redshift_password" {
  type = string

}

variable "sns_queue" {
  type = string
  default = "terraform-redshift-sns-topic"
}

variable "security_group_id" {
  type = string
  default = "sg-0b57b04af571dd653"
}