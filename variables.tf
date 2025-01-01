variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "remote_state_bucket" {
  description = "AWS s3 bucket to store the state remotely"
  default     = "kafka-infrastructure-state"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  default     = "10.0.1.0/24"
}

variable "task_definition_file" {
  description = "Path to the local task definition JSON file"
  default     = "kafkaservice-task-definition.json"  # Change as needed
}
