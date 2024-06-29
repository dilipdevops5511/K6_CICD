variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "us-east-2"
}

variable "availability_zones" {
  description = "List of availability zones to use for the subnets."
  default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}

variable "ami_id" {
  description = "The AMI ID to use for the yesEC2 instances."
  default     = "ami-0e001c9271cf7f3b9"
}

variable "instance_type" {
  description = "The type of instance to use."
  default     = "t2.micro"
}
