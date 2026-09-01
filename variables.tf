variable "project_id" {
  description = "GCP project ID that owns the scheduler job."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid GCP project ID (6-30 chars, lowercase letters, digits, hyphens)."
  }
}

variable "region" {
  description = "Region hosting the Cloud Scheduler job (e.g. us-central1). Must be a region where Cloud Scheduler is available."
  type        = string
  default     = "us-central1"
}

variable "name" {
  description = "Name of the scheduler job."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9_-]{0,499}$", var.name))
    error_message = "name must start with a letter and contain only letters, digits, hyphens or underscores."
  }
}

variable "description" {
  description = "Human-readable description of the job."
  type        = string
  default     = "Managed by IaC Bazaar — Cloud Scheduler HTTP job."
}

variable "schedule" {
  description = "Cron schedule in unix-cron format (e.g. \"*/30 * * * *\" every 30 minutes)."
  type        = string
  default     = "*/30 * * * *"
}

variable "time_zone" {
  description = "IANA time zone the schedule is interpreted in (e.g. Etc/UTC, America/New_York)."
  type        = string
  default     = "Etc/UTC"
}

variable "paused" {
  description = "Create the job in the PAUSED state (it will not fire until resumed)."
  type        = bool
  default     = false
}

variable "attempt_deadline" {
  description = "How long Cloud Scheduler waits for the HTTP request to complete before treating the attempt as failed, as a duration with the 's' suffix (15s-1800s). Bounding this prevents a hung endpoint from holding an attempt open."
  type        = string
  default     = "180s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?s$", var.attempt_deadline))
    error_message = "attempt_deadline must be a duration in seconds with the 's' suffix, e.g. \"180s\"."
  }
}

variable "uri" {
  description = "Full HTTPS URI the job calls (HTTP is allowed but discouraged)."
  type        = string
  default     = "https://example.com/health"

  validation {
    condition     = can(regex("^https?://", var.uri))
    error_message = "uri must be a full http(s) URL."
  }
}

variable "http_method" {
  description = "HTTP method used for the request."
  type        = string
  default     = "GET"

  validation {
    condition     = contains(["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"], upper(var.http_method))
    error_message = "http_method must be one of GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS."
  }
}

variable "headers" {
  description = "HTTP headers sent with the request (e.g. { \"Content-Type\" = \"application/json\" })."
  type        = map(string)
  default     = {}
}

variable "body" {
  description = "Request body as a plain string (base64-encoded by the module). Only meaningful for POST/PUT/PATCH. Null = no body."
  type        = string
  default     = null
}

variable "retry_count" {
  description = "How many times a failed execution is retried (0 disables retries)."
  type        = number
  default     = 3

  validation {
    condition     = var.retry_count >= 0 && var.retry_count <= 5
    error_message = "retry_count must be between 0 and 5."
  }
}

variable "max_retry_duration" {
  description = "Time limit for all retries of one execution, as a duration with the 's' suffix. \"0s\" = no overall limit (only retry_count bounds it)."
  type        = string
  default     = "0s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?s$", var.max_retry_duration))
    error_message = "max_retry_duration must be a duration in seconds with the 's' suffix."
  }
}

variable "min_backoff_duration" {
  description = "Minimum wait before the first retry, as a duration with the 's' suffix."
  type        = string
  default     = "5s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?s$", var.min_backoff_duration))
    error_message = "min_backoff_duration must be a duration in seconds with the 's' suffix."
  }
}

variable "max_backoff_duration" {
  description = "Maximum wait between retries, as a duration with the 's' suffix."
  type        = string
  default     = "3600s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?s$", var.max_backoff_duration))
    error_message = "max_backoff_duration must be a duration in seconds with the 's' suffix."
  }
}

variable "max_doublings" {
  description = "How many times the retry backoff interval doubles before becoming constant."
  type        = number
  default     = 5

  validation {
    condition     = var.max_doublings >= 0
    error_message = "max_doublings must be >= 0."
  }
}

variable "oidc_service_account_email" {
  description = "Service account whose OIDC token authenticates calls to a Cloud Run / Cloud Functions / IAP endpoint. Null = no OIDC. Mutually exclusive with oauth_service_account_email."
  type        = string
  default     = null
}

variable "oidc_audience" {
  description = "Audience claim for the OIDC token (defaults to the target uri when null). Usually set to the receiving service's base URL."
  type        = string
  default     = null
}

variable "oauth_service_account_email" {
  description = "Service account whose OAuth token authenticates calls to a *.googleapis.com endpoint. Null = no OAuth. Mutually exclusive with oidc_service_account_email."
  type        = string
  default     = null
}

variable "oauth_scope" {
  description = "OAuth scope for the OAuth token."
  type        = string
  default     = "https://www.googleapis.com/auth/cloud-platform"
}
