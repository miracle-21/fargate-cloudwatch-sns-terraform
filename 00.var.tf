variable "region" {
  default = "ap-northeast-2"
}

variable "cidr" {
  default = "10.0.0.0/16"
}

variable "rocidr" {
  default = "0.0.0.0/0"
}

variable "count_pub_subnets" {
  type    = number
  default = 2
}

variable "count_pri_subnets" {
  type    = number
  default = 2
}

variable "count_db_subnets" {
  type    = number
  default = 2
}

variable "ami" {
  description = "EC2 bastion AMI"
  default = ""
}

variable "name" {
  default = "test"
}

variable "cluname" {
  default = "test-clu"
}

variable "kubeconfig_path" {
  default = "~/.kube"
}

variable "ACM_ARN" {
  description = "ACM_ARN"
  default = ""
}

variable "access_key" {
  description = "Access_key for AWS CLI"
  type    = string
  default = ""
}

variable "secret_key" {
  description = "Secret_key for AWS CLI"
  type    = string
  default = ""
}

#SNS
variable "email_addresses" {
  description = "Email address for SNS"
  type    = list(string)
  default = [""]
}

#Image
variable "web_image" {
  description = "Image for web service"
  type    = string
  default = "nginx"
}

variable "was_image" {
  description = "Image for was service"
  type    = string
  default = "tomcat"
}

#cloudwatch
variable "FluentBitHttpPort" {
  type    = string
  default = "2020"
}

variable "FluentBitReadFromHead" {
  type    = string
  default = "Off"
}

variable "FluentBitHttpServer" {
  type    = string
  default = "On"
}

variable "FluentBitReadFromTail" {
  type    = string
  default = "On"
}