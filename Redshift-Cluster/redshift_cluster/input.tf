variable "redshift_password" {
  type = string

}

variable "sns_queue" {
  type = string
  default = "terraform-redshift-sns-topic"
}