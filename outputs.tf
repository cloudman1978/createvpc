output "vpc_id" {
  description = "ID du VPC"
  value       = aws_vpc.main.id
}

output "public_subnets" {
  description = "Subnets publics"
  value       = [for s in aws_subnet.public : s.id]
}

output "private_subnets" {
  description = "Subnets privés"
  value       = [for s in aws_subnet.private : s.id]
}

output "nat_gateway_ip" {
  description = "IP publique de la NAT Gateway"
  value       = aws_eip.nat.public_ip
}
