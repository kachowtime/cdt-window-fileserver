**Prerequsites**

The Ansible control node used for this deployment is recommended to be an Ubuntu Linux system. Ubuntu provides stable and well‑supported Ansible packages and includes native support for required dependencies such as Python, OpenSSH, and Ansible Windows collections. Using Ubuntu as the control node simplifies installation, reduces compatibility issues, and ensures consistent execution of Windows‑focused Ansible playbooks.


_Note:_ In the home repository ubuntuConfig.sh is a script that can either be preconfigured on OpenStacks or directly run on the box by -- <chmod+x ubuntuConfig.sh> <./ubuntuConfig.sh>

**Installation & Configuration**

During deployment on Windows Server 2022, Windows Defender Firewall was intentionally disabled to allow unrestricted network access to the SMB file share and related services. This was done to ensure that Ansible could configure the system without connectivity issues and to simplify exploitation and testing of the vulnerable configuration. Disabling the firewall exposes services such as SMB on port 445, making the system reachable for verification and exploitation purposes.

1. Clone the repository and change directory to the folder. 

    git clone https://github.com/kachowtime/cdt-window-fileserver.git

2. Configure inventory. Edit _inventory.ini_ with your target IP and users credentials.

3. Verify inventory connection.

    ansible windows -i inventory.ini -m win_ping

6. Run playbook.

    ansible-playbook -i inventory.ini playbook.yml

**About Anisible Playubook**

The master playbook (playbook.yml) serves as the central entry point for the deployment. It does not contain tasks directly but instead imports and executes multiple playbooks in a defined order. This structure ensures that the environment is deployed, populated, and configured with vulnerabilities in a controlled and repeatable sequence.

The deployment playbook (deploy-server.yml) is responsible for configuring the baseline Windows Server environment. It installs the Windows File Server role, creates the root directory for file shares, and creates a publicly accessible share directory. The playbook applies NTFS permissions and SMB share permissions based on values defined in the external variables file. These permissions are intentionally configured to be overly permissive to simulate a vulnerable system. The playbook also ensures that required services are enabled and running.

The population playbook (populate-server.yml) is used to place files or data into the shared directory. This may include sample documents or placeholder files that simulate sensitive or user‑generated data. Populating the share makes the environment more realistic and allows verification that read and write access is functioning as expected.

The vulnerabilities playbook (vulnerabilities-server.yml) applies insecure configurations to the system to intentionally weaken security. This may include relaxed access controls, insecure authentication settings, or other misconfigurations designed for testing and educational purposes. These changes allow the system to be used for exploitation and defensive analysis exercises.

All playbooks rely on external variable files stored in the vars/ directory. This separation allows configuration values such as paths, share names, and user permissions to be modified without changing the playbook logic. Together, this playbook structure provides a modular, repeatable, and easily verifiable deployment of a vulnerable Windows file server.

**Verification Steps**

Verification should be performed directly on the physical Windows server after the Ansible playbooks complete. Confirm that the File Server service (LanmanServer) is running using the Services console or PowerShell. Verify that the shared directory exists on the filesystem and that NTFS permissions are applied correctly. Check that the SMB share is present and accessible through Computer Management or by connecting to the share locally. Screenshots should show running services, folder permissions, and successful access to the file share.

**Troubleshooting Techniques**
1. Cannot SSH into Ubuntu deployer

    Verify that the SSH service is running on the Ubuntu control node:
    sudo systemctl status ssh

    Confirm that you are using the correct username, IP address, and SSH key or password. Test basic network connectivity to the deployer using ping <ubuntu-ip>.

2. WinRM Connection Failures

    Ensure WinRM is enabled and listening on the Windows Server 2022 target:
    winrm quickconfig

    Check firewall rules on the Windows server to allow WinRM traffic (ports 5985 for HTTP, 5986 for HTTPS).

    From the Ansible control node, test connectivity using the Ansible ping module:
    ansible windows_fileserver -i inventory.ini -m ansible.windows.win_ping

    Verify credentials in inventory.ini match the Administrator account on the target system.

3. Files Visible but Not Writable

    Validate both NTFS permissions and SMB share permissions on the target folder.
    Check directory inheritance settings to ensure permissions propagate to subfolders and files.

    Use PowerShell on Windows Server to view ACLs:

    Get-Acl,l Enter NeonPublic, [Enter]
    Get-SmbShareAccess -Name "NeonPublic"
