variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-east-1"
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets."
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ami_id" {
  description = "The AMI ID to use for the yesEC2 instances."
  default     = "ami-011e54f70c1c91e17"
}

variable "instance_type" {
  description = "The type of instance to use."
  default     = "t2.micro"
}
