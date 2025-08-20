variable "region" {
  description = "AWS region"
  type = string
}

variable "profile" {
  description = "AWS profile"
  type = string
}

variable "my_ip" {
  description = "Allow CIDR"
  type = string
  sensitive = true
}

variable "instance_type" {
  description = "Instance type"
  type = string
}

variable "kp" {
  description = "Key pair"
  type = string
}

variable "admin_password" {
  description = "ubuntu user password"
  type = string
  sensitive = true
}

variable "ansible_user" {
  description = "ansible slave username"
  type = string
}