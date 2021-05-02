terraform {
  required_version = ">= 0.11"
   backend "s3" {
      bucket = "suriya-build-artifacts"
      key    = "rds.tfstate"
      workspace_key_prefix="rds"
   }
  #  required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = ">= 2.7.0"
  #   }
  # }
  # backend "s3" {
  #   bucket = "suriya-build-artifacts"
  #   key    = "myapp/myapp.tfstate"
  #   region = "ap-south-1"
  # }
}

provider "aws" {
  region = "ap-south-1"
  version = "~> 2.70"
}

variable "environment" {
  
}

resource "aws_rds_cluster" "default" {
  cluster_identifier = "sample-${var.environment}-cluster"
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
  identifier         = "sample-${var.environment}-cluster"
  cluster_identifier = "${aws_rds_cluster.default.id}"
  instance_class     = "db.t2.medium"
  engine="aurora-mysql"
  engine_version="5.7.mysql_aurora.2.09.2"
  publicly_accessible = true
  lifecycle {
    create_before_destroy = true
    ignore_changes = ["engine_version"]
  }
  # engine             = "${aws_rds_cluster.default.engine}"
  # engine_version     = "${aws_rds_cluster.default.engine_version}"
}

resource "aws_appautoscaling_target" "replicas" {
  service_namespace  = "rds"
  scalable_dimension = "rds:cluster:ReadReplicaCount"
  resource_id        = "cluster:${aws_rds_cluster.default.id}"
  min_capacity       = 1
  max_capacity       = 1
}

resource "aws_appautoscaling_policy" "replicas" {
  name               = "cpu-auto-scaling"
  service_namespace  = "${aws_appautoscaling_target.replicas.service_namespace}"
  scalable_dimension = "${aws_appautoscaling_target.replicas.scalable_dimension}"
  resource_id        = "${aws_appautoscaling_target.replicas.resource_id}"
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "RDSReaderAverageCPUUtilization"
    }

    target_value       = 75
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
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
