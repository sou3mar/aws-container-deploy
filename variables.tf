# Terraform variables file

variable "aws_region" {
  description = "The AWS region to deploy to"
  default     = "ap-southeast-2"
  type        = string
}

variable "aws_profile" {
  description = "AWS Profile to use"
  type        = string
  default     = "default"
}

variable "prefix" {
  description = "The prefix for all infra resources"
  default     = "myproject"
  type        = string
}

# RDS instance variables
variable "rds_instance_name" {
  description = "RDS instance db name"
  type        = string
}

variable "rds_instance_username" {
  description = "RDS instance username"
  type        = string
}

variable "rds_instance_password" {
  description = "RDS instance password"
  type        = string
}

variable "rds_engine" {
  description = "The database engine to be used for the RDS instance"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "The engine version of the RDS instance"
  type        = string
  default     = "5.7.44-rds.20240408"
}

variable "rds_instance_class" {
  description = "The instance class of the RDS instance"
  type        = string
  default     = "db.t3.medium"
}

# Elasticache Redis variables
variable "redis_cluster_id" {
  description = "The name of the cluster"
  type        = string
  default     = "redis-cluster"
}

variable "redis_node_type" {
  description = "The compute and memory capacity of the nodes"
  type        = string
  default     = "cache.m4.medium"
}

variable "redis_num_cache_nodes" {
  description = "The number of cache nodes the cluster should have"
  type        = number
  default     = 1
}

variable "redis_parameter_group_name" {
  description = "The name of the parameter group to associate with this cluster"
  type        = string
  default     = "default.redis5.0"
}

variable "redis_engine_version" {
  description = "The version number of the cache engine to be used for the nodes in this cluster"
  type        = string
  default     = "5.0.6"
}

variable "redis_port" {
  description = "The port number on which each of the cache nodes accepts connections"
  type        = number
  default     = 6379
}

# EC2 Auto Scaling Group variables
variable "ec2_min_size" {
  description = "The minimum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ec2_max_size" {
  description = "The maximum number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "ec2_desired_capacity" {
  description = "The desired number of instances in the Auto Scaling Group"
  type        = number
  default     = 1
}

variable "health_check_grace_period" {
  description = "The amount of time, in seconds, that Auto Scaling waits before checking the health status of an EC2 instance"
  type        = number
  default     = 300
}

# ECS task variables
variable "ec2_instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
}

variable "ec2_key" {
  description = "The key pair used to SSH into EC2 instances"
  type        = string
}

variable "task_cpu" {
  description = "The amount of CPU to allocate to the task"
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "The amount of memory used by the task"
  type        = number
  default     = "512"
}

variable "docker_image" {
  description = "The Docker image to use for the task"
  type        = string
  default     = "DOCKER_IMAGE"
}

# ECS Service variables
variable "ecs_service_desired_count" {
  description = "The number of tasks to run in the service"
  type        = number
  default     = 1
}
