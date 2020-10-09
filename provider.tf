variable "aws_profile" {
	type        = string
	default     = "default"
  description = "Profile to use, defined in ~/.aws/[credentials, config]"
}

variable "aws_region" {
	type        = string
	default     = "ap-southeast-2"
  description = "AWS region, defaults to Sydney"
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}