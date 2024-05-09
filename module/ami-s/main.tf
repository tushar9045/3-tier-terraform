
resource "aws_instance" "name" {
    instance_type = "t2.micro"
    ami = "ami-0eba6c58b7918d3a1"
    for_each = var.ami-server
  subnet_id = each.value["subnet_id"]
  key_name = "TOK"
  vpc_security_group_ids = var.sg-ami
    user_data = file("${path.module}/userdata.sh")      # "${file("userdata.sh")}"
  connection {
 type        = "ssh"
  user        = "ubuntu"
   private_key =  file("${path.module}/TOK.pem")
   host  = self.public_ip
   }
    provisioner "remote-exec" {
    inline =[
      "sleep 500",
      "ls /var/www/html/",
      "sudo cp /var/www/html/wordpress/wp-config-sample.php  /var/www/html/wordpress/wp-config.php",
      "sudo sed -i   's/database_name_here/${var.db_name}/' /var/www/html/wordpress/wp-config.php",
      "sudo sed -i   's/username_here/${var.db_user}/' /var/www/html/wordpress/wp-config.php",
      "sudo sed -i 's/password_here/${var.db_password}/' /var/www/html/wordpress/wp-config.php",
      "sudo sed -i 's/localhost/${var.db_host}/' /var/www/html/wordpress/wp-config.php",
     

    ]
  }


  
}

resource "aws_ami_from_instance" "example" {
  name               = "terraform-example" 
  source_instance_id = var.created-instance-id
}