locals {
  tags = merge(
    var.required_tags,
    var.optional_tags
  )

  include_private_endpoint = length(var.private_endpoint_subnet_id) > 0
}