#create VPC
resource "aws_vpc" "petclinic" {
  cidr_block           = var.cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = var.envname
  }
}

#Public subnet

resource "aws_subnet" "pubsub" {
  count                   = length(var.azs)
  vpc_id                  = aws_vpc.petclinic.id
  cidr_block              = element(var.cidr_publicsubnet, count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = "true"

  tags = {
    Name = "${var.envname}-pubsubnet-${count.index + 1}"
  }
}

#private subnet

resource "aws_subnet" "privatesub" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.petclinic.id
  cidr_block        = element(var.cidr_privatesubnet, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.envname}-privatesubnet-${count.index + 1}"
  }
}

#Data subnet

resource "aws_subnet" "datasub" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.petclinic.id
  cidr_block        = element(var.cidr_datasubnet, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "${var.envname}-datasubnet-${count.index + 1}"
  }
}

#Internet GW

resource "aws_internet_gateway" "Internetgateway" {
  vpc_id = aws_vpc.petclinic.id

  tags = {
    Name = "${var.envname}-intgw"
  }
}

#Elastic IP

resource "aws_eip" "elasticip" {
  # instance = aws_instance.web.id
  vpc      = true

  tags = {
    Name = "${var.envname}-elasticip"
  }
}

#Natgateway

resource "aws_nat_gateway" "Natgateway" {
  allocation_id = aws_eip.elasticip.id
  subnet_id     = aws_subnet.pubsub[0].id

  tags = {
    Name = "${var.envname}-natgw"
  }
}

#route tables

resource "aws_route_table" "publicroute" {
  vpc_id = aws_vpc.petclinic.id

  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.Internetgateway.id
    }

  tags = {
    Name = "${var.envname}-publicroute"
  }
}

resource "aws_route_table" "privateroute" {
  vpc_id = aws_vpc.petclinic.id

  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.Natgateway.id
    }

  tags = {
    Name = "${var.envname}-privateroute"
  }
}

resource "aws_route_table" "dataroute" {
  vpc_id = aws_vpc.petclinic.id

  route  {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.Natgateway.id
    }

  tags = {
    Name = "${var.envname}-dataroute"
  }
}

#subnet association

 resource "aws_route_table_association" "pubsubassociation" {
  count = length (var.azs)
  subnet_id      = element (aws_subnet.pubsub.*.id,count.index)
  route_table_id = aws_route_table.publicroute.id
}

resource "aws_route_table_association" "prisubassociation" {
  count = length (var.azs)
  subnet_id      = element (aws_subnet.privatesub.*.id,count.index)
  route_table_id = aws_route_table.privateroute.id
}

resource "aws_route_table_association" "datasubassociation" {
  count = length (var.azs)
  subnet_id      = element (aws_subnet.datasub.*.id,count.index)
  route_table_id = aws_route_table.dataroute.id
}
