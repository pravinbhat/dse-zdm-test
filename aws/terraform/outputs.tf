output "origin_vpc_id" {
  description = "IDs of the Origin VPC"
  value       = aws_vpc.vpc_dse_zdm_test.id
}

output "origin_route_table_ids" {
  description = "Route tables of the Origin environment that must be opened up for communication with the Cloudgate infrastructure"
  value       = [aws_route_table.rt_dse_core_zdm_test.id, aws_route_table.rt_zdm_proxy_zdm_test.id, aws_route_table.rt_dse_olap_zdm_test.id]
}