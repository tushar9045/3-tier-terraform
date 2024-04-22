resource "aws_launch_template" "template" {
#  security_group_names = var.security_group_names
  vpc_security_group_ids = var.lt-sg
  image_id        = var.ami
  instance_type   = var.instance_type
  key_name = var.key-name
  
  # user_data = base64encode(<<-EOF
  #   #!/bin/bash
  #   sudo apt update
  #   sudo apt install -y nginx php-fpm php-mysql unzip
  #   sudo wget -O /tmp/latest.zip https://wordpress.org/latest.zip
  #   sudo unzip /tmp/latest.zip -d /tmp
  #   sudo mv /tmp/wordpress /var/www/html
  #   sudo rm -f /etc/nginx/sites-enabled/default
  #   sudo cat > /etc/nginx/sites-enabled/wp.conf << 'CONFIG'
  #   server {
  #       listen 80 default_server;
  #       listen [::]:80 default_server;
  #       root /var/www/html/wordpress;
  #       index index.php index.html index.htm index.nginx-debian.html;
  #       server_name _;
  #       location / {
  #           try_files $uri $uri/ =404;
  #       }
  #       location ~ \.php$ {
  #           include snippets/fastcgi-php.conf;
  #           fastcgi_pass unix:/run/php/php8.1-fpm.sock;
  #       }
    
  #   CONFIG
    

  #   sudo nginx -s reload
  #   sudo service php8.1-fpm reload
  # EOF
  # )
  

}
  

 resource "aws_autoscaling_group" "asg" {
  name_prefix = var.test-asg
  health_check_type = "ELB"
  health_check_grace_period = "300"
  target_group_arns = var.target_group_arns
  launch_template {
    id = aws_launch_template.template.id
  }
   desired_capacity = var.desired_capacity
   max_size = var.max_size
   min_size = var.min_size
   vpc_zone_identifier = var.vpc_zone_identifier
 }




  # resource "aws_autoscaling_attachment" "example" {
  #   autoscaling_group_name = aws_autoscaling_group.asg.id
  #   elb = var.elb-id
  #   lb_target_group_arn = var.tgt-arn
  # }



  resource "aws_autoscaling_policy" "example" {
  autoscaling_group_name = aws_autoscaling_group.asg.name
  name                   = "asg-policy"
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
    }
      target_value = 40
}
}