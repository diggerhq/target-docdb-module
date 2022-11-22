resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name        = "${var.cluster_identifier}_docdb_subnet"
  description = "Allowed subnets for DB cluster instances"
  subnet_ids  = var.private_subnets
}

resource "random_password" "master_password" {
  length  = 32
  special = false
}

resource "aws_security_group" "docdb_sg" {
  name_prefix = "${var.cluster_identifier}-docdb-sg"
  vpc_id      = var.vpc_id
  description = "Digger docdb ${var.cluster_identifier}"

  # Only postgres in
  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.security_groups
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_docdb_cluster" "docdb" {
  cluster_identifier      = var.cluster_identifier
  engine                  = var.engine
  master_username         = var.master_username
  master_password         = random_password.master_password.result
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.docdb_sg.id]
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
}

resource "aws_docdb_cluster_instance" "default" {
  count                      = var.instances_number
  identifier                 = "${var.cluster_identifier}-${count.index + 1}"
  cluster_identifier         = aws_docdb_cluster.docdb.id
  apply_immediately          = true
  instance_class             = var.instance_class
  engine                     = var.engine
  auto_minor_version_upgrade = true
}

resource "aws_ssm_parameter" "master_password" {
  name  = "${var.cluster_identifier}.master_password"
  value = random_password.master_password.result
  type  = "SecureString"
}

resource "aws_ssm_parameter" "docdb_uri" {
  name  = "${var.cluster_identifier}.docdb_uri"
  value = "mongodb://${var.master_username}:${random_password.master_password.result}@${aws_docdb_cluster.docdb.endpoint}/test?retryWrites=true&w=majority"
  type  = "SecureString"
}




