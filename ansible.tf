resource "local_file" "ansible_host" {

    depends_on = [
      aws_instance.k8s
    ]

    count       = var.n
    content     = "[Master_Node]\n${aws_instance.k8s.public_ip}\n\n[Worker_Node]\n${join("\n", azurerm_linux_virtual_machine.myk8svm.*.public_ip_address)}"
    filename    = "inventory"
  }

resource "null_resource" "null1" {

    depends_on = [
      local_file.ansible_host
    ]

  provisioner "local-exec" {
    command = "sleep 60"
    }

  provisioner "local-exec" {
    command = "ansible-playbook playbook.yml"
    }

}

output "Master_Node_IP" {
  value = aws_instance.k8s.public_ip
}

output "Worker_Node_IP" {
  value = join(", ", azurerm_linux_virtual_machine.myk8svm.*.public_ip_address)
}