<h1>Launching an EC2 Instance</h1>

### Objective: Create a VPC with public and private subnets and 1 EC2 in each subnet, configure private EC2 security group to only allow inbound SSH from public EC2 IP, SSH to the private instance using bastion host.

> ## 1. Create VPC:

- Go to VPC Dashboard
- Click "Create VPC"
- Enter:
  - Name: My-VPC
  - IPv4 CIDR: 10.0.0.0/16
  - Click Create VPC

> ## 2. Create Subnets :

- Create Public Subnet:

  - Name: Public-Subnet
  - VPC: Select the VPC you created
  - Availability Zone: Select any AZ
  - IPv4 CIDR: 10.0.1.0/24

- Create Private Subnet:
  - Name: Private-Subnet
  - VPC: Select the same VPC
  - Availability Zone: Same as public subnet
  - IPv4 CIDR: 10.0.2.0/24

> ## 3. Create Internet Gateway :

- Click "Internet Gateways"
- Create Internet Gateway
- Name it: My-IGW
- Attach it to your VPC

> ## 4. Configure Route Tables :

- Create Public Route Table:

  - Name: Public-RT
  - Associate with your VPC
  - Add route: 0.0.0.0/0 target to Internet Gateway
  - Associate with Public Subnet

- Create Private Route Table:
  - Name: Private-RT
  - Associate with your VPC
  - Associate with Private Subnet

> ## 5. Create Security Groups :

- Bastion Host Security Group:

  - Name: Bastion-SG
  - VPC: Select your VPC
  - Inbound Rules:
    - SSH (22) from your IP (for security)

- Private Instance Security Group:
  - Name: Private-Instance-SG
  - VPC: Select your VPC
  - Inbound Rules:
    - SSH (22) from Bastion-SG

> ## 6. Launch EC2 Instances :

- Bastion Host (Public Instance):

  - Launch EC2 instance
  - Choose Amazon Linux 2023
  - Instance type: t2.micro
  - Network: Your VPC
  - Subnet: Public Subnet
  - Auto-assign Public IP: Enable
  - Security Group: Bastion-SG
  - Create or select key pair

- Private Instance:
  - Launch EC2 instance
  - Choose Amazon Linux 2023
  - Instance type: t2.micro
  - Network: Your VPC
  - Subnet: Private Subnet
  - Auto-assign Public IP: Disable
  - Security Group: Private-Instance-SG
  - Use same key pair as bastion

> ## 7. SSH Connection :

```
# Copy private key to bastion host
scp -i your-key.pem your-key.pem ec2-user@<bastion-public-ip>:~/.ssh/

# SSH to bastion host
ssh -i your-key.pem ec2-user@<bastion-public-ip>

# From bastion, SSH to private instance
ssh -i ~/.ssh/your-key.pem ec2-user@<private-instance-private-ip>
```
