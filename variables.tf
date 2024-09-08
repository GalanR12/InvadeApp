variable "database_user" {
  type    = string
  default = "user"
}

variable "database_password" {
  type    = string
  default = "password"
}

variable "database_name" {
  type    = string
  default = "postgres"
}

variable "database_port" {
  type    = number
  default = 5432
}

variable "database_host" {
  default = "invadeapp-database.postgres.database.azure.com"
}

variable "entrypoint_path" {
  default = "./docker-entrypoint.sh"
}
