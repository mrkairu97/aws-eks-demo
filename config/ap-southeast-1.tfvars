aws_region = "ap-southeast-1"

vpc_cidr                = "172.16.0.0/16"
pub_1_subnet_cidr_block = "172.16.63.0/24"
pub_1_subnet_az         = "ap-southeast-1a"
pub_2_subnet_cidr_block = "172.16.191.0/24"
pub_2_subnet_az         = "ap-southeast-1b"
pri_1_subnet_cidr_block = "172.16.127.0/24"
pri_1_subnet_az         = "ap-southeast-1a"
pri_2_subnet_cidr_block = "172.16.255.0/24"
pri_2_subnet_az         = "ap-southeast-1b"

admin_users = [
  "arn:aws:iam::<ACCOUNT_NUMBER>:user/<USERNAME>"
]

is_dr_cluster = false

# admin_users = [
#   "arn:aws:iam::337968139672:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_80b13ef75dc7681b",
#   "arn:aws:iam::337968139672:role/GitHubRunner"
# ]