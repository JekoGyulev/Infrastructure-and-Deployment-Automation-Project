variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The Azure Region in which to create the resources."
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the app service plan."
  type        = string
}

variable "wep_app_name" {
  description = "The name of the web application."
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL server."
  type        = string
}

variable "sql_db_name" {
  description = "The name of the SQL database."
  type        = string
}

variable "sql_admin_name" {
  description = "The name of the SQL server admin."
  type        = string
}

variable "sql_admin_pass" {
  description = "The password of the SQL server admin."
  type        = string
}

variable "firewall-rule-name" {
  description = "The name of the firewall rule."
  type        = string
}

variable "github-repo-url" {
  description = "The URL of your github repository."
  type        = string
}

variable "github-repo-branch" {
  description = "The default branch to use for your github repository."
  type        = string
}