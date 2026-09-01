output "id" {
  description = "Fully-qualified job ID (projects/<p>/locations/<region>/jobs/<name>)."
  value       = google_cloud_scheduler_job.this.id
}

output "name" {
  description = "The job name."
  value       = google_cloud_scheduler_job.this.name
}

output "schedule" {
  description = "The effective cron schedule."
  value       = google_cloud_scheduler_job.this.schedule
}

output "state" {
  description = "Current job state (ENABLED, PAUSED, ...)."
  value       = google_cloud_scheduler_job.this.state
}

output "uri" {
  description = "The HTTP target URI the job calls."
  value       = google_cloud_scheduler_job.this.http_target[0].uri
}
