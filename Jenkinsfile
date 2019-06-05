pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'echo "Hello World!"'
            }
        }
        stage('Build More') {
            steps {
                sh '''
                    echo "Multiline steps works too"
                    ls -lah
                '''
            }
        }
    }
}
