pipeline{
  agent any  
  stages{  
      stage("Run ansible playbook"){
        steps{
        ansiblePlaybook credentialsId: 'ansible', inventory: 'hosts', playbook: 'nginx.yaml', vaultTmpPath: ''
        
        }
      }
  }
}