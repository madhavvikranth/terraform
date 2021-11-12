# terraform {
#   required_providers {
#     aws = {
#       source = "hashicorp/aws"
#       version = "3.64.1"
#     }
#   }
# }

provider "aws" {
  region = var.region
}
