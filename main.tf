resource "aws_security_group" "web" {
  name        = "vpc_web"
  description = "Allow incoming HTTP connections."

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.default.id

  tags = {
    Name = "WebServerSG"
  }
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon-linux-2.id
  availability_zone           = "us-east-1a"
  instance_type               = "t2.micro"
  key_name                    = var.aws_key_name
  vpc_security_group_ids      = [aws_security_group.web.id]
  subnet_id                   = aws_subnet.us-east-1a-private.id
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = file("user-data.sh")
  tags                        = { Name = "Webserver-private" }
}
output "web_private_ip" {
  value = aws_instance.web.private_ip
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  vpc      = true
}