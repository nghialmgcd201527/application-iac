output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = element(concat(aws_acm_certificate_validation.this.*.certificate_arn, aws_acm_certificate.this.*.arn, [""]), 0)
}


output "api_acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = element(concat(aws_acm_certificate_validation.api.*.certificate_arn, aws_acm_certificate.api.*.arn, [""]), 0)
}

// output "acm_certificate_validation_emails" {
//   description = "A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used."
//   value       = flatten(aws_acm_certificate.this.*.validation_emails)
// }

// output "validation_route53_record_fqdns" {
//   description = "List of FQDNs built using the zone domain and name."
//   value       = aws_route53_record.validation.*.fqdn
// }
