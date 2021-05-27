# Create (and display) an SSH key
resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}

# Create local key
resource "local_file" "keyfile" {
    content         = tls_private_key.k8s_ssh.private_key_pem
    filename        = "terraform_key.pem"
    file_permission = "0400"
}