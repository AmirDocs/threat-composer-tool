
# Threat App Infrastructure Deployment on AWS with Terraform 🚀

This project is based on Amazon's Threat Composer Tool, an open source tool designed to facilitate threat modeling and improve security assessments. You can explore the tool's dashboard here: [Threat Composer Tool](https://awslabs.github.io/threat-composer/workspaces/default/dashboard)

## Project Overview📝

This end-to-end, three-tier project focuses on containerising Amazon's Threat Model application. Docker is used with multi-stage builds to optimise the containerisation process, and the resulting Docker image is uploaded to Amazon Elastic Container Registry (ECR). Infrastructure provisioning for deploying the application is managed using Terraform, with a remote S3 backend initialised to store Terraform state. All resources, including the ECS task, service, and cluster, are manually configured through Terraform. Additionally, a Virtual Private Cloud (VPC) and an Application Load Balancer (ALB) are implemented to ensure secure and efficient traffic management.

CI/CD pipelines are integrated using GitHub Actions to automate the entire workflow, including building, testing, deploying the application, and managing infrastructure changes. This automation reduces manual effort, minimises errors, and accelerates the deployment process, fostering a seamless DevOps pipeline.

![threat-composer](https://github.com/user-attachments/assets/a2430ea8-ed91-4e82-9636-506df4828487)

## Local app setup 💻

```bash
yarn install           # Installs all dependencies specified in package.json.
yarn build             # Creates an optimised production-ready build of the application.
yarn global add serve  # Installs the "serve" package globally to serve static files.
serve -s build         # Serves the production build locally using the "serve" package.

#yarn start
http://localhost:3000/workspaces/default/dashboard

## or
yarn global add serve
serve -s build
```

## Local Docker Container setup 💻🐳

```bash
# Builds a Docker image from the current directory using the Dockerfile and tags it with <image-name>.
docker build -t <image-name> .

# Runs a container from the <image-name> image in detached mode (-d), maps port 3000 of the container to port 3000 on the host, and names the container <container-name>.
docker run -d -p 3000:3000 --name <container-name> <image-name>
```

## Architecture Overview

The deployment uses the following AWS services:

- **ECS (Elastic Container Service)**: For container orchestration with Fargate for serverless computing.
- **ALB (Application Load Balancer)**: For routing HTTP and HTTPS traffic to the ECS service.
- **VPC (Virtual Private Cloud)**: For networking, including private and public subnets, NAT Gateway, and Internet Gateway.
- **Route 53**: For DNS resolution and routing traffic to the application domain.

The application is secured with **HTTPS** using a certificate managed by **AWS ACM**.

## Terraform Files Structure

The Terraform configuration consists of the following files:

1. **`VPC.tf`**: Defines the VPC, subnets, and network setup (including public and private subnets).
2. **`ALB.tf`**: Defines the Application Load Balancer, its listeners, and target groups.
3. **`ECS.tf`**: Contains the ECS cluster, task definition, and ECS service setup.
4. **`Route53.tf`**: Sets up the Route 53 DNS records for routing traffic to the ALB.
5. **`backend.tf`**: Configures the remote state backend for Terraform using an S3 bucket.
6. **`variables.tf`/`tfvars.tf`** Defines variables for reuse across the Terraform configuration.

## Prerequisites

Ensure the following before running the Terraform code:

- **AWS Account**: You need an AWS account with the necessary IAM permissions to create resources such as VPC, EC2, S3, etc.
- **Terraform**: Terraform version 1.0.0 or higher is required.
- **Docker**: Docker is required for building the container image.
- **AWS CLI**: The AWS CLI should be configured with appropriate credentials.




## Key Modules 📚

### 1. `alb.tf`

**Purpose**: Configures the Application Load Balancer (ALB) to manage and distribute incoming traffic to the ECS tasks.

**Key Components**:
- **Application Load Balancer (ALB)**: Acts as the entry point for traffic. It distributes requests evenly across ECS tasks and can scale based on demand.
- **Listeners**: Configure the ALB to listen for incoming traffic on specific ports (e.g., HTTP on port 80 and HTTPS on port 443). The listener forwards traffic to the appropriate target group.
- **Target Groups**: Define the ECS tasks as targets. The ALB uses health checks to ensure only healthy ECS tasks receive traffic.
- **Security**: Configures HTTPS with SSL certificates to encrypt communication.

**Why This Matters**:
- Ensures high availability by routing traffic to healthy instances.
- Enhances security with HTTPS.
- Improves performance through optimised traffic distribution.

---

### 2. `ecs.tf`

**Purpose**: Defines the ECS cluster, task definition, and service required to run the containerised application.

**Key Components**:
- **ECS Cluster**: A logical grouping of ECS resources, enabling efficient management of tasks.
- **Task Definition**: Specifies the Docker container image, resource requirements (CPU and memory), and network settings.
- **ECS Service**: Ensures that the desired number of task instances are always running.
- **IAM Roles**: Provide the necessary permissions for ECS tasks to interact with AWS services.
- **CloudWatch Logs**: Capture logs from ECS tasks for monitoring and debugging.

**Why This Matters**:
- Simplifies deployment of containerised applications with serverless compute (Fargate).
- Automatically scales tasks based on demand.
- Provides detailed logging for operational insights.

---

### 3. `route53.tf`

**Purpose**: Manages DNS settings to map domain names to the ALB.

**Key Components**:
- **Route 53 Hosted Zone**: Represents the domain (`amirb.uk`) and manages DNS records.
- **DNS Records**: Map subdomains (e.g., `ecs.amirb.uk`) to the ALB’s DNS name.

**Why This Matters**:
- Provides user-friendly domain names instead of IP addresses.
- Ensures seamless routing to the application with minimal latency.

---

### 4. `vpc.tf`

**Purpose**: Configures the network infrastructure, ensuring secure and efficient communication between resources.

**Key Components**:
- **VPC**: Isolates resources within a private network.
- **Subnets**: Divide the VPC into smaller segments. Public subnets host the ALB, while private subnets host ECS tasks.
- **Security Groups**: Control inbound and outbound traffic to ensure only authorised communication.
- **Internet Gateway and NAT Gateway**: Enable internet access for the ALB and ECS tasks.

**Why This Matters**:
- Provides network-level security.
- Ensures reliable communication between components.
- Optimises cost and performance by segregating public and private resources.

---

### 5. `backend.tf`

**Purpose**: Configures the backend for storing Terraform state remotely in an S3 bucket.

**Key Components**:
- **S3 Bucket**: Stores the Terraform state file securely.
- **DynamoDB Table**: Used for state locking to prevent concurrent modifications.

**Why This Matters**:
- Ensures state consistency in a collaborative environment.
- Facilitates recovery in case of local file loss.

---

### 6. `provider.tf`

**Purpose**: Specifies the AWS provider and region for Terraform.

**Key Components**:
- **AWS Provider**: Connects Terraform to the AWS account and region where resources are deployed.

**Why This Matters**:
- Establishes a connection to AWS for deploying resources.
- Ensures configurations are region-specific.

---

### 7. `variables.tf` and `terraform.tfvars`

**Purpose**: Parametrise the configuration for reusability and flexibility.

**Key Components**:
- **Variables**: Defined in `variables.tf` with default values or descriptions.
- **Variable Values**: Set in `terraform.tfvars` to customize the deployment.

**Why This Matters**:
- Makes the configuration modular and reusable.
- Simplifies updates by centralising variable management.

---

### 8. `outputs.tf`

**Purpose**: Defines outputs for critical information, such as the ALB DNS name or ECS cluster ID.

**Key Components**:
- **Outputs**: Expose key resource attributes, making them easy to reference.

**Why This Matters**:
- Simplifies access to deployed resource details.
- Reduces manual lookups in the AWS Management Console.

---

## CI/CD Workflows

The project integrates CI/CD workflows to streamline the build, deployment, and management processes. These workflows are powered by GitHub Actions and are defined in YAML files. Below are the details:

### Workflows Overview

1. **Build and Push Docker Image** 🐳  
   File: `build.yaml` 
   - **Purpose**: Builds a Docker image for the application and pushes it to Amazon ECR.
   - **Key Steps**:
     - Checks if deployment is confirmed before proceeding.
     - Configures AWS credentials for secure access.
     - Logs into Amazon ECR and builds the Docker image.
     - Pushes the image to Amazon ECR for further deployment.

2. **Terraform Build and Deploy** 🌍  
   File: `terraform-deploy.yaml`  
   - **Purpose**: Automates the deployment of infrastructure using Terraform.
   - **Key Steps**:
     - Formats and validates Terraform configurations.
     - Initialises Terraform for the project.
     - Plans and applies Terraform configurations to provision the required infrastructure.

3. **Terraform Destroy Infrastructure** 🔥  
   File: `terraform-destroy.yaml`  
   - **Purpose**: Safely destroys the Terraform-managed infrastructure.
   - **Key Steps**:
     - Checks AWS credentials and secrets.
     - Runs static analysis for Terraform files.
     - Targets and destroys specific resources such as the Route 53 subdomain before destroying all infrastructure.

### Workflow Details

#### Build and Push Docker Image (`build.yaml`) 🐳
- **Trigger**: Manual trigger with a confirmation input.
- **Components**:
  - **Checkout Code**: Ensures the latest code is used for the build.
  - **Docker Build and Push**:
    - Uses `docker/setup-buildx-action` for efficient multi-platform builds.
    - Builds the Docker image with the tag `<AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/threat_app_image:latest`.
    - Pushes the image to Amazon ECR.

#### Terraform Build and Deploy (`terraform-deploy.yaml`) 🌍
- **Trigger**: Manual trigger with confirmation.
- **Components**:
  - **Terraform Initialisation**:
    - Uses `hashicorp/setup-terraform` to set up the environment.
    - Runs `terraform init` to prepare the working directory.
  - **Validation and Formatting**:
    - Ensures Terraform files adhere to best practices.
  - **Plan and Apply**:
    - Executes `terraform plan` to create an execution plan.
    - Runs `terraform apply` to provision infrastructure.

#### Terraform Destroy Infrastructure (`terraform-destroy.yaml`) 🔥
- **Trigger**: Manual trigger with confirmation.
- **Components**:
  - **Static Analysis**:
    - Verifies the structure and syntax of Terraform files.
  - **Terraform Destroy**:
    - Targets specific resources (e.g., `aws_route53_record.threat-sub-domain`) before a complete teardown.
    - Confirms and destroys all remaining resources.

### Benefits of CI/CD Integration
- **Automation**: Reduces manual effort in building and deploying infrastructure.
- **Reliability**: Ensures consistent and repeatable deployments.
- **Security**: Utilises AWS credentials securely through GitHub secrets.
- **Scalability**: Facilitates the addition of new resources or updates to existing infrastructure with minimal disruption.

This CI/CD pipeline ensures a smooth workflow from development to deployment, complementing the Terraform modules used for infrastructure provisioning.

# Conclusion 🎯

This project demonstrates the full deployment lifecycle of a containerised application using AWS, Docker, and Terraform. The infrastructure is automated and scalable, with the ability to handle production-level traffic efficiently. Through CI/CD pipelines, updates to the application and infrastructure are seamlessly managed with minimal intervention, promoting a DevOps approach to software delivery.

## Useful links 🔗

- [Terraform AWS Registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform AWS ECS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster)
- [Terraform Docs](https://www.terraform.io/docs/index.html)
- [ECS Docs](https://docs.aws.amazon.com/ecs/latest/userguide/what-is-ecs.html)

## How to Deploy �

1. **Set up your AWS credentials**:
   Ensure your AWS CLI is configured with the necessary access.

2. **Clone the repository**:
   ```bash
   git clone https://github.com/AmirDocs/threat-composer-tool.git
   cd threat-composer-tool

## Troubleshooting 🔧
If you face issues during deployment, check the following:

- **CloudWatch Logs:** Logs from ECS tasks are sent to CloudWatch. Check the log group /ecs/threatmodel-logs for any error messages.
- **Security Groups:** Ensure that the security groups allow traffic on the necessary ports (80, 443, 3000).
- **ACM Certificate:** If you have SSL issues, ensure the ACM certificate ARN is correct and the certificate is valid.