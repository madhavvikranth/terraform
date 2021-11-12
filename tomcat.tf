#security group of tomcat"

resource "aws_security_group" "tomcatsg" {
  name        = "tomcatsg"
  description = "Allow ALB and Admin traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress = [
  {
      description      = "allow ALB and Admin traffic"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = ["${aws_security_group.bastionsg.id}"]
      self = false
    },

  {
      description      = "allow ALB and Admin traffic"
      from_port        = 8080
      to_port          = 8080
      protocol         = "tcp"
      cidr_blocks      = []
      ipv6_cidr_blocks = []
      prefix_list_ids = []
      security_groups = ["${aws_security_group.alb.id}"]
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
    Name = "${var.envname}-tomcatsg"
  }
}

#userdata

data "template_file" "tomcat_install" {
  template = "${file("tomcat_install.sh")}"
}

#EC2

resource "aws_instance" "tomcat" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.tomcatsg.id}"]
  key_name = "${aws_key_pair.pem.id}"
  subnet_id   = aws_subnet.privatesub[0].id
  user_data = data.template_file.tomcat_install.rendered

  tags = {
    Name = "${var.envname}-tomcat"
  }
}