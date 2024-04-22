resource "aws_db_instance" "database1" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = var.dbname
  username             = var.username
  password             = var.password
  skip_final_snapshot  = true
  availability_zone    = var.rds-az
  db_subnet_group_name = aws_db_subnet_group.subnet-grp.name
  vpc_security_group_ids = var.sgrds
  
  }
   
   resource "aws_db_subnet_group" "subnet-grp" {
    subnet_ids = [var.subnt1 , var.subnt2]
     
   }