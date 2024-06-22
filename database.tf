// AWS RDS Database instance + Elasticache Redis instance
// https://docs.aws.amazon.com/cli/latest/reference/rds/describe-orderable-db-instance-options.html
// get the available RDS instance options using the nifty command below:
// aws rds describe-orderable-db-instance-options --engine mysql --engine-version 5.7.44-rds.20240408 --region ap-southeast-2 --page-size 100 --profile offshore > available.txt
// creation of a RDS instance can take up to 5 mins or more. don't panic!

// AWS RDS Database instance
resource "aws_db_instance" "default" {
  identifier                      = var.rds_instance_name
  db_name                         = var.rds_instance_name
  engine                          = var.rds_engine
  engine_version                  = var.rds_engine_version
  instance_class                  = var.rds_instance_class
  license_model                   = "general-public-license"
  allocated_storage               = 20
  username                        = var.rds_instance_username
  password                        = var.rds_instance_password
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]
  db_subnet_group_name            = aws_db_subnet_group.default.name
  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
  publicly_accessible             = false
  skip_final_snapshot             = true
}

resource "aws_elasticache_cluster" "redis_cluster" {
  cluster_id           = var.redis_cluster_id
  engine               = "redis"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.redis_num_cache_nodes
  parameter_group_name = var.redis_parameter_group_name
  engine_version       = var.redis_engine_version
  port                 = var.redis_port

  subnet_group_name  = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids = [aws_security_group.redis_security_group.id]
}
