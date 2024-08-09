module "db" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for mysql db instance"
    common_tags = var.common_tags
    sg_name = "db"
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value

}

module "backend" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for backend instance"
    common_tags = var.common_tags
    sg_name = "backend"
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value

}
module "frontend" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for frontend instance"
    common_tags = var.common_tags
    sg_name = "frontend"
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value

}
module "bastion" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for bastion instance"
    common_tags = var.common_tags
    sg_name = "bastion"
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value

}
module "app_alb" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for app-alb instance"
    common_tags = var.common_tags
    sg_name = "app-alb"
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value

}

module "web_alb" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for web-alb instance"
    common_tags = var.common_tags
    sg_name = "web-alb"
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value

}

module "vpn" {
    source = "../../terraform-aws-securitygroup"
    project_name = var.project_name
    environment = var.environment
    description = "SG for vpn instance"
    common_tags = var.common_tags
    vpc_id = data.aws_ssm_parameter.ssm_vpc_info.value
    sg_name = "vpn"
    inbound_rules = var.vpn_sg_rules
}

#inbound security group rules allowing traffic to db from backend
resource "aws_security_group_rule" "db_backend" {
    type = "ingress"
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    security_group_id = module.db.sg_id
    source_security_group_id = module.backend.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to db from bastion
resource "aws_security_group_rule" "db_bastion" {
    type = "ingress"
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    security_group_id = module.db.sg_id
    source_security_group_id = module.bastion.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to db from vpn
resource "aws_security_group_rule" "db_vpn" {
    type = "ingress"
    protocol = "tcp"
    from_port = 3306
    to_port = 3306
    security_group_id = module.db.sg_id
    source_security_group_id = module.vpn.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to backend from app_alb
resource "aws_security_group_rule" "backend_app_alb" {
    type = "ingress"
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    security_group_id = module.backend.sg_id
    source_security_group_id = module.app_alb.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to backend from bastion
resource "aws_security_group_rule" "backend_bastion" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_group_id = module.backend.sg_id
    source_security_group_id = module.bastion.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to backend from vpn_ssh
resource "aws_security_group_rule" "backend_vpn_ssh" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_group_id = module.backend.sg_id
    source_security_group_id = module.vpn.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to backend from vpn
resource "aws_security_group_rule" "backend_vpn_http" {
    type = "ingress"
    protocol = "tcp"
    from_port = 8080
    to_port = 8080
    security_group_id = module.backend.sg_id
    source_security_group_id = module.vpn.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to backend from jenkins, nexus created in default vpc(as part of CICD)
resource "aws_security_group_rule" "backend_tools" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_group_id = module.backend.sg_id
    cidr_blocks = ["172.31.0.0/16"]  # source is from where we're getting traffic
}

# not required when connecting from web_alb & vpn
# inbound security group rules allowing traffic to frontend from public
# resource "aws_security_group_rule" "frontend_public" {
#     type = "ingress"
#     protocol = "tcp"
#     from_port = 80
#     to_port = 80
#     security_group_id = module.frontend.sg_id
#     cidr_blocks = ["0.0.0.0/0"] # it is from where we're getting traffic
# }

#inbound security group rules allowing traffic to frontend from bastion
resource "aws_security_group_rule" "frontend_bastion" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_group_id = module.frontend.sg_id
    source_security_group_id = module.bastion.sg_id  # it is from where we're getting traffic
}

#inbound security group rules allowing traffic to frontend from vpn
resource "aws_security_group_rule" "frontend_vpn" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_group_id = module.frontend.sg_id
    source_security_group_id = module.vpn.sg_id  # it is from where we're getting traffic
}

#inbound security group rules allowing traffic to frontend from web_alb
resource "aws_security_group_rule" "frontend_web_alb" {
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_group_id = module.frontend.sg_id
    source_security_group_id = module.web_alb.sg_id # it is from where we're getting traffic
}

#inbound security group rules allowing traffic to bastion from public
resource "aws_security_group_rule" "bastion_public" {
    type = "ingress"
    protocol = "tcp"
    from_port = 22
    to_port = 22
    security_group_id = module.bastion.sg_id
    cidr_blocks = ["0.0.0.0/0"]  # it is from where we're getting traffic
}
#inbound security group rules allowing traffic to app-alb from vpn
resource "aws_security_group_rule" "app_alb_vpn" {
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_group_id = module.app_alb.sg_id
    source_security_group_id = module.vpn.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to app-alb from frontend
resource "aws_security_group_rule" "app_alb_frontend" {
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_group_id = module.app_alb.sg_id
    source_security_group_id = module.frontend.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to app-alb from bastion
resource "aws_security_group_rule" "app_alb_bastion" {
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_group_id = module.app_alb.sg_id
    source_security_group_id = module.bastion.sg_id # source is from where we're getting traffic
}

#inbound security group rules allowing traffic to web_alb from public
resource "aws_security_group_rule" "web_alb_public" {
    type = "ingress"
    protocol = "tcp"
    from_port = 80
    to_port = 80
    security_group_id = module.web_alb.sg_id
    cidr_blocks = ["0.0.0.0/0"] # it is from where we're getting traffic
}

#inbound security group rules allowing secured traffic to web_alb from public
resource "aws_security_group_rule" "web_alb_public_https" {
    type = "ingress"
    protocol = "tcp"
    from_port = 443
    to_port = 443
    security_group_id = module.web_alb.sg_id
    cidr_blocks = ["0.0.0.0/0"] # it is from where we're getting traffic
}


