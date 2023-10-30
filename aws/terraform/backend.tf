terraform {
  backend "s3" {
    bucket = "mysticrenji"
    key    = "terraform/gitlabec2.tfstate"
    region = "us-west-2"
  }
}