terraform {
  backend "s3" {
    bucket       = "mon-tfstate-bucket-projet1-session-12345"
    key          = "project1-iaac/main/terraform.tfstate"
    region       = "eu-west-3"
    use_lockfile = true
    encrypt      = true
  }
}