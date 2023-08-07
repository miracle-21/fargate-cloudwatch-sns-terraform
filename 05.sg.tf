# EKS 보안그룹
resource "aws_security_group" "eks_secu" {
  name   = "${var.name}-cluster"
  vpc_id = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.rocidr]
  }

  ingress = [
    {
      description      = "ssh"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = [var.rocidr]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "https"
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = [var.rocidr]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "redis"
      from_port        = 6379
      to_port          = 6379
      protocol         = "tcp"
      cidr_blocks      = [var.rocidr]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "tomcat"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = [var.rocidr]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    },
    {
      description      = "rds"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = [var.rocidr]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

  tags = {
    Name = "${var.name}-cluster"
  }
}