resource "aws_instance" "bastion" {
  ami                    = "ami-0fc32db49bc3bfbb1"
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = "BastionKey"
  tags = {
    Name = "vending-machine-bastion"
  }
}

resource "aws_security_group" "bastion" {
  vpc_id = var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["94.196.35.159/32"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vending-machine-bastion-sg"
  }
}

resource "aws_security_group" "private_ec2" {
  vpc_id = var.vpc_id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "vending-machine-private-ec2-sg"
  }
}

resource "aws_instance" "private_ec2" {
  ami                    = "ami-0fc32db49bc3bfbb1"
  instance_type          = "t2.micro"
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private_ec2.id]
  key_name               = "APIGatewayServer"
  tags = {
    Name = "vending-machine-private-ec2"
  }
}