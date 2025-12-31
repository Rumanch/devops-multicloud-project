terraform {
  required_version = ">= 1.4.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "google" {
  project = "total-market-482620-e5" 
  region  = "us-central1"
}

# 1. Enable Required APIs (Crucial for a new project)
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "container" {
  service = "container.googleapis.com"
}

# 2. VPC Network
resource "google_compute_network" "vpc_network" {
  name                    = "devops-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

# 3. Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "devops-subnet"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

# 4. GKE Cluster (The Brain - Zonal for Free Tier)
resource "google_container_cluster" "gke_cluster" {
  name     = "devops-gke"
  location = "us-central1-a" # Changed from region to ZONE to save money

  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.subnet.name

  # Recommended: Start with a "clean" cluster and add nodes separately
  remove_default_node_pool = true
  initial_node_count       = 1

  depends_on = [google_project_service.container]
}

# 5. Managed Node Pool (The Muscle)
resource "google_container_node_pool" "primary_nodes" {
  name       = "main-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.gke_cluster.name
  node_count = 1 # Keep it at 1 for the free tier

  node_config {
    preemptible  = true # Perfect for dev: uses cheaper "Spot" capacity
    machine_type = "e2-medium"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
