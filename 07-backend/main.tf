module "backend_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

  instance_type          = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  #convert stringlist to list and fetch 1st subnet id
  subnet_id              = local.private_subnet_id
  ami = data.aws_ami.ami_info.id

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    }
  )
}
resource "null_resource" "resources" {
    triggers = {
        instance_id = module.backend_instance.id #this will be triggered everytime, the instance is created

    }
    connection {
      type = "ssh"
      user = "ec2-user"
      password = "DevOps321"
      host = module.backend_instance.private_ip
    }
    provisioner "file" {  #to copy a file to remote server, we use file provisioner after giving the connection details
      source = "${var.common_tags.component}.sh"
      destination = "/tmp/${var.common_tags.component}.sh"
    }
    provisioner "remote-exec" {
        inline =[
          "chmod +x /tmp/${var.common_tags.component}.sh",
          "sudo sh /tmp/${var.common_tags.component}.sh ${var.common_tags.component} ${var.environment}"

    ]
    }

}

#stopping the backend instance before taking ami
resource "aws_ec2_instance_state" "backend" {
    instance_id = module.backend_instance.id
    state = "stopped"

    #stop the backend resource only when the null resource provisioning is completed
    depends_on = [ null_resource.resources ]
}

#taking the AMI after stopping the configured backend instance
resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  source_instance_id = module.backend_instance.id

#should take AMI only when instance is stopped
  depends_on = [ aws_ec2_instance_state.backend ]
}

#configuring the resources using null resource
resource "null_resource" "backend_delete" {
    triggers = {
        instance_id = module.backend_instance.id #this will be triggered everytime, the instance is created

    }
    connection {
      type = "ssh"
      user = "ec2-user"
      password = "DevOps321"
      host = module.backend_instance.private_ip
    }
    
    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${module.backend_instance.id}"
    }
    depends_on = [ aws_ami_from_instance.backend ]
}

#creates app lb providing the port and protocols, also the health check
resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  health_check {
    path = "/health"
    port        = 8080
    protocol    = "HTTP"
    healthy_threshold = 2
    unhealthy_threshold = 2
    matcher = "200"
  }
}

#creates an aws launch template with the AMI provided
resource "aws_launch_template" "backend" {
  name = "${var.project_name}-${var.environment}-${var.common_tags.component}"

  image_id = aws_ami_from_instance.backend.id

  instance_initiated_shutdown_behavior = "terminate"

  instance_type = "t3.micro"

  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  update_default_version = true #sets the latest version as default

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.common_tags,{
      Name = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    }
    )
  }
}

#creates an auto scaling group providing the launch template and defining the health checks, also mentions how many should be created at once
resource "aws_autoscaling_group" "backend" {
  name                      = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "ELB"
  desired_capacity          = 1
  target_group_arns = [aws_lb_target_group.backend.arn]
  launch_template {
    id = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier       = [local.private_subnet_id]

 tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-${var.common_tags.component}"
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
  tag {
    key                 = "Project"
    value               = "${var.project_name}"
    propagate_at_launch = true
  }
   instance_refresh {
    strategy = "Rolling" #it means new instance is created and then, old one is deleted.
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"] #refresh should be done when launch_template is updated
  }
}

# creates auto scaling policy, in which we define the metric based on which auto scaling has to be done
resource "aws_autoscaling_policy" "backend" {
  name                   = "${var.project_name}-${var.environment}-${var.common_tags.component}"
  policy_type             = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.backend.name

   target_tracking_configuration { #to be used whenn we specify policy_type as above, since we're tracking AVG cpu utilization
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 10.0
  }
}

# creating listener rule for app alb
resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 100 # can set multiple rules with respective priority numbers and the rule with less number gets prioritised

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.zone_name}"] #we're providing the host path of backend
    }
  }
}