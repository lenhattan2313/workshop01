//1. create VPC
resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr_block
  tags = {
    Name = "VPC HCM"
  }
}

//2. create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW"
  }
}

//3. create 2 public subnets in ap-southeast-1a,1b
resource "aws_subnet" "public_subnet" {
  count      = length(var.public_subnet_cidr_blocks)
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index % length(var.availability_zones)]
  
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

//4. create route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public route table"
  }
}

//5. associate public subnet with public route table
resource "aws_route_table_association" "public_associate" {
  count = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

