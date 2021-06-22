terraform {
  backend "gcs" {
    bucket  = "terraform-state-bucket-2"
    prefix  = "terraform/state"
  }
}