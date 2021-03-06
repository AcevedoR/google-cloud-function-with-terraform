# Setup
/*
resource "google_storage_bucket" "terraform-backend-bucket" {
  name          = "terraform-state-bucket-2"
  force_destroy = true
  //storage_class = var.terraform-state-storage-class
  versioning {
    enabled = true
  }
}
*/

# Functions
resource "google_storage_bucket" "functions_bucket" {
  name = "functions1-bucket"
  force_destroy = true
}

data "archive_file" "function_archive" {
  type        = "zip"
  source_dir  = "../src"
  output_path = var.bucket_archive_filepath
}

# https://github.com/hashicorp/terraform-provider-google/issues/1938 dynamic name, otherwise the Function cannot be updated
resource "google_storage_bucket_object" "archive" {
  name = format("%s#%s", var.bucket_archive_filepath, data.archive_file.function_archive.output_md5)
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.function_archive.output_path
}

resource "google_cloudfunctions_function" "function" {
  name        = "poc-tf-function"
  description = "POC function, managed with Terraform"
  runtime     = "nodejs14"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.functions_bucket.name
  source_archive_object = google_storage_bucket_object.archive.name
  timeout               = 60
  entry_point           = "greetFromPubSub"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource = "projects/${var.gcp_project}/topics/${var.function_topic}"
  }

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


