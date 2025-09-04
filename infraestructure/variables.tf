variable "instance_type" {
    description = "EC2 instance type"
    type        = string
    default     = "t2.micro"
}

variable "ami_id" {
    description = "AMI ID for the EC2 instance"
    type        = string
    default     = "ami-00ca32bbc84273381" # Replace with a suitable AMI for your region
}

variable "AWS_DEFAULT_REGION" {}
variable "AWS_ACCESS_KEY_ID" {}
variable "AWS_SECRET_ACCESS_KEY" {}
variable "CODE_BRANCH" {}