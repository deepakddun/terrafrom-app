provider "aws" {
  region = "us-east-2"
}

terraform {
  required_version = " > 0.12"
}

resource "aws_vpc" "aws-vpc-terraform-custom" {
  cidr_block = "10.200.0.0/16"
  tags = {
      vpcType = "custom-vpc-terraform"
      }

}

resource "aws_subnet" "aws-subnet-public-subnet" {
  cidr_block = "10.200.0.0/24"
  vpc_id = aws_vpc.aws-vpc-terraform-custom.id
  map_public_ip_on_launch = "true"
  tags = {
    SubnetType = "terraform-public-subnet"
  }
}

resource "aws_subnet" "aws-subnet-private-subnet" {
  cidr_block = "10.200.1.0/24"
  vpc_id = aws_vpc.aws-vpc-terraform-custom.id
  tags = {
    SubnetType = "terraform-private-subnet"
  }
}

resource "aws_internet_gateway" "terraform-internet-gateway" {
  vpc_id = aws_vpc.aws-vpc-terraform-custom.id
  tags = {
    gateway = "terraform-gateway"
  }
}

resource "aws_eip" "lb" {
    vpc      = true
    depends_on = [aws_internet_gateway.terraform-internet-gateway]
    tags = {
      CreatedBy ="terraform-elasticIP"
    }
}

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.aws-subnet-public-subnet.id

  tags = {
    CreatedBy = "terraform-nat-gateway"
  }
}

resource "aws_route_table" "terraform-route-table-public" {
  vpc_id = aws_vpc.aws-vpc-terraform-custom.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform-internet-gateway.id
  }
  tags = {
    routTable = "terraform-public-routetable"
  }
}




resource "aws_route_table" "terraform-route-table-private" {
  vpc_id = aws_vpc.aws-vpc-terraform-custom.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id
  }
  tags = {
    routetable ="terraform-private-routetable"
  }
}

resource "aws_route_table_association" "terraform-private-subnet-route-assoc" {
   subnet_id = aws_subnet.aws-subnet-private-subnet.id
   route_table_id = aws_route_table.terraform-route-table-private.id
}

resource "aws_route_table_association" "terraform-public-subnet-route-assoc" {
  route_table_id = aws_route_table.terraform-route-table-public.id
  subnet_id = aws_subnet.aws-subnet-public-subnet.id
}


resource "aws_redshift_subnet_group" "redshift_subnet_group_name" {
  name = "terraform-redshift-subnet-group"
  subnet_ids = [aws_subnet.aws-subnet-private-subnet.id]
  tags = {
    CreatedBy = "Terraform",
    For = "Redshift-Cluster"
  }
}

terraform {
  backend "s3" {
   bucket = "nyeisterraformstatedata2"
    key = "vpc/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "terraform-up-and-running-locks-2"
    encrypt = true
  }
}

output "vpc_id" {
  value = aws_vpc.aws-vpc-terraform-custom.id
}

output "vpc_arn" {
  value = aws_vpc.aws-vpc-terraform-custom.arn
}

output "private_subnet_id" {
  value = aws_subnet.aws-subnet-private-subnet.id
}

output "public_subnet_id" {
  value = aws_subnet.aws-subnet-public-subnet.id
}

output "redshift_subnet_group_output"  {
  value = aws_redshift_subnet_group.redshift_subnet_group_name.name
}

output "redshift_subnet_group_id"  {
  value = aws_redshift_subnet_group.redshift_subnet_group_name.subnet_ids
}
