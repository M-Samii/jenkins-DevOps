pipeline {
    agent {
        label 'slave-1'  // Change to your Jenkins agent label
    }
    

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-1'  // Change to your region
      //  REPO_URL              = 'https://github.com/mina-safwat-1/jenkins-devops-project'
        DOCKER_IMAGE_TAG     = 'latest'
       // ANSIBLE_INVENTORY    = 'ansible/node_app/inventory.ini'  // Path to your Ansible inventory
        DB_PASSWORD        = credentials('DB_PASSWORD')  // Assuming you have a Jenkins credential for DB password
        DB_USERNAME       = credentials('DB_USERNAME')  // Assuming you have a Jenkins credential for DB password
    }

    options {
        skipDefaultCheckout(false)  //to automatically checkout the repo
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }


    stages {

        stage('Setup SSH Key') {
            steps {
                withCredentials([sshUserPrivateKey(
                    credentialsId: 'ansible-ssh-key',  // Jenkins credential ID
                    keyFileVariable: 'SSH_KEY_FILE'
                )]) {
                    script {
                        // Make key readable only by current user
                        sh """
                            mkdir -p ~/.ssh
                            cp ${SSH_KEY_FILE} ~/.ssh/private.pem
                            chmod 400 ~/.ssh/private.pem
                        """
                    }
                }
            }
        }

        // STAGE 2: Terraform (init & apply)
        stage('Terraform Apply') {
            steps {
                dir('terraform') {  // Changes directory to terraform/
                    script {
                        sh 'terraform init'
                        sh 'terraform apply -var-file vars.tfvars -var "db_password=${DB_PASSWORD}" -var "db_username=${DB_USERNAME}" -auto-approve'
                    }
                }
            }
}


        stage('Get ECR URL and Repo Name') {
            steps {
                dir('terraform') {  // Changes directory to terraform/
                script {
                    // Fetch ECR repository URL from Terraform output
                    REGISTRY = sh(
                        script: 'terraform  output -raw aws_ecr_repository | cut -d "/" -f1',
                        returnStdout: true
                    ).trim()
                    
                    // Fetch ECR repository name from Terraform output
                    REPOSITORY = sh(
                        script: 'terraform  output -raw aws_ecr_repository | cut -d "/" -f2',
                        returnStdout: true
                    ).trim()


                    REDIS_HOSTNAME = sh(
                        script: 'terraform  output -raw redis_endpoint',
                        returnStdout: true
                    ).trim()



                    RDS_HOSTNAME = sh(
                        script: 'terraform  output -raw mysql_endpoint | cut -d ":" -f1',
                        returnStdout: true
                    ).trim()

                    NODE_APP_IP = sh(
                        script: 'terraform output -raw node_app_ip',
                        returnStdout: true
                    ).trim()


                    env.REDIS_HOSTNAME = REDIS_HOSTNAME
                    env.RDS_HOSTNAME = RDS_HOSTNAME
                    env.NODE_APP_IP = NODE_APP_IP
                    env.REPOSITORY = REPOSITORY
                    env.REGISTRY = REGISTRY

                    // echo "ECR Registry: ${env.REGISTRY}"
                    // echo "ECR Repository: ${env.REPOSITORY}"
                    // echo "Redis Host: ${env.REDIS_HOSTNAME}"
                    // echo "RDS Host: ${env.RDS_HOSTNAME}"
                    // echo "Node App IP: ${env.NODE_APP_IP}"

                }
            }
        }
        }

        // // STAGE 3: Login to ECR, Build & Push Docker Image
        stage('Build and Push Docker Image') {
            steps {
                dir('nodeapp') {  // Changes directory to terraform/
                script {
                    // Login to AWS ECR
                    echo "Building Docker image for ${env.REGISTRY}/${env.REPOSITORY}:${DOCKER_IMAGE_TAG}"

                    sh  "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | sudo docker login --username AWS --password-stdin ${env.REGISTRY}"

                    // Build Docker image
                    sh "sudo docker build -t ${env.REGISTRY}/${env.REPOSITORY}:${DOCKER_IMAGE_TAG} ."

                    // Push to ECR
                    sh "sudo docker push ${env.REGISTRY}/${env.REPOSITORY}:${DOCKER_IMAGE_TAG}"
                }
            }
        }
        }

        stage('Prepare Inventory') {
            steps {
                dir('ansible/node_app') {
                    script {
                        def inventoryContent = """[ubuntu_servers]
server1 ansible_host=${env.NODE_APP_IP} ansible_user=ubuntu"""

                        writeFile(
                            file: 'hosts.ini',
                            text: inventoryContent.trim()
                        )
                    }
                }
            }
        }

        // STAGE 4: Run Ansible Playbook on Application Node
        stage('Deploy with Ansible') {
            steps {
                dir('ansible/node_app') {  // Changes directory to terraform/
                script {
                    // Run Ansible playbook
                    sh "ansible-playbook -i hosts.ini  ansible.yml --extra-vars 'REGISTRY=${env.REGISTRY} REPOSITORY=${env.REPOSITORY} RDS_USERNAME=${DB_USERNAME} RDS_PASSWORD=${DB_PASSWORD} REDIS_HOSTNAME=${env.REDIS_HOSTNAME} RDS_HOSTNAME=${env.RDS_HOSTNAME}' "
                }
            }
        }
    }

    stage('print load balancer DNS') {
            steps {
                dir('terraform') {  // Changes directory to terraform/
                script {
                    LB_DNS = sh(
                        script: 'terraform output -raw lb_url',
                        returnStdout: true
                    ).trim()
                    echo "Load Balancer DNS: ${LB_DNS}"

                }
            }
        }
        }
    }

    post {
        always {
            // Clean up workspace (optional)
            // cleanWs()
            sh """
            rm -f ~/.ssh/private.pem
            """

        }
        failure {
            // Notify on failure (Slack, Email, etc.)
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}