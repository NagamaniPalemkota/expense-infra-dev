data "aws_ssm_parameter" "backend_sg_id" {
    name = "/${var.project_name}/${var.environment}/backend_sg_id"
}

data "aws_ssm_parameter" "private_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "vpc_id" {
    name = "/${var.project_name}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "app_alb_listener_arn" {
  name = "/${var.project_name}/${var.environment}/app_alb_listener_arn"
}

data "aws_ami" "ami_info" {
    most_recent = true
    owners = ["973714476881"]

    filter {
      name = "name" #asking to filter with its name here
      values =["RHEL-9-DevOps-Practice"] #mentioning with the name value of the ami queried
    }
    filter {
      name = "root-device-type"
      values = ["ebs"] #though the value is shown as EBS in aws, terraform accepts and caompares with 'ebs' while querying.
    } 
    
}