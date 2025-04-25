
variable "region" {
  description = "The AWS region your resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "ubuntu_ami_id" {
  description = "Explicit Ubuntu AMI ID to use for EC2 instance"
  type        = string
  default     = "ami-084568db4383264d4" # <-- Replace with the AMI you want
}
