# This file is responsible for creating the ECS cluster, EC2 instance(s) and the services/tasks that will run on it

# ECS Cluster and Services
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.prefix}_ecs_task_execution_role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS instance role
resource "aws_iam_role" "ecs_instance_role" {
  name = "${var.prefix}_ecs_instance_role"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_ec2_full_access" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_ec2_container_service_for_ec2_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "${var.prefix}_ecs_instance_role"
  role = aws_iam_role.ecs_instance_role.name

  depends_on = [aws_iam_role_policy_attachment.ecs_instance_role_ec2_container_service_for_ec2_role, aws_iam_role_policy_attachment.ecs_instance_role_ec2_full_access]
}

data "aws_ami" "latest_ecs" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

# Cluster configurations
resource "aws_ecs_cluster" "cluster" {
  name = "${var.prefix}_job_cluster"
}


resource "aws_launch_template" "lt" {
  name          = "${var.prefix}_ecs_launch_template"
  image_id      = data.aws_ami.latest_ecs.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key

  network_interfaces {
    subnet_id       = aws_subnet.main["app_subnet1"].id
    security_groups = [aws_security_group.ecs_instances_sg.id]
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  user_data = base64encode(<<USERDATA
  #!/bin/bash
  echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
  sudo service docker start
  sudo start ecs
  USERDATA
  )

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity = var.ec2_desired_capacity
  min_size         = var.ec2_min_size
  max_size         = var.ec2_max_size

  health_check_grace_period = var.health_check_grace_period
  health_check_type         = "EC2"
  vpc_zone_identifier       = [aws_subnet.main["app_subnet1"].id, aws_subnet.main["app_subnet2"].id]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefix}_ec2_instance"
    propagate_at_launch = true
  }
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/${var.prefix}_main_container"
}

resource "aws_ecs_task_definition" "main_task" {
  family                   = "${var.prefix}_main_container"
  network_mode             = "host"
  requires_compatibilities = ["EC2"]

  cpu                = var.task_cpu
  memory             = var.task_memory
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  lifecycle {
    create_before_destroy = true
  }

  container_definitions = jsonencode([
    {
      "name" : "main_container",
      "image" : var.docker_image,
      "essential" : true,
      "cpu" : var.task_cpu,
      "portMappings" : [
        {
          "containerPort" : 80,
          "hostPort" : 80
        },
        {
          "containerPort" : 443,
          "hostPort" : 443
        },
      ],
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : aws_cloudwatch_log_group.ecs_log_group.name,
          "awslogs-region" : var.aws_region,
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main_task_service" {
  name            = "${var.prefix}_ecs_main_service"
  cluster         = aws_ecs_cluster.cluster.arn
  task_definition = aws_ecs_task_definition.main_task.arn
  desired_count   = var.ecs_service_desired_count
  launch_type     = "EC2"
}
