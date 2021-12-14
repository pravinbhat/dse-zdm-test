#
# Security group rules:
# - open opscenter-agent ports
#
resource "aws_security_group" "sg_dse_zdm_test_internal_only" {
  name   = "sg_dse_zdm_test_internal_only"
  vpc_id = aws_vpc.vpc_dse_zdm_test.id

  tags = {
    Name        = "${var.tag_identifier}-sg_dse_zdm_test_internal_only"
    Environment = var.env
  }
}

# 
# Security group rules:
# - open SSH port (22) from anywhere
#
resource "aws_security_group" "sg_dse_zdm_test_ssh" {
  name   = "sg_dse_zdm_test_ssh"
  vpc_id = aws_vpc.vpc_dse_zdm_test.id

  tags = {
    Name        = "${var.tag_identifier}-sg_dse_zdm_test_ssh"
    Environment = var.env
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "sg_dse_zdm_test_proxy" {
  name   = "sg_dse_zdm_test_proxy"
  vpc_id = aws_vpc.vpc_dse_zdm_test.id

  # Allow ssh connection from the public subnet (i.e. monitoring instance only)
  ingress {
    cidr_blocks = [var.vpc_cidr_str_zdm_proxy]
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  // Grafana UI
  ingress {
    cidr_blocks = var.whitelisted_inbound_ip_ranges
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
  }
  // Prometheus UI
  ingress {
    cidr_blocks = var.whitelisted_inbound_ip_ranges
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
  }

  # Allow Prometheus to pull proxy metrics
  ingress {
    cidr_blocks = [var.vpc_cidr_str_zdm_proxy]
    from_port   = 14001
    to_port     = 14001
    protocol    = "tcp"
  }

  # Allow Prometheus to pull OS node metrics
  ingress {
    cidr_blocks = [var.vpc_cidr_str_zdm_proxy]
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.whitelisted_outbound_ip_ranges
  }

  tags = {
    Name = "sg_dse_zdm_test_proxy"
  }
}

#
# Security group rules:
# - Ports required for proper DSE function
#
resource "aws_security_group" "sg_dse_zdm_test_node" {
  name   = "sg_dse_zdm_test_node"
  vpc_id = aws_vpc.vpc_dse_zdm_test.id

  tags = {
    Name        = "${var.tag_identifier}-sg_dse_zdm_test_node"
    Environment = var.env
  }

  # Outbound: allow everything to everywhere
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }


  # DSE inter-node cluster communication port
  # - 7000: No SSL
  # - 7001: With SSL
  ingress {
    from_port       = 7000
    to_port         = 7001
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }

  # JMX monitoring port
  ingress {
    from_port       = 7199
    to_port         = 7199
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }

  # Port for inter-node messaging service
  ingress {
    from_port       = 8609
    to_port         = 8609
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }

  # Native transport port
  ingress {
    from_port       = 9042
    to_port         = 9042
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }

  # Rule added to enable the Cloudgate proxy to connect to the DSE nodes over VPC peering
  # Native transport port
  ingress {
    from_port   = 9042
    to_port     = 9042
    protocol    = "tcp"
    cidr_blocks = ["172.18.0.0/16"]
  }

  # Native transport port, with SSL
  ingress {
    from_port       = 9142
    to_port         = 9142
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }

  # Rule added to enable the Cloudgate proxy to connect to the DSE nodes over VPC peering
  # Native transport port, with SSL
  ingress {
    from_port   = 9142
    to_port     = 9142
    protocol    = "tcp"
    cidr_blocks = ["172.18.0.0/16"]
  }

  # Client (Thrift) port
  ingress {
    from_port       = 9160
    to_port         = 9160
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_dse_zdm_test_internal_only.id]
  }

}