terraform {
  backend "s3" {
    bucket         = "skehlet-terraformstate"
    region         = "us-west-2"
    key            = "vpc.tfstate"
    dynamodb_table = "terraform-state"
  }
}
