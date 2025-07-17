

<img width="1200" height="627" alt="image" src="https://github.com/user-attachments/assets/f692ad33-f205-4d47-9e48-938c2d81326c" />

![opennebula_cloud_logo_white_bg](https://github.com/user-attachments/assets/130bcaad-6b90-4adc-9971-dcc93c0a1fe5)  

# Deployment Guide


## 🏗️ Target OpenNebula Architecture
This section describes the target architecture based on OpenNebula, deployed on Scaleway Elastic Metal instances.

### Objectives:
Deliver a full IaaS infrastructure on bare-metal servers.

#### Core Components:
OpenNebula Front-end (with KVM):

Manages VM lifecycle, networking, and storage and provides Opennebula Frontend.
Also runs local virtual machines (acts as a compute node).

#### Hypervisor Nodes:

EM-A610R-NVMe instances running KVM.
Connected to private network for internal communication.
Can also be attached to Public IP for providing access to VM.

#### Storage:

Local NVMe SSDs on each node.

### Networking:

Virtual Network using Private Networks in VPC.
For high traffic Public gateway is the goto, but for one deploy and MVP Public IP directly attached to instances via NIC.

<img width="2080" height="944" alt="image" src="https://github.com/user-attachments/assets/bc13e49d-8c84-4055-80a5-29278e3375c1" />


### High-Level Diagram:

<img width="1953" height="932" alt="image" src="https://github.com/user-attachments/assets/c17945c5-d3f5-4e08-a7c1-ff42bba3365e" />


### Hardware Specification
Elastic Metal Instances – EM-A610R-NVMe

| Role            | Instance Type | CPU                           | RAM   | Disks          | KVM | Count      | Bandwitdh     |
| --------------- | ------------- | ----------------------------- | ----- | -------------- | --- | ---------- | ------------- |
| Front-end + KVM | EM-A610R-NVMe | AMD Ryzen PRO 3600 (6C / 12T) | 16 GB | 2× NVMe 960 GB | Yes | 1          | Up to 1 Gbp/s |
| Hypervisor(s)   | EM-A610R-NVMe | AMD Ryzen PRO 3600 (6C / 12T) | 16 GB | 2× NVMe 960 GB | Yes | 1 to any   | Up to 1 Gbp/s |   


### Provisioning Strategies 

#### Usage of one deploy and one deploy validation hook

Deployment can be done using onedeploy hook as per theses documentations 
* https://github.com/OpenNebula/one-deploy-validation/tree/master
* https://github.com/OpenNebula/one-deploy
  
This hook is rely on ansible scaleway provider
https://docs.ansible.com/ansible/latest/collections/community/general/docsite/guide_scaleway.html#ansible-collections-community-general-docsite-guide-scaleway


