provider "aws" {
  region = "eu-west-2" 
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create public subnets in two availability zones (eu-west-2a and eu-west-2b)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = cidrsubnet(aws_vpc.my_vpc.cidr_block, 8, count.index)
  availability_zone = element(["eu-west-2a", "eu-west-2b"], count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index}"
  }
}

# Create a security group for your EC2 instances
resource "aws_security_group" "web_server_sg" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = aws_vpc.my_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Define ingress rules for your application, e.g., port 80 for HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a default route in the VPC's main route table to the Internet Gateway
resource "aws_route" "public_route" {
  route_table_id         = aws_vpc.my_vpc.default_route_table_id
  destination_cidr_block = "0.0.0.0/0"  # This is the default route for internet access
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Create an Application Load Balancer (ALB)
resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  enable_deletion_protection = false
}

# Create a target group
resource "aws_lb_target_group" "my_target_group" {
  name     = "my-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.my_vpc.id
}

# Create an ALB listener for HTTP
resource "aws_lb_listener" "my_alb_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = 80      # The port where traffic enters the ALB
  protocol          = "HTTP"  # Use HTTP as the protocol

  default_action {
    target_group_arn = aws_lb_target_group.my_target_group.arn
    type             = "forward"
  }
}

# Create a Launch Template for EC2 instances
resource "aws_launch_template" "my_lt" {
  name_prefix = "my-lt-"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      delete_on_termination = true
      volume_type = "gp2"
    }
  }

  instance_type = "t2.micro"
  image_id      = "ami-0cf6f2b898ac0b337"  
}

# Create an Auto Scaling Group (ASG)
resource "aws_autoscaling_group" "my_asg" {
  name                 = "my-asg"
  max_size             = 1
  min_size             = 1
  desired_capacity     = 1
  target_group_arns    = [aws_lb_target_group.my_target_group.arn]

  # Set the public subnets for instances in the Auto Scaling Group
  vpc_zone_identifier  = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.my_lt.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Policies
resource "aws_autoscaling_policy" "scale_out_policy" {
  name                   = "scale-out-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  scaling_adjustment     = 1
  cooldown               = 300  
}

resource "aws_autoscaling_policy" "scale_in_policy" {
  name                   = "scale-in-policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.my_asg.name
  scaling_adjustment     = -1
  cooldown               = 300  
}

# Create an EC2 instance
resource "aws_instance" "my_linux_instance" {
  count         = 1
  ami           = "ami-0cf6f2b898ac0b337"  
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update
    sudo apt install -y apache2
    echo '<html><body><h1>Hello, World from Linux!</h1></body></html>' > /var/www/html/index.html
    sudo systemctl start apache2
    sudo systemctl enable apache2
    EOF
}
