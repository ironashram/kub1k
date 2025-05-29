resource "kubernetes_cron_job_v1" "image_cache" {
  depends_on = [helm_release.calico]
  metadata {
    name      = "image-cache"
    namespace = "default"
    labels = {
      app = "image-cache"
    }
  }

  spec {
    concurrency_policy            = "Allow"
    schedule                      = "0 */6 * * *"
    timezone                      = "Europe/Rome"
    failed_jobs_history_limit     = 1
    successful_jobs_history_limit = 1
    job_template {
      metadata {
        labels = {
          app = "image-cache"
        }
      }
      spec {
        parallelism = 3
        completions = 3
        template {
          metadata {
            labels = {
              app = "image-cache"
            }
          }
          spec {
            topology_spread_constraint {
              max_skew           = 1
              topology_key       = "kubernetes.io/hostname"
              when_unsatisfiable = "DoNotSchedule"
              label_selector {
                match_labels = {
                  app = "image-cache"
                }
              }
            }
            container {
              name              = "toolbox-cache"
              image             = "ghcr.io/ironashram/toolbox:latest"
              image_pull_policy = "Always"
              command           = ["date", "+%Y-%m-%d %H:%M:%S toolbox image cached"]
            }
            restart_policy = "OnFailure"
          }
        }
      }
    }
  }
}
