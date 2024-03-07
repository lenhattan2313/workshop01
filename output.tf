output "alb_id" {
  value = aws_lb.alb.dns_name
}

output "zone_name_servers" {
  value       = aws_route53_zone.main.name_servers
  description = "Route53 DNS Zone Name Servers"
}