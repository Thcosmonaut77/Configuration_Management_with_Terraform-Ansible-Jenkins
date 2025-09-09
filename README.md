# Ansible Infrastructure Deployment on AWS

![Ansible](https://img.shields.io/badge/Configuration-Ansible-red?logo=ansible)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazon-aws)
![Jenkins](https://img.shields.io/badge/CI/CD-Jenkins-blue?logo=jenkins)

## 📌 Project Overview
This project provisions infrastructure on **AWS with Terraform** and uses **Ansible** for configuration management.  

- Terraform creates a **Jenkins master node** and multiple **slave nodes**.  
- Master is auto-configured with **Java, Jenkins, Maven, Ansible, SSH keys, and dynamic inventory**.  
- Slaves are auto-configured with **user accounts, SSH access, and Ansible readiness**.  
- Ansible playbooks manage services like **Nginx installation** and **system updates** across the environment.  

The result is a **fully automated, idempotent, and production-ready setup** for cloud infrastructure and configuration.

---

## 🚀 Features
- Infrastructure provisioning with **Terraform**
- Automated Jenkins + Ansible bootstrap via **user_data**
- Slave nodes ready for Ansible orchestration
- Ansible playbooks for:
  - Installing and enabling **Nginx**
  - Running **system updates and reboots** when needed
- Inventory and config auto-generated on master
- Infrastructure as Code (IaC) for **repeatable, consistent deployments**

---

## 🛠️ Tools & Technologies
- **AWS** (EC2, Security Groups)
- **Terraform** (Infrastructure as Code)
- **Ansible** (Playbooks, Inventory, Config Management)
- **Jenkins** (CI/CD server)
- **Linux** (Ubuntu, systemd services)
- **Bash scripting** (automation wrappers)

---

## 📂 Repository Structure

```bash
.
│── scripts/ # Automation scripts
│ ├── ansible_master.sh # Provisions Jenkins + Ansible master
│ └── ansible_slaves.sh # Configures slave nodes
│── ec2.tf # Terraform AWS EC2 provisioning
│── variables.tf # Terraform variables
│── ansible.cfg # Ansible configuration
│── install_nginx.yaml # Playbook for Nginx setup
│── update.yaml # Playbook for system updates & reboots
│── README.md # Documentation
│── LICENSE # License file
```

## ⚙️ Usage

### 1️⃣ Provision AWS Infrastructure
Terraform automatically provisions the EC2 instances and configures:
- Jenkins master (Java, Jenkins, Maven, Ansible, SSH keys, inventory)
- Slave nodes (user setup, SSH access)

```bash
terraform init
terraform apply -auto-approve
```
Jenkins, Ansible, and SSH setup are all handled during provisioning.

2️⃣ Run Ansible Playbooks

After infrastructure is up, run playbooks directly from the Jenkins master:

• Install & start Nginx on slave nodes:
- ansible-playbook -i ansible/hosts ansible/nginx.yaml

• Update & patch systems:
- ansible-playbook -i ansible/hosts ansible/update.yaml

## License

- This project is licensed under the MIT License — See the 'LICENSE' file for full details.