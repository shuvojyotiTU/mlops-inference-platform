# main.tf

provider "google" {
  project = "refined-gist-454116-d2"  # <--- REPLACE THIS with your actual Project ID
  region  = "us-central1"
  zone    = "us-central1-a"
}

# 1. The GKE Cluster (Control Plane)
# We use a Zonal cluster because the Management Fee is FREE.
resource "google_container_cluster" "primary" {
  name     = "mlops-cluster"
  location = "us-central1-a"
  
  # We delete the default node pool to create a custom one below
  remove_default_node_pool = true
  initial_node_count       = 1
}

# 2. The Worker Nodes (Computers)
# This is where your Docker containers will run.
resource "google_container_node_pool" "primary_nodes" {
  name       = "mlops-node-pool"
  location   = "us-central1-a"
  cluster    = google_container_cluster.primary.name
  node_count = 2  # Start with 2 nodes

  node_config {
    preemptible  = true  # CHEAPER! These are "Spot instances" (60-90% discount)
    machine_type = "e2-medium" # 2 vCPU, 4GB RAM (Good balance for AI)
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}