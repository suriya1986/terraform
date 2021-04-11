terraform {
  required_version = ">= 0.11"
   backend "s3" {
      bucket = "suriya-build-artifacts"
      key    = "rds.tfstate"
      workspace_key_prefix="rds"
   }
  # backend "s3" {
  #   bucket = "suriya-build-artifacts"
  #   key    = "myapp/myapp.tfstate"
  #   region = "ap-south-1"
  # }
}

provider "aws" {
  region = "ap-south-1"
}

variable "environment" {
  
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "aurora-cluster-demo"
  engine="aurora-mysql"
  engine_version="5.7.mysql_aurora.2.09.2"
  availability_zones = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
  database_name      = "mydb"
  master_username    = "foo"
  master_password    = "barbut8chars"
  port=3306
  apply_immediately=true
}


resource "aws_rds_cluster_instance" "cluster_instances" {
  count              = 1
  identifier         = "aurora-cluster-demo"
  cluster_identifier = "${aws_rds_cluster.default.id}"
  instance_class     = "db.t2.medium"
  engine             = "${aws_rds_cluster.default.engine}"
  engine_version     = "${aws_rds_cluster.default.engine_version}"
}
# resource "aws_instance" "web" {
#   ami           = "ami-0e306788ff2473ccb"
#   instance_type = "t2.micro"

#   tags = {
#     Name = "HelloWorld-${var.environment}"
#   }
# }

# output "instance_arn" {
#   value = "${aws_instance.web.arn}"
# }

# resource "aws_s3_bucket" "terraform_state" {
#   # TODO: change this to your own name! S3 bucket names must be *globally* unique.
#   bucket = "suriya-tf-state-bucket"

#   # Enable versioning so we can see the full revision history of our
#   # state files
#   versioning {
#     enabled = true
#   }

#   # Enable server-side encryption by default
#   server_side_encryption_configuration {
#     rule {
#       apply_server_side_encryption_by_default {
#         sse_algorithm = "AES256"
#       }
#     }
#   }
# }

# resource "aws_s3_bucket" "b" {
#   bucket = "my-tf-test-bucket"
#   acl    = "private"

#   tags = {
#     Name        = "My bucket"
#     Environment = "Dev"
#   }
# }
