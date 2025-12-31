resource "aws_db_instance" "devops_db" {
  allocated_storage    = 20
  engine               = "postgres"
  engine_version       = "16.3"  # Updated to a modern, available version
  instance_class       = "db.t3.micro"
  db_name              = "devopsdb"
  username             = "adminuser"
  password             = "yourpassword123"
  parameter_group_name  = "default.postgres16" # This must match the version 16
  skip_final_snapshot  = true

  tags = {
    Name        = "devops-database"
    Environment = "dev"
  }
}
