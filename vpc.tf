data "aws_vpc" "vpc" {
  id = local.vpc_id
}

# data "aws_subnet" "campus_1" {
#   id = local.subnets["campus_1"]
# }

# data "aws_subnet" "campus_2" {
#   id = local.subnets["campus_2"]
# }

data "aws_subnet" "private_1" {
  id = local.subnets["private_1"]
}

data "aws_subnet" "private_2" {
  id = local.subnets["private_2"]
}

# data "aws_subnet" "public_1" {
#   id = local.subnets["public_1"]
# }

# data "aws_subnet" "public_2" {
#   id = local.subnets["public_2"]
# }

