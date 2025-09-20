# Ansible Infrastructure Deployment on AWS

![Ansible](https://img.shields.io/badge/Configuration-Ansible-red?logo=ansible)
![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)
![AWS](https://img.shields.io/badge/Cloud-AWS-FF9900?logo=amazon-aws)
![Jenkins](https://img.shields.io/badge/CI/CD-Jenkins-blue?logo=jenkins)

##  Project Overview
This project provisions and configures a **Jenkins + Ansible** automation environment on **AWS** using **Terraform** and **Ansible**.  

- Terraform provisions a **Jenkins master node** and multiple **slave nodes** with **user_data** scripts.  
- Master is auto-configured with **Java, Jenkins, Ansible, SSH key pair generation, ansible.cfg, ansible playbooks, and dynamic inventory**.  
- Slaves are auto-configured with **user password, SSH access, and Ansible readiness**.  
- Ansible playbooks manage services like **Nginx installation** and **system updates** across the environment.  
- A **Jenkins pipeline** is created to automatically trigger **Ansible playbooks** for configuration management.

The result is a **self-contained DevOps lab** where **infrastructure, configuration, and CI/CD workflows** are fully automated and production-ready.

---

##  Features
- Infrastructure provisioning with **Terraform**
- Automated Jenkins + Ansible bootstrap via **user_data**
- SSH key-based authentication between master and slaves
- Pre-configured Ansible inventory and configuration file
- Ansible playbooks for:
  - Installing and enabling **Nginx**
  - Running **system updates and reboots** when needed
- Jenkins pipeline to orchestrate Ansible tasks across nodes
- Infrastructure as Code (IaC) for **repeatable, consistent deployments**

---

##  Tools & Technologies
- **AWS** (EC2, Security Groups)
- **Terraform** (Infrastructure as Code)
- **Ansible** (Playbooks, Inventory, Config Management)
- **Jenkins** (Pipeline automation)
- **Linux** (Ubuntu, systemd services)
- **Bash scripting** (automation wrappers)

---

##  Repository Structure

```bash
.
├── scripts/                # Automation scripts
│   ├── ansible_master.sh   # Bootstraps Jenkins + Ansible master node
│   └── ansible_slaves.sh   # Configures slave nodes
├── ec2.tf                  # Terraform AWS EC2 provisioning
├── variables.tf            # Terraform variables
├── ansible.cfg             # Ansible configuration
├── hosts                   # Auto-generated Ansible inventory
├── install_nginx.yaml      # Playbook for Nginx setup
├── update.yaml             # Playbook for system updates & reboots
├── Jenkinsfile             # Jenkins pipeline definition
├── README.md               # Documentation
└── LICENSE                 # License file

```

##  Usage

### 1️⃣ Provision AWS Infrastructure
Terraform automatically provisions the EC2 instances and configures:
- Jenkins master (Java, Jenkins, Ansible, SSH keys, inventory)
- Slave nodes (user setup, SSH access)

```bash
terraform init
terraform apply -auto-approve
```
Jenkins, Ansible, and SSH setup are all handled during provisioning.

### 2️⃣ Run Ansible Playbooks

After infrastructure is up, run playbooks directly from the Jenkins master:

• Install & start Nginx on slave nodes:
- ansible-playbook -i ansible/hosts ansible/nginx.yaml

• Update & patch systems:
- ansible-playbook -i ansible/hosts ansible/update.yaml

Jenkins can also be used to automate and schedule these playbooks.

## License

- This project is licensed under the MIT License — See the 'LICENSE' file for full details.