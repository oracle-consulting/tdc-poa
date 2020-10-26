resource "oci_core_instance" "wordpress" {
	availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "wpress-srv"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    subnet_id        = oci_core_subnet.public_subnet.id
    assign_public_ip = "true"
    hostname_label   = "wpress-srv"
  }

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_20_04_image_ocid
  }

  timeouts {
    create = "60m"
  }

  metadata = {
    ssh_authorized_keys = file(var.ssh_public_key)
  }
}

resource "null_resource" "connection_wordpress" {

  triggers = {
    user        = "ubuntu"
    private_key = file(var.ssh_private_key)
    host = oci_core_instance.wordpress.public_ip
  }
  connection {
    agent       = false
    timeout     = "1m"
    host        = self.triggers.host
    user        = self.triggers.user
    private_key = self.triggers.private_key
  }

 provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt install vim locate apache2 php php-mysql php-curl php-gd php-zip mysql-server mysql-server -y",
      "sudo iptables -I INPUT 6 -m state --state NEW -p tcp --dport 80 -j ACCEPT",
      "sudo netfilter-persistent save",
      "sudo systemctl restart apache2",
      "sudo adduser $USER www-data",
      "sudo chown -R www-data:www-data /var/www/html",
      "sudo chmod -R g+rw /var/www/html",
      "sudo wget https://wordpress.org/latest.tar.gz -O /tmp/latest.tar.gz",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo echo 'sudo mysql_secure_installation <<EOF' > mysql_secure_installation.sh",
      "sudo echo 'y' >> mysql_secure_installation.sh",
      "sudo echo 'welcomeTDC' >> mysql_secure_installation.sh",
      "sudo echo 'welcomeTDC' >> mysql_secure_installation.sh",
      "sudo echo 'y' >> mysql_secure_installation.sh",
      "sudo echo 'y' >> mysql_secure_installation.sh",
      "sudo echo 'n' >> mysql_secure_installation.sh",
      "sudo echo 'y' >> mysql_secure_installation.sh",
      "sudo echo 'y' >> mysql_secure_installation.sh",
      "sudo echo 'EOF' >> mysql_secure_installation.sh",
      "sudo rm -rf /home/ubuntu/mysql_secure_installation.sh",
    ]
  }

  provisioner "file" {
    source = "scripts/create_user_mysql.sh"
    destination = "/tmp/create_user_mysql.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_user_mysql.sh",
      "/tmp/create_user_mysql.sh",
    ]
  }

  provisioner "file" {
    source = "scripts/create_wpress-db.sh"
    destination = "/tmp/create_wpress-db.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/create_wpress-db.sh",
      "/tmp/create_wpress-db.sh",
    ]
  }  

  provisioner "remote-exec" {
    inline = [
      "sudo tar -xzvf /tmp/latest.tar.gz -C /tmp/",
      "sudo cp -R /tmp/wordpress/* /var/www/html/",
      "sudo rm -rf /tmp/wordpress/",
      "sudo mv /var/www/html/index.html /var/www/html/index.html.bk",
      "sudo mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php",
      "sudo sed -i 's/username_here/wpress_user/' /var/www/html/wp-config.php",
      "sudo sed -i 's/password_here/welcomeTDC/' /var/www/html/wp-config.php",
      "sudo sed -i 's/database_name_here/wordpress_db/' /var/www/html/wp-config.php",
    ]  
  }
}  