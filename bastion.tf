#Security group of Bastion

resource "aws_security_group" "bastionsg" {
  name        = "bastionsg"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.petclinic.id

  ingress = [
  {
      description      = "allow ssh"
      from_port        = 22
      to_port          = 22
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
    Name = "${var.envname}-bastionsg"
  }
}

#EC2 instance

#Key Pair
resource "aws_key_pair" "pem" {
  key_name   = "petclinic_pem"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCiOMMzN18BmJQhjk0nhwhRw8iwdDV5ujBwXvpKY2S906Xd7uYzT/igq61dy6xp9RdiSXAGiImnYVZMeTc+cpvOGORuvr85XNooZAR4Ivxy2XZblBJj9BrTdsiSv2Mn8TPZdUMCE6wQWbO64yXaeUDJhFrcqQs8TuRIzixcqV5INWUSmxbSDAMEbZmPAtjVYjh84wD1gX70bb1JJv8CRTq2T5KxrivKOE2p3IoWgKjyN14rp5Q1zQPIKE7jLae/e+vUOCoTy+Wk3sS7EfUuxja8d2LO5S7QxNOfKSZgdkqWUqhiMBWURm8evEv8u77ftgWwe4qhDMNV0G2LUrsOv8ZF4My+G0cz/FRuzyV8NHQ2GSaeZr1ctRMJLO9IquZlZZrB7fz4JpoGiti04mvqQEABdr9e1qSR5/hbws+bWsHxoyAnaQ7i4pQGeM7hqvhTEusY6idTbrd8WFi6yL19oyuueUmjN/jGdLb2ooWg8eBPoMe2czVOOzc9ARz2qQ+0MRk= Vikranth@Vikranth"
}


resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = ["${aws_security_group.bastionsg.id}"]
  key_name = "${aws_key_pair.pem.id}"
  subnet_id   = aws_subnet.pubsub[0].id

  tags = {
    Name = "${var.envname}-bastion"
  }
}