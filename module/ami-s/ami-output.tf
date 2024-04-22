output "ami-s-id" {
  
  value = {for k , v in aws_instance.name: k =>v.id}
}





output "created_ami_id" {
  value = aws_ami_from_instance.example.id
}
