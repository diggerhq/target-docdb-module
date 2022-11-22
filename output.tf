output "endpoint" {
  value = aws_docdb_cluster.docdb.endpoint
}

output "docdb_uri_ssm_arn" {
  value = aws_ssm_parameter.docdb_uri.arn
}
