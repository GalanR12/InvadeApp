terraform {
  backend "local" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.0.1"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = "<your_subscription_id>"
  features {}
}

data "template_file" "entrypoint" {
  template = <<-EOT
    #!/bin/bash

    # allow CSRF for HTTP requests (example: "https://invadeapp.azurewebsites.net")
    export CSRF_TRUSTED_ORIGINS_PATH=https://invadeapp.azurewebsites.net

    # collect static files
    python manage.py collectstatic

    # database settings
    python manage.py makemigrations invade_app
    python manage.py migrate

    # run application
    python manage.py runserver 0.0.0.0:8000
  EOT
}

resource "local_file" "entrypoint_sh" {
  filename = var.entrypoint_path
  content  = data.template_file.entrypoint.rendered
  file_permission = "0755"  # Optional: to set executable permissions
}

resource "azurerm_resource_group" "rg" {
  name     = "django-app"
  location = "polandcentral"
}

# postgresql database
resource "azurerm_postgresql_flexible_server" "invadeapp-database" {
  name                          = "invadeapp-database"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  version                       = "12"
  public_network_access_enabled = true
  administrator_login           = var.database_user
  administrator_password        = var.database_password
  zone                          = "1"

  storage_mb   = 32768
  storage_tier = "P4"
  sku_name   = "B_Standard_B1ms"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow_all"
  server_id        = azurerm_postgresql_flexible_server.invadeapp-database.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_container_registry" "invade_app_acr" {
  name                  = "invadeappacr"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  sku                   = "Basic"
  admin_enabled         = true
}

resource "terraform_data" "acr_commands" {
    provisioner "local-exec" {
      command = "az acr login --name ${azurerm_container_registry.invade_app_acr.login_server}"
    }
    provisioner "local-exec" {
      command = "docker build -t invadeapp:3.0 ."
    }
    provisioner "local-exec" {
      command = "docker tag invadeapp:3.0 ${azurerm_container_registry.invade_app_acr.login_server}/invadeapp"
    }
    provisioner "local-exec" {
      command = "docker push ${azurerm_container_registry.invade_app_acr.login_server}/invadeapp"
    }
}

resource "azurerm_service_plan" "invadeapp_app_service_plan" {
  name                = "invadeapp_app_service_plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# web App
resource "azurerm_linux_web_app" "app-service" {
  name = "invadeapp"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id = azurerm_service_plan.invadeapp_app_service_plan.id

  app_settings = {
    DOCKER_ENABLE_CI = "true"
    DATABASE_NAME=var.database_name
    DATABASE_USER=var.database_user
    DATABASE_PASSWORD=var.database_password
    DATABASE_HOST=var.database_host
    DATABASE_PORT=var.database_port
  }
  
  site_config {
    app_command_line = ""
    always_on = false
    application_stack {
        docker_registry_url = "https://${azurerm_container_registry.invade_app_acr.login_server}"
        docker_registry_username = azurerm_container_registry.invade_app_acr.admin_username
        docker_registry_password = azurerm_container_registry.invade_app_acr.admin_password
        docker_image_name = "invadeapp:latest"
      }
  }
}

# Outputs
output "acr_admin_username" {
  value = "ACR admin username: ${azurerm_container_registry.invade_app_acr.admin_username}"
  sensitive = true
}

output "acr_admin_password" {
  value = "ACR admin password: ${azurerm_container_registry.invade_app_acr.admin_password}"
  sensitive = true
}




