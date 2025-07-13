output "images" {
  description = "Map of downloaded image resources"
  value       = proxmox_virtual_environment_download_file.images
}

output "image_ids" {
  description = "Map of image names to their resource IDs"
  value = {
    for name, image in proxmox_virtual_environment_download_file.images : name => image.id
  }
}

output "image_files" {
  description = "Map of image names to their file information"
  value = {
    for name, image in proxmox_virtual_environment_download_file.images : name => {
      id           = image.id
      file_name    = image.file_name
      content_type = image.content_type
      datastore_id = image.datastore_id
      node_name    = image.node_name
      size         = image.size
      task_id      = image.task_id
    }
  }
}

output "successful_downloads" {
  description = "List of successfully downloaded image names"
  value       = keys(proxmox_virtual_environment_download_file.images)
}

output "total_size" {
  description = "Total size of all downloaded images in bytes"
  value = sum([
    for image in proxmox_virtual_environment_download_file.images : image.size
  ])
}