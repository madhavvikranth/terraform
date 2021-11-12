#security group of ALB"

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow internet traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress = [
  {
      description      = "allow internet traffic"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]
  

  egress = [
  {
      description      = "outbound traffic"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids = []
      security_groups = []
      self = false
    }
  ]


  tags = {
    Name = "${var.envname}-albsg"
  }
}