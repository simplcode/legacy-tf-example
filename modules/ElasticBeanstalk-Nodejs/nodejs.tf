# Full options for Elastic Beanstalk
# http://docs.aws.amazon.com/elasticbeanstalk/latest/dg/command-options-general.html#command-options-general-elasticbeanstalkmanagedactionsplatformupdate

variable "env" {}
variable "domain" {}
variable "ebZoneId" {}
variable "name" {}
variable "cname" {}
variable "description" {}
# Environment
variable "solutionStackName" {}
# Launch configuration
variable "instanceType" {}
variable "ec2keyName" {}
# Deployment
variable "deploymentPolicy" {
  default = "Rolling"
  description = "Choose between Rolling and RollingWithAdditionalBatch"
}
# Auto Scaling Group
variable "az" { type = "list" }
variable "minSize" {}
variable "maxSize" {}
# Scaling Trigger
variable "breachDuration" {}
variable "lowerBreachScaleIncrement" {}
variable "lowerThreshold" {}
variable "measureName" {}
variable "unit" {}
variable "upperBreachScaleIncrement" {}
variable "upperThreshold" {}
# Load Balancer
variable "allowHTTP" { default = "true"}
variable "allowHTTPS" { default = "false"}
variable "httpsListenerProtocol" { default = "HTTPS" }
variable "httpsInstancePort" { default = "80" }
variable "httpsInstanceProtocal" { default = "HTTP" }
variable "securityGroupId" {}
variable "sslCertificateId" {}
# VPC
variable "vpcId" {}
variable "subnetIds" {}
variable "elbSubnetIds" {}

data "aws_route53_zone" "selected" {
  name = "${var.domain}"
  private_zone = false
}

################## Application ##################

resource "aws_elastic_beanstalk_application" "EB" {
  name = "${var.name}${var.env == "prod" ? "" : var.env}"
  description = "${var.description}"
}

################## Environment ##################

