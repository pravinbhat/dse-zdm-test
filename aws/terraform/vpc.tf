######################################################
# Create a custom VPC. 
#
resource "aws_vpc" "vpc_dse_zdm_test" {
  cidr_block           = var.vpc_cidr_str_vpc
  enable_dns_hostnames = true

  tags = {
    Name = "${var.tag_identifier}-vpc_dse_zdm_test"
  }
}


######################################################
# Create an internet gateway for public/internet access
#
resource "aws_internet_gateway" "ig_dse_zdm_test" {
  vpc_id = aws_vpc.vpc_dse_zdm_test.id

  tags = {
    Name = "${var.tag_identifier}-ig_dse_zdm_test"
  }
}

######################################################
# Create a custom route table for the core cluster
#
resource "aws_route_table" "rt_dse_core_zdm_test" {
  vpc_id = aws_vpc.vpc_dse_zdm_test.id
  tags = {
    Name = "${var.tag_identifier}-rt_dse_core_zdm_test"
  }
}

resource "aws_route" "dse_core_to_igw_zdm_test" {
  route_table_id         = aws_route_table.rt_dse_core_zdm_test.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_dse_zdm_test.id
}

######################################################
# Create a custom route table for the ZDM Proxy
#
resource "aws_route_table" "rt_zdm_proxy_zdm_test" {
  vpc_id = aws_vpc.vpc_dse_zdm_test.id
  tags = {
    Name = "${var.tag_identifier}-rt_zdm_proxy_zdm_test"
  }
}

resource "aws_route" "zdm_proxy_to_igw_zdm_test" {
  route_table_id         = aws_route_table.rt_zdm_proxy_zdm_test.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_dse_zdm_test.id
}

######################################################
# Create a custom route table for the olap cluster
#
resource "aws_route_table" "rt_dse_olap_zdm_test" {
  vpc_id = aws_vpc.vpc_dse_zdm_test.id
  tags = {
    Name = "${var.tag_identifier}-rt_dse_olap_zdm_test"
  }
}

resource "aws_route" "dse_olap_to_igw_zdm_test" {
  route_table_id         = aws_route_table.rt_dse_olap_zdm_test.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig_dse_zdm_test.id
}

######################################################
# Create subnets
#

# Subnet for DSE core
resource "aws_subnet" "sn_dse_core_zdm_test" {
  vpc_id                  = aws_vpc.vpc_dse_zdm_test.id
  cidr_block              = var.vpc_cidr_str_core
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_identifier}-sn_dse_core_zdm_test"
  }
}
resource "aws_route_table_association" "rt_assoc_sn_dse_core_zdm_test" {
  route_table_id = aws_route_table.rt_dse_core_zdm_test.id
  subnet_id      = aws_subnet.sn_dse_core_zdm_test.id
}

# Subnet for ZDM Proxy
resource "aws_subnet" "sn_zdm_proxy_zdm_test" {
  vpc_id                  = aws_vpc.vpc_dse_zdm_test.id
  cidr_block              = var.vpc_cidr_str_zdm_proxy
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_identifier}-sn_zdm_proxy_zdm_test"
  }
}
resource "aws_route_table_association" "rt_assoc_sn_zdm_proxy_zdm_test" {
  route_table_id = aws_route_table.rt_zdm_proxy_zdm_test.id
  subnet_id      = aws_subnet.sn_zdm_proxy_zdm_test.id
}

# Subnet for DSE Alaytics/OLAP
resource "aws_subnet" "sn_dse_olap_zdm_test" {
  vpc_id                  = aws_vpc.vpc_dse_zdm_test.id
  cidr_block              = var.vpc_cidr_str_olap
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.tag_identifier}-sn_dse_olap_zdm_test"
  }
}
resource "aws_route_table_association" "rt_assoc_sn_dse_olap_zdm_test" {
  route_table_id = aws_route_table.rt_dse_olap_zdm_test.id
  subnet_id      = aws_subnet.sn_dse_olap_zdm_test.id
}