resource "aws_db_parameter_group" "pmh_pg" {
  name   = "${var.name}-mariadb-pg"
  family = "mariadb10.6"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_general_ci"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8_general_ci"
  }

  parameter {
    name  = "time_zone"
    value = "Asia/Seoul"
  }
}

resource "aws_db_option_group" "pmh_og" {
  name                 = "${var.name}-mariadb-og"
  engine_name          = "mariadb"
  major_engine_version = "10.6"
}

resource "aws_db_subnet_group" "pmh_dbsg" {
  name       = "${var.name}-dbsg"
  subnet_ids = concat(aws_subnet.db[*].id)
}

resource "aws_db_instance" "pmh_db" {
  engine                     = "mariadb"
  engine_version             = "10.6"
  auto_minor_version_upgrade = false
  identifier                 = "${var.name}db"
  username                   = "root"
  password                   = "12345678"

  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  max_allocated_storage = 100
  storage_type          = "gp2"

  multi_az            = true
  publicly_accessible = false
  network_type        = "IPV4"

  vpc_security_group_ids = [aws_security_group.db_secu.id]
  db_subnet_group_name   = aws_db_subnet_group.pmh_dbsg.name
  port                   = 3306

  db_name              = "${var.name}db"
  parameter_group_name = aws_db_parameter_group.pmh_pg.name
  option_group_name    = aws_db_option_group.pmh_og.name

  skip_final_snapshot     = true
  backup_retention_period = 7

  tags = {
    Name = "${var.name}db"
  }
}
