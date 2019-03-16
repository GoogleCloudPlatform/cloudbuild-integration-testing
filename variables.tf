variable "project-name" {
  type    = "string"
}

variable "region" {
  type    = "string"
  default = "us-central1-c"
}

variable "instance-name" {
  type  = "string"
  default = "test"
}

variable "self-destruct-timeout-minutes" {
    type = "string"
    default = "240"
}