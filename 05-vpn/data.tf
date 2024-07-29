data "aws_ssm_parameter" "vpn_sg_id" {
    name = "/${var.project_name}/${var.environment}/vpn_sg_id"
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "/${var.project_name}/${var.environment}/public_subnet_ids"
}

data "aws_ami" "ami_info" {
    most_recent = true
    owners = ["679593333241"]

    filter {
      name = "name" #asking to filter with its name here
      values =["OpenVPN Access Server Community Image-fe8020db-5343-4c43-9e65-5ed4a825c931"] #mentioning with the name value of the ami queried
    }
    filter {
      name = "root-device-type"
      values = ["ebs"] #though the value is shown as EBS in aws, terraform accepts and caompares with 'ebs' while querying.
    } 
    
}