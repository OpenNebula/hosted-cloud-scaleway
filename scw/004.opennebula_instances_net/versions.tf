terraform {
  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "2.57.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }
    ssh = {
      source = "loafoe/ssh"
    }
  }
}
