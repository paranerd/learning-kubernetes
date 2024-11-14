provider "google" {
  project     = var.project_id
  region      = var.region
}

variable "project_id" {
  type = string
  description = "Project ID"
}

variable "region" {
  type = string
  description = "Region"
  default = "us-central1"
}

resource "google_project_service" "cloud_resource_manager" {
  project = var.project_id
  service = "cloudresourcemanager.googleapis.com"
}

resource "google_project_service" "kubernetes_engine" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_project_organization_policy" "shielded_vm_policy" {
  project    = var.project_id
  constraint = "compute.requireShieldedVm"

  boolean_policy {
    enforced = false
  }
}

resource "google_project_organization_policy" "external_ip_policy" {
  project    = var.project_id
  constraint = "compute.vmExternalIpAccess"

  list_policy {
    allow {
      all = true
    }
  }
}

resource "google_compute_network" "vpc_network" {
  name = "default"
}

resource "google_container_cluster" "primary" {
  name               = "hello-cluster"
  location           = var.region
  initial_node_count = 3
}