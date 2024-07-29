module "bastion_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-bastion"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.ssm_bastion_info.value]
  #convert stringlist to list and fetch 1st subnet id
  subnet_id              = local.public_subnet_id
  ami = data.aws_ami.ami_info.id
  user_data = file("bastion.sh")

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}