module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${var.project_name}-${var.environment}"

  engine            = "mysql"
  engine_version    = "8.0" 
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "transactions"
  username = "root"
  port     = "3306"

  vpc_security_group_ids = [data.aws_ssm_parameter.db_sg_id.value] #provide db security group id from querying ssm parameter store

  db_subnet_group_name = data.aws_ssm_parameter.db_subnet_group_name.value

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

     tags = merge(
        var.common_tags,
        {
            Name = "${var.project_name}-${var.environment}"
        }
     )
    manage_master_user_password = false #we're managing password on our own. If it's true, then aws will manage & store the pwd in secret manager
    password = "ExpenseApp1"

    skip_final_snapshot = true

  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]
 

  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

#creating route53 records usind RDS endpoint (address)
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "db-${var.environment}"
      type    = "CNAME"
      ttl     = 1
      records = [
        module.db.db_instance_address #we're catching the output db_instance_address declared in db module which is the RDS address/endpoint
      ]
    },
  ]
}
