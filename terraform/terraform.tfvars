resource_group_name = "taskboardrg"

location = "Poland Central"

app_service_plan_name = "taskboard-service-plan"

app_service_name = "taskboard-web-app"

sql_server_name = "mssql-server"

sql_db_name = "mssql-db"

sql_admin_name = "missadministrator"

sql_admin_pass = "thisIsKat11"

firewall-rule-name = "mssql-firewall-rule"

github-repo-url = "https://github.com/JekoGyulev/AzureTaskBoard-Terraform"

github-repo-branch = "master"


// For using the values of the variables , run this command: terraform apply -var-file="values.tfvars"