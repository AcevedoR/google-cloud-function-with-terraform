# google-cloud-function-with-terraform
Deploy GCP Pub/Sub function with terraform

## How
On each commit, Github Actions applies Terraform conf (located at `./terraform`), 
to deploy the GCP Function (located at `./src`)

Terraform state is saved in a Google Cloud Storage named `terraform-state-bucket-2` (bucket is handled by Terraform)

## Requirements
- GCP Service Account, with Functions, Roles and Storage Object permissions.
- Secrets on Github repository:
    - GCP_SA_KEY (service account Json)
    - GCP_PROJECT (project id)
