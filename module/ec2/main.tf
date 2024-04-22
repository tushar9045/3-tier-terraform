# resource "aws_instance" "ec2-server" {
#    for_each = var.ec2-server
#    instance_type = var.instance_type
#    ami = var.ami
#    subnet_id = each.value["subnet-id"]
#    user_data = <<-EOF
#      !/bin/ba
#       sudo apt update -y
#       sudo apt install nginx -y
#      sudo systemctl start nginx
#       sudo systemctl enable nginx
#     EOF
   
#    tags = {
#      name = "app-server"
#  }
#   }


# # #  resource "aws_instance" "private-server" {
# # #   for_each = var.pvt-sub
# # #   instance_type = var.instance_type
# # #   ami = var.ami
# # #   subnet_id = each.value["subnet-id"]
   
# # #  }