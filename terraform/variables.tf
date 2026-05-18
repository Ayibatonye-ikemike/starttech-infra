variable "aws_region" {
  type        = string
  description = "The target AWS region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "production"
}

variable "project_name" {
  type        = string
  description = "The base name for all project resources"
  default     = "starttech"
}

variable "docker_username" { 
  type = string 
}

variable "mongo_uri" { 
  type = string 
}
