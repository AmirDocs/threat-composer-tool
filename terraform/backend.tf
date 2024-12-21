terraform {
  required_version = ">= 1.0.0"  
  backend "s3" {
    bucket  = "threat-app-bucket"
    key     = "state"                        # Path for the state file in the bucket
    region  = "eu-west-2"
    encrypt = true                           # (optional): Enable server side encryption
  }
}