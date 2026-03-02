locals {
  tags = merge(
    var.required_tags,
    var.optional_tags
  )

}