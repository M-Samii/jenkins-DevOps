variable "subnets" {
  type = list(object({
    name       = string
    cidr_block = string
    type       = string
    az         = string
  }))
}


variable "region" {
  type    = string
  default = "us-east-1"
}



# Variables

variable "db_password" {

  type = string
  sensitive = true
  default = "admin"
  
}
variable "db_username" {
  type = string
  default = "admin"
}