resource "aws_elastic_beanstalk_environment" "EBENV" {
  application = "${aws_elastic_beanstalk_application.EB.name}"
  name = "${aws_elastic_beanstalk_application.EB.name}"
  solution_stack_name = "${var.solutionStackName}"
  cname_prefix = "${aws_elastic_beanstalk_application.EB.name}"

  ######### CloudWatch logs #########
/*  setting {
    name = "StreamLogs"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    value = "true"
  }

  setting {
    name = "DeleteOnTerminate"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    value = "true"
  }

  setting {
    name = "RetentionInDays"
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    value = "7"
  }*/

  ######### X-Ray #########
  setting {
    name = "XRayEnabled"
    namespace = "aws:elasticbeanstalk:xray"
    value = "false"
  }

  ######### Environment #########

  setting {
    name = "EnvironmentType"
    namespace = "aws:elasticbeanstalk:environment"
    value = "LoadBalanced"
  }

  setting {
    name = "ServiceRole"
    namespace = "aws:elasticbeanstalk:environment"
    value = "aws-elasticbeanstalk-service-role"
  }

  setting {
    name = "LoadBalancerType"
    namespace = "aws:elasticbeanstalk:environment"
    value = "classic"
  }

  ######### Application Environment #########

  setting {
    name = "NODE_ENV"
    namespace = "aws:elasticbeanstalk:application:environment"
    value = "${var.env}"
  }

  ######### Rolling Deployments #########

  setting {
    name = "DeploymentPolicy"
    namespace = "aws:elasticbeanstalk:command"
    value = "Rolling"
  }

  setting {
    name = "BatchSizeType"
    namespace = "aws:elasticbeanstalk:command"
    value = "Fixed"
  }

  setting {
    name = "BatchSize"
    namespace = "aws:elasticbeanstalk:command"
    value = "1"
  }


  ######### Managed Updates #########

  setting {
    name = "ManagedActionsEnabled"
    namespace = "aws:elasticbeanstalk:managedactions"
    value = "true"
  }

  setting {
    name = "PreferredStartTime"
    namespace = "aws:elasticbeanstalk:managedactions"
    value = "Mon:00:00"
  }

  setting {
    name = "UpdateLevel"
    namespace = "aws:elasticbeanstalk:managedactions:platformupdate"
    value = "minor"
  }

  ######### Enhanced Health Reporting #########

  setting {
    name = "SystemType"
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    value = "enhanced"
  }

  ######### Launch configuration #########

  setting {
    name = "InstanceType"
    namespace = "aws:autoscaling:launchconfiguration"
    value = "${var.instanceType}"
  }

  setting {
    name = "IamInstanceProfile"
    namespace = "aws:autoscaling:launchconfiguration"
    value = "aws-elasticbeanstalk-ec2-role"
  }

  setting {
    name = "EC2KeyName"
    namespace = "aws:autoscaling:launchconfiguration"
    value = ""
  }

  ######### Auto Scaling Group #########

  setting {
    name = "Availability Zones"
    namespace = "aws:autoscaling:asg"
    value = "Any ${length(var.az) > 3 ? 3 : length(var.az)}"
  }

  setting {
    name = "MinSize"
    namespace = "aws:autoscaling:asg"
    value = "${var.minSize}"
  }

  setting {
    name = "MaxSize"
    namespace = "aws:autoscaling:asg"
    value = "${var.maxSize}"
  }

  ######### Scaling Trigger #########

  setting {
    name = "BreachDuration"
    namespace = "aws:autoscaling:trigger"
    value = "${var.breachDuration}"
  }

  setting {
    name = "LowerBreachScaleIncrement"
    namespace = "aws:autoscaling:trigger"
    value = "${var.lowerBreachScaleIncrement}"
  }

  setting {
    name = "LowerThreshold"
    namespace = "aws:autoscaling:trigger"
    value = "${var.lowerThreshold}"
  }

  setting {
    name = "MeasureName"
    namespace = "aws:autoscaling:trigger"
    value = "${var.measureName}"
  }

  setting {
    name = "Unit"
    namespace = "aws:autoscaling:trigger"
    value = "${var.unit}"
  }

  setting {
    name = "UpperBreachScaleIncrement"
    namespace = "aws:autoscaling:trigger"
    value = "${var.upperBreachScaleIncrement}"
  }

  setting {
    name = "UpperThreshold"
    namespace = "aws:autoscaling:trigger"
    value = "${var.upperThreshold}"
  }

  ######### Rolling Updates #########

  setting {
    name = "MaxBatchSize"
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    value = "1"
  }

  setting {
    name = "RollingUpdateEnabled"
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    value = "true"
  }

  setting {
    name = "RollingUpdateType"
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    value = "Health"
  }


  ######### Load Balancer #########

  setting {
    name = "Crosszone"
    namespace = "aws:elb:loadbalancer"
    value = "true"
  }

  setting {
    name = "SecurityGroups"
    namespace = "aws:elb:loadbalancer"
    value = "${var.securityGroupId}"
  }

  setting {
    name = "ManagedSecurityGroup"
    namespace = "aws:elb:loadbalancer"
    value = "${var.securityGroupId}"
  }

  ######### ELB Listener #########

  // HTTP
  // AWS Web console에 값이 제대로 표시되지 않는 버그가 있음.(AWS bug)
  setting {
    name = "ListenerProtocol"
    namespace = "aws:elb:listener"
    value = "HTTP"
  }

  setting {
    name = "InstancePort"
    namespace = "aws:elb:listener"
    value = "80"
  }

  setting {
    name = "InstanceProtocol"
    namespace = "aws:elb:listener"
    value = "HTTP"
  }

  setting {
    name = "ListenerEnabled"
    namespace = "aws:elb:listener"
    value = "${var.allowHTTP}"
  }

  // HTTPS
  setting {
    name = "ListenerProtocol"
    namespace = "aws:elb:listener:443"
    value = "${var.httpsListenerProtocol}"
  }

  setting {
    name = "InstancePort"
    namespace = "aws:elb:listener:443"
    value = "${var.httpsInstancePort}"
  }

  setting {
    name = "InstanceProtocol"
    namespace = "aws:elb:listener:443"
    value = "${var.httpsInstanceProtocal}"
  }

  setting {
    name = "SSLCertificateId"
    namespace = "aws:elb:listener:443"
    value = "${var.sslCertificateId}"
  }

  setting {
    name = "ListenerEnabled"
    namespace = "aws:elb:listener:443"
    value = "${var.allowHTTPS}"
  }

  ######### ELB Policies #########

  setting {
    name = "ConnectionDrainingEnabled"
    namespace = "aws:elb:policies"
    value = "true"
  }

  setting {
    name = "ConnectionDrainingTimeout"
    namespace = "aws:elb:policies"
    value = "20"
  }

  setting {
    name = "LoadBalancerPorts"
    namespace = "aws:elb:policies"
    value = ":all"
  }

  setting {
    name = "Stickiness Cookie Expiration"
    namespace = "aws:elb:policies"
    value = "3600"
  }

  setting {
    name = "Stickiness Policy"
    namespace = "aws:elb:policies"
    value = "true"
  }

  ######### VPC #########

  setting {
    name = "VPCId"
    namespace = "aws:ec2:vpc"
    value = "${var.vpcId}"
  }

  setting {
    name = "Subnets"
    namespace = "aws:ec2:vpc"
    value = "${var.subnetIds}"
  }

  setting {
    name = "ELBSubnets"
    namespace = "aws:ec2:vpc"
    value = "${var.elbSubnetIds}"
  }

}

resource "aws_route53_record" "EBDomain" {
  name = "${var.cname}${var.env == "prod" ? "" : var.env}"
  type = "A"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"

  alias {
    evaluate_target_health = false
    name = "${aws_elastic_beanstalk_environment.EBENV.cname}"
    zone_id = "${var.ebZoneId}"
  }
}

output "eb-url" {
  value = "${aws_route53_record.EBDomain.fqdn}"
}

output "eb-cname" {
  value = "${aws_elastic_beanstalk_environment.EBENV.cname}"
}