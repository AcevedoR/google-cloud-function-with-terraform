terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = var.gcp_credentials
  project = var.gcp_project
  region  = var.gcp_region
  zone    = var.gcp_zone
}

resource "google_storage_bucket" "bucket" {
  name = "functions1-bucket"
}

data "archive_file" "local_tracer_source" {
  type        = "zip"
  source_dir  = "../src"
  output_path = "./function_content.zip"
}

resource "google_storage_bucket_object" "archive" {
  name   = "function_content.zip"
  bucket = google_storage_bucket.bucket.name
  source = "./function_content.zip"
}

resource "google_cloudfunctions_function" "function" {
  name        = "poc-tf-function"
  description = "POC function, managed with Terraform"
  runtime     = "nodejs14"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "greetFromPubSub"
  labels = {
    my-label = "my-label-value"
  }

  environment_variables = {
    MY_ENV_VAR = "my-env-var-value"
  }
}

# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  project        = google_cloudfunctions_function.function.project
  region         = google_cloudfunctions_function.function.region
  cloud_function = google_cloudfunctions_function.function.name

  role   = "roles/cloudfunctions.invoker"
#  member = "user:myFunctionInvoker@example.com" TODO is it ugly ?
  member = "allUsers"
}

