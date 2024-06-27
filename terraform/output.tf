output "instance_ips" {
  description = "The public IPs of the created instances."
  value       = aws_instance.k6_instance.*.public_ip
}
