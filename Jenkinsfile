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

                """
            }

        }
        stage('Plan'){
            steps{
                sh 'echo "This is from Plan stage"'
            }
        }
        stage('Deploy'){
            steps{
                sh 'echo "This is from Deploy stage"'
            }
        }
         stage('Example') {
            steps {
                echo "Hello ${params.PERSON}"
                echo "Biography: ${params.BIOGRAPHY}"
                echo "Toggle: ${params.TOGGLE}"
                echo "Choice: ${params.CHOICE}"
                echo "Password: ${params.PASSWORD}"
            }
        }
    }
}