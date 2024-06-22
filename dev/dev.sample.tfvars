
##########################################
# Required
##########################################

prefix = "myproject" // prefix for all infra resources

# AWS EC2 Auto Scaling Group configuration
ec2_min_size              = 1
ec2_max_size              = 2
ec2_desired_capacity      = 1
health_check_grace_period = 300 # in seconds

# AWS ECS Task definition configuration
// https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
task_cpu          = "2048"                                                                            // 2048 is equal to 2 vCores
task_memory       = "3500"                                                                            // task_memory should be less than the available container memory, specified in instance type (in MiB)
docker_image      = "<AWS_ACCOUNT_ID>.dkr.ecr.ap-southeast-2.amazonaws.com/<DOCKER_IMAGE_NAME:latest" // place the docker image name available on ECR here
ec2_instance_type = "t3.medium"                                                                       // t3.medium is a good starting point. modify as needed
ec2_key           = "blob"                                                                            // place the key pair "name" created in your AWS account

# AWS ECS Service configuration
ecs_service_desired_count = 1

# AWS Elasticache Redis configuration
redis_cluster_id           = "redis-cluster"
redis_node_type            = "cache.m4.medium"
redis_num_cache_nodes      = 1
redis_parameter_group_name = "default.redis5.0"
redis_engine_version       = "5.0.6"
redis_port                 = 6379

# AWS RDS configuration
rds_instance_name     = "myprojectdb" // only alphanumeric chars
rds_instance_username = "admin"
rds_instance_password = "password" // default password. must be changed afterwards
rds_engine            = "mysql"
rds_engine_version    = "5.7.44-rds.20240408"
rds_instance_class    = "db.t3.medium"

##########################################
# Optional (default values below)
##########################################

aws_region  = "ap-southeast-2" // default region
aws_profile = "default"        // "default" profile unless specified
