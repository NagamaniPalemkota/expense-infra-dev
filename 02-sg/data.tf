data "aws_ssm_parameter" "ssm_vpc_info" {
    name = "/${var.project_name}/${var.environment}/vpc_id"
}