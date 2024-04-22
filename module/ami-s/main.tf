
resource "aws_instance" "name" {
    instance_type = "t2.micro"
    ami = "ami-0d4eb6147723d4645"
    for_each = var.ami-server
  subnet_id = each.value["subnet_id"]
  key_name = "TOK"
  vpc_security_group_ids = var.sg-ami
  connection {
 type        = "ssh"
  user        = "ubuntu"
   private_key =  file("${path.module}/TOK.pem")
   host  = self.public_ip
   }


  provisioner "remote-exec" {
    inline = [
      
      "sudo sed -i   's/tushar/${var.db_user}/' /var/www/html/wordpress/wp-config.php",
      "sudo sed -i 's/tushar123/${var.db_password}/' /var/www/html/wordpress/wp-config.php",
      "sudo sed -i 's/database-1.cjuiuia8m9pg.ap-northeast-1.rds.amazonaws.com/${var.db_host}/' /var/www/html/wordpress/wp-config.php",
    ]
  }


}

resource "aws_ami_from_instance" "example" {
  name               = "terraform-example"
  source_instance_id = var.created-instance-id
}