
output "load_balancer_url" { value = module.compute.alb_dns }
output "cloudfront_distribution_id" { value = module.storage.cloudfront_id }
