pipeline{
    agent {
        label 'AGENT-1'
    }
    options{
        timeout(time: 30,unit: 'MINUTES')
        disableConcurrentBuilds()
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
            steps{
                sh """
                    cd 01-vpc
                    terraform plan
                """
            }
        }
        stage('Deploy'){
            input{
                message "should we continue?"
                ok "Yes.."
            }
            steps{
                sh """
                    cd 01-vpc
                    terraform apply -auto-approve
                """
            }
        }
        }
    }