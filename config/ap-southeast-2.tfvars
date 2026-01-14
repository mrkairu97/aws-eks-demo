aws_region = "ap-southeast-2"

vpc_cidr                = "172.17.0.0/16"
pub_1_subnet_cidr_block = "172.17.63.0/24"
pub_1_subnet_az         = "ap-southeast-2a"
pub_2_subnet_cidr_block = "172.17.191.0/24"
pub_2_subnet_az         = "ap-southeast-2b"
pri_1_subnet_cidr_block = "172.17.127.0/24"
pri_1_subnet_az         = "ap-southeast-2a"
pri_2_subnet_cidr_block = "172.17.255.0/24"
pri_2_subnet_az         = "ap-southeast-2b"


admin_users = [
  "arn:aws:iam::430515646008:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_d7b4bf0ecd9de6dc",
  "arn:aws:iam::430515646008:role/GitHubRunner"
]

# admin_users = [
#   "arn:aws:iam::337968139672:role/aws-reserved/sso.amazonaws.com/ap-southeast-1/AWSReservedSSO_AdministratorAccess_80b13ef75dc7681b",
#   "arn:aws:iam::337968139672:role/GitHubRunner"
# ]

is_dr_cluster = true