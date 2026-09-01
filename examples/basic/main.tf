terraform {
  required_version = ">= 1.6"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 7.0, < 8.0"
    }
  }
}

provider "google" {
  project = "iacbazaar-example-project"
  region  = "us-central1"
}

# Public health-check ping every 30 minutes, no auth.
module "healthcheck" {
  source = "../../"

  project_id = "iacbazaar-example-project"
  name       = "example-healthcheck"
  schedule   = "*/30 * * * *"

  uri         = "https://example.com/health"
  http_method = "GET"
}

output "job_id" {
  value = module.healthcheck.id
}

output "job_state" {
  value = module.healthcheck.state
}
