output "master_ip" {
  value = aws_spot_instance_request.master.public_ip
}

output "worker_ips" {
  value = aws_spot_instance_request.worker[*].public_ip
}

output "ssh_master" {
  value = "ssh -i ~/.ssh/key.pem ubuntu@${aws_spot_instance_request.master.public_ip}"
}
