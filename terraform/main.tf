resource "google_compute_instance" "sonarqube" {
    name           = "sonarqub-instance"
    machine_type   = "e2-medium"
    zone           = "us-central1-a"

    tags = ["sonarqube-instance"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
      }
    }
  }

    network_interface {
        network = "default"
        access_config {

        }
    }

  metadata = {
    foo = "bar"
  }


metadata_startup_script = <<-EOT
#!/bin/bash
echo "Starting SonarQube setup..." >> /var/log/startup-script.log
sudo apt-get update >> /var/log/startup-script.log 2>&1
sudo apt-get install -y docker.io >> /var/log/startup-script.log 2>&1

# Pull SonarQube Docker image
sudo docker pull sonarqube >> /var/log/startup-script.log 2>&1

# Run SonarQube container (choose one option):

# Option 1: Run in foreground and expose web interface
# sudo docker run -d -p 9000:9000 --name sonarqube sonarqube

# Option 2: Run in detached mode with persistent data (create volume named sonar-data first)
sudo docker run -d -p 9000:9000 --name sonarqube -v sonar-data:/var/lib/sonarqube sonarqube

# Log the completion
echo "SonarQube setup completed." >> /var/log/startup-script.log
EOT
}

resource "google_compute_firewall" "allow-sonarqube" {
    name = "allow-sonaqube"
    network = "default"

    allow {
       protocol = "tcp"
       ports = ["9000", "80"]
    }

    target_tags = ["sonarqube-instance"]
    source_ranges = ["0.0.0.0/0"]
}

