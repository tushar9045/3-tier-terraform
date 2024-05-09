terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "ap-northeast-1"
}
# terraform {
#   backend "s3" {
#     bucket = "yournamegrras"
#     key    = "terraform.tfstate"
#     region = "ap-northeast-1"
#     dynamodb_table = "terraform-2"

#   }
# }
module "vpc-1" {
  source = "./module/vpc"
  cidr   = "10.0.0.0/16"
  pub-sub = {
    pub-snet-1 = {
      a-z  = "ap-northeast-1a"
      cidr = "10.0.1.0/24"
    },
    pub-snet-2 = {
      a-z  = "ap-northeast-1d"
      cidr = "10.0.2.0/24"
    }
  }
  pvt-sub = {
    pvt-snet-1 = {
      a-z  = "ap-northeast-1a"
      cidr = "10.0.4.0/24"

    },
    pvt-snet-2 = {
      a-z  = "ap-northeast-1d"
      cidr = "10.0.5.0/24"
    }
  }

  ##### nat gw ####
  nat-gw = {
    net-1 = {
      allocation_id  = lookup(module.vpc-1.eip-id,"eip1", null )
      subnet_id = lookup(module.vpc-1.subnet-id,"pub-snet-1", null )
    },
    net-2 = {
     allocation_id = lookup(module.vpc-1.eip-id,"eip2", null )
     subnet_id =  lookup(module.vpc-1.subnet-id,"pub-snet-2", null )            
    }
  }
  eip = {
    eip1={

    }

    
    eip2={

    }
  }
  pvt-rt = {
    pvt-rt-1 ={
      gateway_id = lookup(module.vpc-1.nat-id, "net-1", null)
    }
    pvt-rt-2 ={
      gateway_id = lookup(module.vpc-1.nat-id, "net-2", null)
    }
  }
  pvt-rt-association = {
    association-1 ={
      route_table_id = lookup(module.vpc-1.rt-id,"pvt-rt-1",null)
      subnet_id = lookup(module.vpc-1.pvt-sub-id, "pvt-snet-1", null)

    }
     association-2 ={
      route_table_id = lookup(module.vpc-1.rt-id,"pvt-rt-2",null)
      subnet_id = lookup(module.vpc-1.pvt-sub-id, "pvt-snet-2", null)

    }
  }
  
  }





  
  

# module "ec2" {
#   source        = "./module/ec2"
#   instance_type = var.instance_type

#   ami           = var.ami
#   ec2-server = {
#     # server-1 = {
#     #   subnet-id = lookup(module.vpc-1.subnet-id, "pub-snet-1", null)
#     # }
#     server-2 = {
#       subnet-id = lookup(module.vpc-1.pvt-sub-id, "pvt-snet-1", null)
#     }
#     # server-3 = {
#     #   subnet-id = lookup(module.vpc-1.pvt-sub-id, "pub-snet-2", null)
#     # }
#     server-3 = {
#       subnet-id = lookup(module.vpc-1.pvt-sub-id, "pvt-snet-2", null)
#     }
#   }

# }

module "sg" {
  source = "./module/sg"
  v-id = module.vpc-1.vpc-id
  sg-details = {
    "lb-sg" = {
    
      name   = "lb-sg"
      ingress_rules = [
        # {
        #   from_port       = 22
        #   to_port         = 22
        #   protocol        = "tcp"
        #   cidr_blocks     = ["0.0.0.0/0"]
        #   security_groups = null
        # },
        {
          from_port       = 80
          to_port         = 80
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = null
        }
      ]
    }
  }

    }
  
  module "sg-2" {
    source = "./module/sg"
      v-id = module.vpc-1.vpc-id

    sg-details = {
  
    "web-sg" = {
      
      name   = "web-sg"
      ingress_rules = [
        {
          from_port       = 22
          to_port         = 22
          protocol        = "tcp"
          cidr_blocks     = null
          security_groups = [lookup(module.sg.sg-id , "lb-sg" , null)]
        },
        {
          from_port       = 80
          to_port         = 80
          protocol        = "tcp"
          cidr_blocks     = null
          security_groups = [lookup(module.sg.sg-id , "lb-sg", null)]
        }
      ]
    }
    "ami-sg" = {
     name   = "ami-sg"
      ingress_rules = [
        {
          from_port       = 22
          to_port         = 22
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
           security_groups = null
        },
        # {
        #   from_port       = 80
        #   to_port         = 80
        #   protocol        = "tcp"
        #   cidr_blocks     = ["0.0.0.0/0"]
        #   security_groups = null
        # }
      ]
    }
  }
  }


