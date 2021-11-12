#security group of rds"

resource "aws_security_group" "rdssg" {
  name        = "rdssg"
  description = "Allow application and Admin traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress = [
  {
      description      = "allow application and Admin traffic"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = ["${aws_security_group.bastionsg.id}"]
      self = false
    },

  {
      description      = "allow application and Admin traffic"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = ["${aws_security_group.tomcatsg.id}"]
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
    Name = "${var.envname}-rdssg"
  }
}