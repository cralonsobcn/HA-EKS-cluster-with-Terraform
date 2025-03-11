## ( -- AWS Config -- )
variable "aws_access_key" { # TODO
  type = string
  default = "" 
  sensitive = true
  description = "Access Key to allow Terraform connect to AWS" 
}

variable "aws_secret_key" { # TODO
  type = string
  default = "" 
  sensitive = true
  description = "Secret  Key to allow Terraform connect to AWS"
}
