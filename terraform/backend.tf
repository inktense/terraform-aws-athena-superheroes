terraform {
  backend "s3" {
    bucket = "tf-state-202201108659685447"
    key    = "terraform-athena-superheroes.tfstate"
    region = "eu-west-2"
  }
}
