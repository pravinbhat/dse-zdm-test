output "origin_vpc_id" {
  description = "IDs of the Origin VPC"
  value       = aws_vpc.vpc_dse_zdm_test.id
}

output "origin_route_table_ids" {
  description = "Route tables of the Origin environment that must be opened up for communication with the Cloudgate infrastructure"
  value       = [aws_route_table.rt_dse_core_zdm_test.id, aws_route_table.rt_zdm_proxy_zdm_test.id, aws_route_table.rt_dse_olap_zdm_test.id]
}

output "default_security_group_id" {
  description = "Default security group of the Cloudgate VPC"
  value       = aws_vpc.vpc_dse_zdm_test.default_security_group_id
}

output "cloudgate_public_subnet_id" {
  description = "ID of the public subnet in the Cloudgate VPC"
  value       = aws_subnet.sn_zdm_proxy_zdm_test.id
}

output "public_subnet_route_table_id" {
  description = "ID of the route table associated with the public subnet where the monitoring instance will live"
  value       = aws_route_table.rt_zdm_proxy_zdm_test.id
}

output "public_instance_sg_id" {
  description = "ID of the security group to be used for public instances"
  value       = aws_security_group.sg_dse_zdm_test_proxy.id
}

output "proxy_instance_ids" {
  description = "IDs of the EC2 proxy instances"
  value       = aws_instance.zdm_proxy_dc1.*.id
}

output "proxy_instance_names" {
  description = "Names of the EC2 proxy instances"
  value       = aws_instance.zdm_proxy_dc1.*.tags.Name
}

output "proxy_instance_private_ips" {
  description = "Private IP of the EC2 proxy instances"
  value       = aws_instance.zdm_proxy_dc1.*.private_ip
}

output "monitoring_instance_public_ip" {
  description = "Public IP of the EC2 monitoring instance"
  value       = aws_instance.zdm_proxy_monitoring_dc1.public_ip
}

output "monitoring_instance_private_ip" {
  description = "Private IP of the EC2 monitoring instance"
  value       = aws_instance.zdm_proxy_monitoring_dc1.private_ip
}

output "public_key" {
  value = aws_key_pair.dse-zdm-test-sshkey.public_key
}
