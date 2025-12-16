resource "aws_db_subnet_group" "db" {
  name       = "strapi-db-subnet"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  identifier              = "strapi-postgres"
  engine                  = "postgres"
  engine_version          = "15.4"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_name                 = "strapi"
  username                = var.db_username
  password                = var.db_password
  publicly_accessible     = false
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db.name
  skip_final_snapshot     = true
}
