# **Vulnerable Windows SMB Fileserver**


## **Overview**

This project deploys an intentionally vulnerable Windows Server 2022 SMB file server using Ansible from an Ubuntu-based deployment host. The playbook automates the installation of the File Server role, creation of SMB shares, assignment of weak NTFS and share permissions, and optional exposure of legacy or insecure features.

Windows Server was chosen deliberately because SMB-based file servers remain one of the most common and high-impact targets in real-world enterprise environments. In many organizations, Windows file servers store shared documents, backups, scripts, and configuration files that are accessible to large groups of users. Misconfigurations in these systems frequently lead to credential exposure, lateral movement, and ransomware deployment, making them a consistent initial foothold or escalation point during attacks.


## **Vulnerability Description**

The primary vulnerability is an insecurely configured SMB file share on Windows Server 2022, including:

**Insecure SMB configuration on Windows Server 2022**
  - The file server is intentionally deployed with weak access controls rather than a software flaw.

**Over‑permissive NTFS and SMB share permissions**
  - Access granted to broad groups such as Everyone or BUILTIN\Users
  - Enables low‑privileged users to enumerate shares and read or modify files

**Legacy protocol exposure**
  - SMBv1 can be enabled for training purposes
  - Introduces exposure to historical vulnerabilities such as CVE‑2017‑0144 (EternalBlue) and related MS17‑010 flaws

**Exposure of sensitive artifacts**
  - SMB shares contain realistic but fake corporate files (logs, configs, credential artifacts)
  - Simulates common enterprise data leakage scenarios

**Goals**
  - SMB share enumeration
  - Credential harvesting and password reuse
  - Data exfiltration
  - Lateral movement and ransomware staging
   
## **Prerequisites**
Traditional SSH access to the Windows Server is not used. Ansible connects to the Windows target exclusively via WinRM, which is the standard management protocol for Windows systems. Disabling the Windows Firewall simplifies lab deployment and avoids WinRM connectivity issues.

**Target OS**
Windows Server 2022
- Fresh install recommended
- Local Administrator account available
- WinRM enabled (enabled by default)

**Control Machine Requirements**
OS: Linux (Ubuntu 20.04+ recommended)
- Ansible: Version 2.14+
- Python: 3.9+
- ansible-galaxy collection install ansible.windows
- ansible-galaxy collection install community.windows

**Network Requirements**
Control machine must reach Windows host over:
- TCP 5985 (WinRM HTTP)
- Windows firewall disabled
- Same network or routable subnet

**Manual Setup Before Ansible**
On the Windows Server:
- Disable ALL Windows Defender Firewall
- Ensure WinRM is enabled (on cmd: winrm quickconfig)

On the Ubuntu Contol Node:
- verify the requirments

_Note_: ubuntuConfig.sh can configure requirements on OpenStacks. This script should work, would recommend to verify or to run this script manually on SSH


## ***Quick Start***
1. SSH to Ubuntu node, verify network connection and ensure all pre-requsites are met.
   
2. Clone the repository.
   git clone https://github.com/kachowtime/cdt-window-fileserver.git

3. Configure inventory.
   Edit inventory.ini with your target IP and users credentials:

6. Verify inventory connection.
   ansible windows -i inventory.ini -m win_ping
   
7. Run playbook
   [ansible-playbook -i inventory.ini playbook.yml]

   
## **Documentation**

### Deployment Guide
Full instructions for configuring the Ubuntu control node, WinRM, inventory, and variables.

### Exploitation Guide
Windows-focused SMB enumeration and exploitation techniques.


## **Competition Use Cases**
Red Team:
- Enumerate SMB shares from Linux or Windows hosts
- Access sensitive files using weak permissions
-Stage ransomware or data theft via SMB

Blue Team:
- Detect anomalous SMB access
- Audit NTFS and share permissions
- Identify legacy protocol usage

Grey Team:
- Rapid environment resets via Ansible
- Adjustable difficulty through variables
- Realistic enterprise automation setup


## **Technical Details**

The 3 step Ansible /playbooks:

[ansible-playbook -i inventory.ini deploy-server.yml]
- Installs the File Server role
- Creates and publishes SMB shares
- Applies intentionally weak permissions
- Enables legacy SMB features

[ansible-playbook -i inventory.ini populate-server.yml]
- Populates the share with fake corporate artifacts

[ansible-playbook -i inventory.ini vulnerabilities-server.yml]
- Deploy vulnerabilities


## **Troubleshooting**

Cannot SSH into Ubuntu deployer
- Verify SSH service and credentials
- Confirm network connectivity

WinRM connection failures
- Ensure WinRM is enabled and listening
- Check firewall rules on Windows Server
- Verify that Ansible can communicate with the Windows file server over WinRM using -- ansible windows -i inventory.ini -m win_ping
  
Files visible but not writable
- Validate both NTFS and share permissions
- Check inheritance settings on directories
