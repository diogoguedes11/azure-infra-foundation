# Azure Infrastructure Foundation (Terraform)

This repository contains the baseline **Infrastructure as Code (IaC)** for deploying an Azure Landing Zone, aligned with the **Cloud Adoption Framework (CAF)** best practices.

The code is structured modularly to ensure reusability, consistency, and ease of maintenance across environments (Dev, Prod).

## Key Features
* **Modular Architecture:** Clear separation between `modules` (logic) and `environments` (configuration).
* **Base Networking:** Implementation of VNets, Subnets, and NSGs supporting Hub-Spoke topology.
* **Disaster Recovery (DR) Ready:** Native integration with **Azure Site Recovery (ASR)** for automatic VM replication and failover orchestration between regions (e.g., West Europe ➝ North Europe).
* **Security & Compliance:** Baseline policies and Resource Groups organized by lifecycle.

## Project Structure
* `/modules`: Reusable building blocks (Compute, Network, Recovery).
* `/environments`: State definitions for each specific environment (dev, prod).

## Quick Start
```bash
cd environments/prod
terraform init
terraform plan
terraform apply