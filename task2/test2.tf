
# Create the Security Group
resource "aws_security_group" "MysqlDB" {
  name         = "MysqlDBSG"
  description  = "MysqlDBSG"
  
  # allow ingress of port 22
  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  } 

  ingress {
    cidr_blocks = ["0.0.0.0/0"]  
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
  } 

  # allow egress of all ports
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
   Name = "MySql Security Group"
   Description = "Mysql VPC Security Group"
  }
} # end resource


resource "aws_db_instance" "mysql" {
  allocated_storage       = 20 # 100 GB of storage, gives us more IOPS than a lower number//20GB for free tier
  engine                  = "mysql"
  engine_version          = "5.7.19"
  instance_class          = "db.t2.micro" # use micro if you want to use the free tier
  identifier              = "mysql"
  publicly_accessible     = false
  apply_immediately       = true
  port                    = 3306
  vpc_security_group_ids  = [aws_security_group.MysqlDB.id]
  multi_az                = "true"
  name                    = "crossover"   # database name
  username                = "favour"    # username
  password                = "favour123" # password
  storage_type            = "gp2"
  backup_retention_period = 7 # how long you’re going to keep your backups
 # availability_zone       = aws_subnet.PrivateDB.availability_zone # prefered AZ
  final_snapshot_identifier = "mysqldb-final-snapshot" # final snapshot when executing terraform destroy
  skip_final_snapshot     = false


  tags = {
    Name = "mariadb-instance"
  }
}


output "db_endpoint" {
  value       = aws_db_instance.mysql.address
  description = "The endpoint of the database instance."
}