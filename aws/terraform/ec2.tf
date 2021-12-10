#
# EC2 instances for DSE core cluster, DC1
# 
resource "aws_instance" "dse_core_dc1" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, var.dse_core_dc1_type)
  root_block_device {
    volume_size = 100
  }
  count     = lookup(var.instance_count, var.dse_core_dc1_type)
  key_name  = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id = aws_subnet.sn_dse_core_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id,
    aws_security_group.sg_dse_zdm_test_node.id
  ]

  tags = {
    Name        = "${var.tag_identifier}-${var.dse_core_dc1_type}-${count.index}"
    Environment = var.env
  }

}

#
# EC2 instances for ZDM Proxy cluster, DC1
# 
/*
resource "aws_instance" "zdm_proxy_dc1" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, var.zdm_proxy_dc1_type)
  count         = lookup(var.instance_count, var.zdm_proxy_dc1_type)
  key_name      = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id     = aws_subnet.sn_zdm_proxy_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id
  ]

  tags = {
    Name        = "${var.tag_identifier}-${var.zdm_proxy_dc1_type}-${count.index}"
    Environment = var.env
  }

}
*/

#
# EC2 instances for DSE olap cluster, DC1
#
resource "aws_instance" "dse_olap_dc1" {
  ami           = var.ami_id
  instance_type = lookup(var.instance_type, var.dse_olap_dc1_type)
  root_block_device {
    volume_size = 100
  }
  count     = lookup(var.instance_count, var.dse_olap_dc1_type)
  key_name  = aws_key_pair.dse-zdm-test-sshkey.key_name
  subnet_id = aws_subnet.sn_dse_olap_zdm_test.id

  vpc_security_group_ids = [
    aws_security_group.sg_dse_zdm_test_internal_only.id,
    aws_security_group.sg_dse_zdm_test_ssh.id,
    aws_security_group.sg_dse_zdm_test_node.id
  ]

  tags = {
    Name        = "${var.tag_identifier}-${var.dse_olap_dc1_type}-${count.index}"
    Environment = var.env
  }

}
