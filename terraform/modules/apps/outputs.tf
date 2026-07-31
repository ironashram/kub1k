output "app_of_apps_release_id" {
  description = "Argo CD app-of-apps release id, used to order downstream provisioning without a module-wide depends_on"
  value       = helm_release.argocd_app_of_apps.id
}
