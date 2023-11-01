terraform {
  backend "s3" {
    bucket = "plz-build-storage"
    key    = "terraform/gitlabec2.tfstate"
    region = "us-west-2"
  }
}