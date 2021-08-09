######################################################
# Create a custom VPC. 
#
resource "aws_vpc" "vpc_dse" {
   cidr_block           = var.vpc_cidr_str_vpc
   enable_dns_hostnames = true

   tags = {
     Name = "${var.tag_identifier}-vpc_dse"  
   }
}


######################################################
# Create an internet gateway for public/internet access
#
resource "aws_internet_gateway" "ig_dse" {
   vpc_id                   = aws_vpc.vpc_dse.id

   tags = {
     Name = "${var.tag_identifier}-ig_dse"  
   }
}

######################################################
# Create a custom route table for public/internet access
#
resource "aws_route_table" "rt_dse" {
    vpc_id                  = aws_vpc.vpc_dse.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig_dse.id
    }

    tags = {
        Name = "${var.tag_identifier}-rt_dse"
    }
}


######################################################
# Create subnets
#

# Subnet for DSE core - application cluster
resource "aws_subnet" "sn_dse_cassapp" {    
    vpc_id                  = aws_vpc.vpc_dse.id
    cidr_block              = var.vpc_cidr_str_cassapp
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.tag_identifier}-sn_dse_cassapp"
    }
}
resource "aws_route_table_association" "rt_assoc_sn_dse_cassapp" {
    route_table_id          = aws_route_table.rt_dse.id
    subnet_id               = aws_subnet.sn_dse_cassapp.id
}

# Subnet for DSE core - application cluster
/*
resource "aws_subnet" "sn_dse_solrspark" {    
    vpc_id                  = aws_vpc.vpc_dse.id
    cidr_block              = var.vpc_cidr_str_solrspark
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.tag_identifier}-sn_dse_solrspark"
    }
}
resource "aws_route_table_association" "rt_assoc_sn_dse_solrspark" {
    route_table_id          = aws_route_table.rt_dse.id
    subnet_id               = aws_subnet.sn_dse_solrspark.id
}
*/