	terraform {
	  required_providers {
	    aws = {
	      source  = "hashicorp/aws"
	      version = "5.48.0"
	    }
	  }
	  backend "s3" {

		bucket = "muvva-remotestate-bucket"	
		region = "us-east-1"		#this is the s3 bucket name
		key = "expense-infra-dev-sg"				#this is the user defined key name for bucket
		dynamodb_table = "muvva-lock"					#mentioning the dynamo table name use for locking
		
	  }
	}
	
	# Configure the AWS Provider
	provider "aws" {
	  region = "us-east-1"
	}
	
	