module "sg-3" {
  source = "./module/sg"
  v-id = module.vpc-1.vpc-id
    sg-details = {
      "rds-sg"= {
     
      name   = "rds-sg"
      ingress_rules = [
        {
          cidr_blocks     = null
          from_port       = 3306
          protocol        = "tcp"
          to_port         = 3306
          security_groups = [lookup(module.sg-2.sg-id ,"web-sg", null), lookup(module.sg-2.sg-id ,"ami-sg", null)]
 }

      ]
}
  
}
}
module "rds" {
  source = "./module/rds"
  allocated_storage = "20"
  engine = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  db_name = "db2"
  username = "admin" 
  password = "Tushar1234"
  rds-az = "ap-northeast-1a"
  sgrds = [lookup(module.sg-3.sg-id, "rds-sg", null)]
  subnt1 = lookup(module.vpc-1.pvt-sub-id, "pvt-snet-1", null)
  subnt2 = lookup(module.vpc-1.pvt-sub-id, "pvt-snet-2", null)
  
}
module "ami-server" {
  source = "./module/ami-s"
  ami-server = {
    g-server ={
      subnet_id = lookup(module.vpc-1.subnet-id, "pub-snet-1", null)
    }
  }
  db_name = "db2"
  db_user = "admin"
  db_password = "Tushar1234"
  db_host = module.rds.rds-endpoint
  sg-ami = [lookup(module.sg-2.sg-id, "ami-sg" ,null)]
  created-instance-id = lookup(module.ami-server.ami-s-id, "g-server", null)
}



module "alb" {
  source = "./module/alb"
  alb = {
    "alb-1" = {
      sg-id     = [lookup(module.sg.sg-id, "lb-sg", null)]
      subnet-id = [lookup(module.vpc-1.subnet-id, "pub-snet-1", null), lookup(module.vpc-1.subnet-id, "pub-snet-2", null)]
    }

  }
  vpc-id = module.vpc-1.vpc-id 
  arn =  lookup(module.alb.alb-arn, "alb-1", null)
  tg =  {
    "tg-1" = {
      port = 80
      protcol = "HTTP"
    }
  }
  tg-arn = lookup(module.alb.arn-tg, "tg-1", null)
}

module "asg" {
  source = "./module/asg"
  ami = module.ami-server.created_ami_id
  instance_type = "t2.micro"
  key-name = "TOK"
  lt-sg = [lookup(module.sg-2.sg-id, "web-sg", null)]

 

asg-zones = ["ap-northeast-1a", "ap-northeast-1d"]
desired_capacity = 2
max_size = 4
min_size = 1
# elb-id = lookup(module.alb.alb-id, "alb-1", null)
# tgt-arn = lookup(module.alb.arn-tg, "tg-1", null)
test-asg = "asg-3-tier"
vpc_zone_identifier = [lookup(module.vpc-1.pvt-sub-id, "pvt-snet-1", null) , lookup(module.vpc-1.pvt-sub-id, "pvt-snet-2" , null)]
  target_group_arns = [lookup(module.alb.arn-tg, "tg-1", null)]
}


output "rds-endpoint" {
  value = module.rds.rds-endpoint
  
}

output "lb-dns" {
value = lookup(module.alb.lb-dns, "alb-1", null).dns_name
  
}
