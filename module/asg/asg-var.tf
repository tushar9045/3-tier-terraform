variable "ami" {
  
}
variable "instance_type" {
  
}
variable "key-name" {
  
}
variable "desired_capacity" {
  
}
variable "max_size" {
  
}
variable "min_size" {
  
}
variable "asg-zones" {
  type = list(string)
}
# variable "elb-id" {
  
# }
# variable "tgt-arn" {
  
# }
# variable "security_group_names" {
  
# }
variable "lt-sg" {
    type = list(string)
  
}
variable "test-asg" {

  
}
variable "vpc_zone_identifier" {
    type = list(string)

  
}
variable "target_group_arns" {
  
  type = list(string)
}