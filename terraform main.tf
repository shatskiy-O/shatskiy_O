Terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "" # https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token получить токен в яндекс облаке
  cloud_id  = "" # id облака
  folder_id = "" # id папки 
  zone      = "ru-central1-a" # зона сети
}

resource "yandex_compute_instance" "vm1" {  
  name = "vm1" # имя виртуальной машины

  resources {
    cores  = 2 # колличество ядер
    memory = 2 # колличество Оперативной памяти
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ps4vdhf5hhuj8obp2" # id образа ОС (есть при создании каждой ВМ)
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id  
    nat       = true 
  }

metadata = {
   user-data = "${file("./meta.txt")}"
   ssh-keys = "tor:${file("~/.ssh/id_ed25519.pub")}"
   serial-port-enable = "1"
  }
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["10.128.0.0/24"] # подсеть где взять ip виртуальной машины
}

output "internal_ip_address_vm1" {
  value = yandex_compute_instance.vm1.network_interface.0.ip_address 
}

output "external_ip_address_vm1" {  
  value = yandex_compute_instance.vm1.network_interface.0.nat_ip_address  
}
