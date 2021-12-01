provider "aws" {
  region = var.region
}

# 
# SSH key used to access the EC2 instances
#
resource "aws_key_pair" "dse-zdm-test-sshkey" {
  key_name   = format("%s-%s", var.tag_identifier, var.keyname)
  public_key = file(format("%s/%s.pub", var.ssh_key_localpath, var.ssh_key_filename))

  tags = {
    Name        = "${var.tag_identifier}-dse-zdm-test-sshkey"
    Environment = var.env
  }
}