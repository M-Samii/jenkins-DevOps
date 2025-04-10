region = "us-east-1"
subnets = [
  {
    name       = "pub_subnet_1"
    cidr_block = "10.0.0.0/24"
    type       = "public"
    az         = "a"
  },
  {
    name       = "pub_subnet_2"
    cidr_block = "10.0.1.0/24"
    type       = "public"
    az         = "b"

  },
  {

    name       = "priv_subnet_1"
    cidr_block = "10.0.2.0/24"
    type       = "private"
    az         = "a"

  },
  {
    name       = "priv_subnet_2"
    cidr_block = "10.0.3.0/24"
    type       = "private"
    az         = "b"

  }
]
worker_ami = "ami-05fb6c1dca9850ef1"

vote_ami = "ami-033103c5dfebee449"

result_ami = "ami-02085ff3416558435"

db_password = "postgres"