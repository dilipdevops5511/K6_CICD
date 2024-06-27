output "k6_instance_ips" {
  description = "The public IPs of the created k6 instances."
  value       = aws_instance.k6_instance.*.public_ip
}
