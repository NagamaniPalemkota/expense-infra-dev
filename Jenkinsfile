pipeline{
    agent {
        label 'AGENT-1'
    }
    options{
        timeout(time: 30,unit: 'MINUTES')
        disableConcurrentBuilds()
        ansiColor('xterm')
    }
    parameters{
        choice(name: 'action' , choices: ['apply' , 'destroy'], description: 'pick one')
    }
    stages{
        stage('Init'){
            steps{
                sh """
                    cd 01-vpc
                    terraform init -reconfigure
                """
            }

        }
        stage('Plan'){
            when{
                expression{
                     params.action == 'apply'
                }
                }
            steps{
                sh """
                    cd 01-vpc
                    terraform plan
                """
            }
        }
        stage('Deploy'){
            when{
                expression{
                     params.action == 'apply'
                }
            }
                
            steps{
                sh """
                    cd 01-vpc
                    terraform apply -auto-approve
                """
            }
        }
         stage('Destroy'){
            when{
                expression{
                     params.action == 'destroy'
                }
            }
            steps{
                sh """
                    cd 01-vpc
                    terraform destroy -auto-approve
                """
            }
        }
        }
        post{
            always{
                deleteDir()
            }
        }
    }