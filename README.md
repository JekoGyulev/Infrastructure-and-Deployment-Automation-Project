# Infrastructure and Deployment Automation Project

![Azure](https://img.shields.io/badge/Azure-0078D4?style=for-the-badge&logo=microsoftazure&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![C#](https://img.shields.io/badge/C%23-239120?style=for-the-badge&logo=csharp&logoColor=white)
![.NET](https://img.shields.io/badge/.NET-512BD4?style=for-the-badge&logo=dotnet&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)

A full-stack ASP.NET Core web application integrated with a fully automated cloud infrastructure pipeline. The project provisions all required Azure resources using **Terraform** (Infrastructure as Code) and deploys the application automatically via **GitHub Actions** CI/CD — with zero manual steps after initial configuration.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [CI/CD Pipeline](#cicd-pipeline)
- [Infrastructure (Terraform)](#infrastructure-terraform)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration & Secrets](#configuration--secrets)
- [How It Works](#how-it-works)

---

## Overview

This project demonstrates a real-world **DevOps workflow** where application code and cloud infrastructure are managed together as code. The key goals are:

- **Reproducibility** — the entire Azure environment can be created or destroyed with a single command.
- **Automation** — every push to the main branch triggers a pipeline that builds, tests, provisions infrastructure, and deploys the application.
- **Separation of concerns** — application logic (`TaskBoard.WebApp`, `TaskBoard.Data`) is cleanly decoupled from infrastructure configuration (`terraform/`).

The application itself is a **Task Board** — a web-based tool for managing and tracking tasks, built with ASP.NET Core MVC and backed by a relational database.

---

## Architecture

```
Developer pushes code
        │
        ▼
┌──────────────────┐
│  GitHub Actions  │  ← CI/CD Pipeline (.github/workflows/)
│  Workflow        │
└────────┬─────────┘
         │
┌───────▼─────────────┐               ┌─────────────────────────────────┐
│  Terraform          │               │         Microsoft Azure         │
│  Init, Plan, Apply  │               │                                 │ 
└─────┬───────────────┘               │     ┌─────────────────────────┐ │
         │                            │     │  Azure App Service      │ |
┌─────▼───────┐   Deploy              │     │  (ASP.NET Core WebApp)  │ │
│  Build      │───────────────────►   │     └─────────────────────────┘ │
│  Deploy     │                       │                                 │
└─────────────┘                       │     ┌─────────────────────────┐ │
                                      │     │  Azure SQL Database     │ │
                                      │     │  (App Data)             │ │
                                      │     └─────────────────────────┘ │
                                      └─────────────────────────────────┘
```

---

## Tech Stack

| Category | Technology |
|---|---|
| **Application Framework** | ASP.NET Core MVC (.NET) |
| **Language** | C# |
| **Frontend** | HTML, CSS, JavaScript |
| **ORM / Data Layer** | Entity Framework Core |
| **Cloud Provider** | Microsoft Azure |
| **Infrastructure as Code** | Terraform (HCL) |
| **CI/CD** | GitHub Actions |
| **Database** | Azure SQL Database |
| **Hosting** | Azure App Service |

---

## Project Structure

```
├── .github/
│   └── workflows/           # GitHub Actions CI/CD pipeline definitions
├── TaskBoard.Data/          # Data layer — Entity Framework models, DbContext, migrations
├── TaskBoard.WebApp/        # ASP.NET Core MVC web application (controllers, views, services)
├── terraform/               # Terraform configuration files for Azure infrastructure
├── TaskBoard.sln            # Visual Studio solution file
└── .gitignore
```

### Key Directories

**`TaskBoard.WebApp/`** — The main web application project. Contains controllers, Razor views, static assets (CSS/JS), and application startup configuration.

**`TaskBoard.Data/`** — The data access layer. Defines the Entity Framework Core `DbContext`, entity models, and database migrations. Keeping this in a separate project enforces clean architecture.

**`terraform/`** — All infrastructure is defined here as code. Terraform reads these `.tf` files to provision and manage Azure resources. No infrastructure is created or changed manually in the Azure portal.

**`.github/workflows/`** — GitHub Actions workflow YAML files that automate building, testing, and deploying the application on every relevant Git event.

---

## CI/CD Pipeline

The GitHub Actions pipeline automates the full delivery lifecycle:

1. **Trigger** — The pipeline is triggered automatically on a push or pull request to the `master` branch.
2. **Terraform Init & Plan** — Terraform initialises its backend and computes the infrastructure changes required.
3. **Terraform Apply** — Azure resources are provisioned or updated automatically.
4. **Build & Publish** — The .NET application is built using the .NET CLI (`dotnet restore`, `dotnet publish`).
5. **Deploy** — The compiled application is deployed to Azure App Service (`azure/webapps-deploy@v2`)



---

## Infrastructure (Terraform)

All Azure resources are defined declaratively in the `terraform/` directory. Terraform ensures the infrastructure is always in the desired state, and any changes are version-controlled alongside the application code.

**Resources provisioned include:**

- **Resource Group** — logical container for all project resources.
- **Azure App Service Plan** — defines the compute tier for hosting the web application.
- **Azure App Service** — hosts the ASP.NET Core web application.
- **Azure SQL Server & Database** — persistent relational database for the Task Board data.
- **Connection String Configuration** — App Service is automatically configured with the database connection string as an environment variable.
- **Firewall Rule** - defines the firewall rule so that the database can communicate with the server in Azure.

**Terraform workflow (locally):**

```bash
cd terraform/

# Format the terraform configuration file
terraform fmt

# Initialise providers and backend
terraform init

# Validate the terraform configuration file
terraform validate

# Preview changes
terraform plan

# Apply changes to Azure
terraform apply

# Tear down all resources (when no longer needed)
terraform destroy
```

---

## Prerequisites

Before running this project locally or setting it up in your own environment, ensure you have the following installed and configured:

| Tool | Purpose | Download |
|---|---|---|
| [.NET SDK](https://dotnet.microsoft.com/download) (6.0+) | Build and run the application | dotnet.microsoft.com |
| [Terraform CLI](https://developer.hashicorp.com/terraform/install) (1.0+) | Provision Azure infrastructure | developer.hashicorp.com |
| [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) | Authenticate with Azure locally | learn.microsoft.com |
| An **Azure Subscription** | Cloud resources are deployed here | portal.azure.com |
| A **GitHub account** | Required to fork and run the pipeline | github.com |

---

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/JekoGyulev/Infrastructure-and-Deployment-Automation-Project.git
cd Infrastructure-and-Deployment-Automation-Project
```

### 2. Log in to Azure

```bash
az login
az account set --subscription "<your-subscription-id>"
```

### 3. Provision infrastructure with Terraform

```bash
cd terraform
terraform fmt
terraform init
terraform validate
terraform plan
terraform apply
```

Terraform will output the App Service URL and other resource details upon completion.

### 4. Run the application locally (optional)

```bash
cd TaskBoard.WebApp
dotnet restore
dotnet run
```

The application will be available at `http://localhost:5001` by default.

---

## Configuration & Secrets

The GitHub Actions pipeline requires the following **repository secrets** to authenticate with Azure and deploy the application. Set these under **Settings → Secrets and variables → Actions** in your GitHub repository:

| Secret Name | Description |
|---|---|
| `AZURE_CREDENTIALS` | Azure Service Principal credentials (JSON) used by Terraform and GitHub Actions to authenticate with Azure |
| `AZURE_SUBSCRIPTION_ID` | Your Azure Subscription ID |
| `AZURE_CLIENT_ID` | Service Principal Client ID |
| `AZURE_CLIENT_SECRET` | Service Principal Client Secret |
| `AZURE_TENANT_ID` | Azure Active Directory Tenant ID |

**Creating an Azure Service Principal:**

```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role Contributor \
  --scopes /subscriptions/<your-subscription-id> \
  --sdk-auth
```

Copy the JSON output and add it as the `AZURE_CREDENTIALS` secret in GitHub.

---

## How It Works

The project follows a **GitOps** approach — the Git repository is the single source of truth for both the application and the infrastructure.

1. A developer commits and pushes code changes to the `master` branch.
2. GitHub Actions detects the push and starts the workflow.
3. The application is compiled and any tests are executed.
4. Terraform connects to Azure (using the Service Principal credentials stored as secrets) and ensures the infrastructure matches the desired configuration.
5. The built application artifact is published to Azure App Service.
6. The live application is updated — with no manual intervention required.

This setup ensures that **every environment is consistent**, **deployments are repeatable**, and **infrastructure drift is prevented**.

---

*This project was built to demonstrate practical DevOps skills including Infrastructure as Code, CI/CD pipeline design, cloud deployment, and clean application architecture.*
