# AWS Infrastructure Deployment with Terraform

This repository contains Terraform configuration files to deploy an AWS infrastructure for hosting a web application. Below are the steps to deploy and destroy the solution.

Prerequisites
Before you begin, ensure you have the following tools and accounts set up:

- Terraform 1.2.*
- AWS CLI
- AWS account with the necessary permissions

------------------------------------------------------------------------------------------------------------------------------------

# Deployment Steps

1. Clone the Repository

git clone <repository_url>
cd <repository_directory>

2. Initialize Terraform

terraform init

3. Create a Terraform Execution Plan

terraform plan

4. Deploy the Infrastructure

terraform apply
Review the execution plan and enter "yes" to deploy the infrastructure.

5. Access Your Application

Once the infrastructure is deployed, you can access your application using the provided URLs or IP addresses.

Public web application: http://<public_web_url>
Load balancer: http://<load_balancer_url>

------------------------------------------------------------------------------------------------------------------------------------

# Destroying the Infrastructure

To destroy the infrastructure, use the following command:

terraform destroy
Review the execution plan and enter "yes" to destroy the infrastructure

--------------------------------------------------------------------------------------------------------------------------------------

# Software and Version Specifications

Listed below are the software and their respective versions used for this task. Make sure you have required dependencies installed before proceeding.

- **Terraform:** v1.2.9
  - An IaC tool which is used to define and manage infrastructure as code

- **AWS CLI:** v2.13.32
  - The AWS Command Line Interface used for interacting with AWS resources

- **Visual Studio Code:** v1.84.1
  - Code editor used for working with Terraform configuration files

- **Operating System:** (Compatible with Windows, macOS, and Linux)

- **AWS Account:**
  - You must have an AWS account with appropriate permissions and access keys configured.

- **AWS Region:** eu-west-2 (This configuration is set to use eu-west-2)


---------------------------------------------------------------------------------------------------------------------------------------

# NOTES

# Design choices (Thought process)

High Availability: Desiging the infrastructure for high availability, which means that the application should continue to run even if there failures. Such as Auto Scaling Groups and Elastic Load Balancers.

Multi-Availability Zone: Deploying resources across multiple Availability Zones. This is essential for redundancy, ensuring that if one Availability Zone becomes unavailable, your application can continue serving traffic from another zone.

Scalability: Anticipating increased traffic or load on the application, this design allows for adding more resources to handle this without service disruption.


# Architecture I chose (Thought process)

Virtual Private Cloud (VPC): Chose to create a VPC which isolates application's network and resources. This enchances security and isolation between other VPCs

EC2 Instance: Chosen instance type meets the application's performance and resource requirements and also cost optimised (Free tier).

Elastic Load Balancers (ALB): Chose Application Load Balancer as this is perfect for web servers on distributing incoming traffic across multiple EC2 instances, providing fault tolerance and high availability.

Security Groups & ACLs: Used security groups & ACLs to control inbound and outbound traffic to the instances. Security groups & ACLs improve security by following the principle of least privilege.

Launch Templates: Launch Templates are useful as they provide a consistent configuration for launching instances

Thoughts on how you would maintain your chosen solution, both for uptime and for new releases of the application:


# Thoughts on how you would maintain your chosen solution, both for uptime and for new releases of the application

Auto Scaling: Continue to monitor application usage and performance. Set up CloudWatch alarms to trigger scaling actions automatically. This ensures that the system can handle increased traffic without manual intervention.

Multi-Availability Zone (Multi-AZ): This protects against zone failures, enhancing system availability.

Load Balancer Health Checks: Configure the load balancer to regularly perform health checks on instances. Instances that fail health checks are automatically replaced, further improving system reliability.

Logging and Monitoring: Implement robust logging and monitoring using AWS CloudWatch. This allows for real-time visibility into the application's performance and any potential issues.

For new releases, I would implement Blue-Green Deployments: This involves creating a duplicate environment (green) and gradually shifting traffic to it while phasing out the old environment (blue). This minimizes downtime and risk during updates.

Launch Templates: Will continue using launch templates for EC2 instances, making it easy to update the base image and instance configurations for new releases.

Implement automated testing and integration pipelines to thoroughly test new releases before deploying them to the production environment. Tools like AWS CodePipeline and AWS CodeDeploy can assist in this process.

The chosen solution can be easily reused by making adjustments to the configuration files, such as the "main.tf" in our use case. You can deploy the same infrastructure in different regions or environments with minimal modifications. This reusability is a benefit of using Infrastructure as Code (IaC) tools like Terraform.


# Improvements

To improve security, I would explore options like using AWS Secrets Manager for managing sensitive application secrets, API Keys etc and AWS Identity and Access Management (IAM) roles for more granular access control. I would also look into AWS Inspector for vulnerbility checking in the entire infrastructure

For cost optimisation, I would implement cost allocation tags to track spending and leverage AWS Cost Explorer to identify opportunities for cost reduction. Having Cost reports generated weekly or monthly to be analysed

And Finally, I would develop a comprehensive disaster recovery plan to address data backup, restoration, and failover strategies in case of catastrophic failures.
