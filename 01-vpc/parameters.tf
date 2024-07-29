resource "aws_ssm_parameter" "vpc_info" {
  name  = "/${var.project_name}/${var.environment}/vpc_id"
  type  = "String" # this String is AWS notation
  value = module.vpc_test.vpc_id # this vpc_id can only be used when the module has this value as output in it
}

#terraform list(string) format ---> ["id1","id2"]
#aws SSM format: StringList format --> "id1","id2"
#using join, we're converting list to stringlist
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/public_subnet_ids"
  type  = "StringList" # this String is AWS notation
  value = join(",",module.vpc_test.public_subnet_ids) # this vpc_id can only be used when the module has this value as output in it
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project_name}/${var.environment}/private_subnet_ids"
  type  = "StringList" # this String is AWS notation
  value = join("," ,module.vpc_test.private_subnet_ids) # this vpc_id can only be used when the module has this value as output in it
}

resource "aws_ssm_parameter" "db_subnet_group_name" {
  name  = "/${var.project_name}/${var.environment}/db_subnet_group_name"
  type  = "StringList" # this String is AWS notation
  value = module.vpc_test.database_subnet_group_name
}

