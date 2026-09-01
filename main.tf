# A Cloud Scheduler cron job targeting an HTTP(S) endpoint, with the retry and
# timeout knobs that hand-rolled jobs leave at unsafe defaults: a bounded attempt
# deadline, a capped exponential-backoff retry policy, and optional service-account
# auth (OIDC for Cloud Run / Cloud Functions / IAP, OAuth for Google APIs) so the
# scheduler can call a private endpoint without baking a token into the request.
#
# Secure defaults: when an auth service account is supplied the scheduler mints a
# short-lived OIDC/OAuth token per invocation (no static secret); leave both auth
# inputs null for a public endpoint. Cloud Scheduler in a supported region (e.g.
# us-central1) no longer requires an App Engine application.

resource "google_cloud_scheduler_job" "this" {
  project     = var.project_id
  region      = var.region
  name        = var.name
  description = var.description
  schedule    = var.schedule
  time_zone   = var.time_zone
  paused      = var.paused

  attempt_deadline = var.attempt_deadline

  retry_config {
    retry_count          = var.retry_count
    max_retry_duration   = var.max_retry_duration
    min_backoff_duration = var.min_backoff_duration
    max_backoff_duration = var.max_backoff_duration
    max_doublings        = var.max_doublings
  }

  http_target {
    uri         = var.uri
    http_method = var.http_method
    headers     = var.headers
    # Bodies are only valid for methods that carry one; the provider expects the
    # body base64-encoded.
    body = var.body == null ? null : base64encode(var.body)

    # OIDC — calling a Cloud Run / Cloud Functions / IAP-protected endpoint.
    dynamic "oidc_token" {
      for_each = var.oidc_service_account_email == null ? [] : [1]
      content {
        service_account_email = var.oidc_service_account_email
        audience              = var.oidc_audience
      }
    }

    # OAuth — calling a *.googleapis.com endpoint.
    dynamic "oauth_token" {
      for_each = var.oauth_service_account_email == null ? [] : [1]
      content {
        service_account_email = var.oauth_service_account_email
        scope                 = var.oauth_scope
      }
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.oidc_service_account_email != null && var.oauth_service_account_email != null)
      error_message = "Set at most one of oidc_service_account_email and oauth_service_account_email — an HTTP target uses a single auth scheme."
    }
  }
}
