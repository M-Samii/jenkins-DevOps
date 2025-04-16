🔧 DevOps Project: Jenkins CI/CD with Node.js App on Private EC2 via Bastion

🗂️ Project Structure
Terraform: Provisions infrastructure including private EC2, bastion host, and ALB.

Ansible: Configures the EC2 instance to run as a Jenkins slave.

Jenkins: Manages CI/CD pipelines to build and deploy the Node.js app.

⚙️ Infrastructure Components
Bastion Host (Public)

Application EC2 (Private, Jenkins agent, Node.js app host)

Jenkins Controller (Accessible from browser, e.g., on port 8080)

🔐 SSH Configuration (~/.ssh/config)
Configure your SSH to route through the bastion host:

ssh
Copy
Edit
Host bastion
  HostName 54.166.71.43
  User ubuntu
  IdentityFile ~/.ssh/test.pem

Host ansible-slave
  HostName 172.31.80.123
  User ubuntu
  IdentityFile ~/.ssh/test.pem
  ProxyJump bastion

Host node-app
  HostName 172.31.80.123
  User ubuntu
  IdentityFile ~/.ssh/test.pem
  ProxyJump bastion


📦 Ansible Setup
Use Ansible to configure the private EC2 instance as a Jenkins slave:

Inventory File (inventory.ini)
Run the playbook:

    ansible-playbook -i inventory.ini configure_jenkins_slave.yml
  
🧪 Jenkins Configuration
    Go to Jenkins Dashboard → Manage Jenkins → Nodes → New Node
    
    Add a new node named private with:
    
    Remote root directory: /home/ubuntu/jenkins
    
    Launch method: WebSocket

IP: 172.31.80.123 (private IP)

🚀 CI/CD Pipeline Setup
Create a pipeline to deploy nodejs_example from the rds_redis branch.

🔌 Port Forwarding from Bastion
To expose local services via the bastion:

    ssh -i ~/.ssh/test.pem -R 8080:localhost:8080 ubuntu@3.91.184.224 -N
Edit /etc/ssh/sshd_config on bastion:

    GatewayPorts yes
    AllowTcpForwarding yes
Then restart SSH:
sudo systemctl restart sshd

✅ Testing the Application

http://<loadbalancer_url>/db — to verify RDS connection.

http://<loadbalancer_url>/redis — to verify Redis integration.
