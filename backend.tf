terraform {
  backend "s3" {
    bucket = "kairu97-aws-tf-state-apse1"
    key    = "demo/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

# terraform {
#   backend "s3" {
#     bucket = "aws-tf-state-ap-southeast-1"
#     key    = "demo/terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }