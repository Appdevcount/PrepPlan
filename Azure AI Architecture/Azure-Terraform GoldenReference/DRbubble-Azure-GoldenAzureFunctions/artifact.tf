resource null_resource artifactory_artifact {
  triggers = {
    always_run = timestamp()
  }

  provisioner local-exec {
    # TODO - Format these to make sure we only have one set of slashes
    command = "curl -o ${local.local_filename} ${var.artifact_root}/${var.artifact_path}/${var.artifact}"
  }
}
