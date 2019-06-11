
pipeline {

    environment {
      registry = "mattmyers3491/jenkins-docker"
      registryCredential = 'dockerhub'
    }

    agent none

    parameters {
      string(name: 'gocode', defaultValue: '*.go')
      string(name: 'dockerfile_Build', defaultValue: 'build.Dockerfile')
      string(name: 'dockerfile_Deploy', defaultValue: 'deploy.Dockerfile')
      string(name: 'docker_compose_setup', defaultValue: 'docker-compose-setup.yml')
      string(name: 'docker_compose_deploy', defaultValue: 'docker-compose-deploy.yml')
      string(name: 'DEPLOY_MODE', defaultValue: 'local')
    }
    stages {

        stage('Build and Test') {
          agent { label 'worker' }
          stages {
              stage('Checkout') {
                  steps {
                      checkout scm
                  }
              }

              stage('Build') {
                  steps {
                      // setup container for testing

                      // dockerfile should be scaled down just for tests
                      //=> build.Dockerfile
                      script {
                        customImage = docker.build(registry,"-f ${dockerfile_Build} ./test" )
                      }
                  }
              }

              stage('Unit Test') {
                  steps {
                      // Unit Testing here
                      try {
                        // echo 'Unit tests'
                        // sh 'docker-compose -f test.yml up -d --build --remove-orphans'
                        // sh 'sleep 5'
                        // sh 'docker-compose -f test.yml exec -T fpm_test bash build/php_unit.sh'

                        script {
                          customImage.inside {
                              sh 'echo "running tests"'
                              // sh 'go fmt ${gocode}'/*Format code*/
                              // sh 'go vet'/*reports suspicious constructs*/
                              // sh 'goapp test'
                              // sh 'go test -cover' /*check code coverage*/
                              // sh 'go test -cover -coverprofile=c.out'/*html coverage report*/
                              // sh 'go tool cover -html=c.out -o coverage.html'
                          }
                        }

                        // Need to output coverage tests
                        // to be processed by jenkins???
                        // needs junit xml format

                      }
                      catch(e){
                        echo "Caught: ${e}"
                        currentBuild.result = 'FAILURE'
                        error "Unit Test failed"
                      }finally{
                        //????
                      }
                  }
              }

              stage ('Integration Test') {
                // infrastructure test performed on specific testing node (docker node)
                // node needs to be setup to support infrastructure tests
                steps {
                  try {

                  }
                  catch(e){
                    echo "Caught: ${e}"
                    currentBuild.result = 'FAILURE'
                    error "Integration Test failed"
                  }finally{
                    //?????
                  }
                }
              }

              stage ('Quality Analysis') {
                  steps {
                    // SonarQube
                    sh 'echo "performing Quality Analysis"'

                  }
              }

              stage('Publish') {
                  steps {
                      echo 'push docker image'

                      script {
                        docker.withRegistry('https://registry.hub.docker.com', registryCredential) {
                          customImage.push("${env.BUILD_NUMBER}")
                          customImage.push("latest")
                        }
                      }

                  }
              }

              stage ('Approval') {
                steps {
                  slackSend channel: 'app_updates', color: 'good', message: "Attention: Approval for job: ${env.JOB_NAME} #${env.BUILD_NUMBER} required for deployment."

                  timeout(time:3, unit:'DAYS') {
                    input 'Approval required for deployment?'
                  }
                }
              }
            }
          }

        stage('Deploy Local'){
          //change to { label local }
          agent { label 'worker' }
          when {
            equals expected: local,
            actual: DEPLOY_MODE
            beforeAgent true
          }
          steps {
              //docker compose to simulate existing infrastructure
              sh 'docker-compose -f ${docker_compose_setup} up -d --build'
              // change nginx conf to allow blue green deployment
              // docker compose up
              // publish to a docker swarm set of nodes
              // make sure that compose pulls the tested and newly uploaded image
              sh 'export image_name=${registry}:${env.BUILD_NUMBER}'
              //docker compose to deploy new version
              sh 'docker-compose -f ${docker_compose_deploy} up -d --build'
          }
        }

        stage('Deploy Production'){
          //change to { label production }
          agent { label 'worker' }
          when {
            equals expected: production,
            actual: DEPLOY_MODE
            beforeAgent true
          }
          steps {
            // change nginx conf to allow blue green deployment
            // docker compose up
            // publish to a docker swarm set of nodes
            // make sure that compose pulls the tested and newly uploaded image
            sh 'export image_name=${registry}:${env.BUILD_NUMBER}'
            //docker compose to deploy new version
            sh 'docker-compose -f ${docker_compose_deploy} up -d --build'
          }
        }

        post {
          always {
            /* clean up our workspace */
            deleteDir()
            // is this needed?
            // sh 'echo "Remove Unused docker image"'
            // sh "docker rmi $registry:$BUILD_NUMBER"
            // sh "docker-compose down --rmi all"
          }
          changed {
            echo 'Things were different before...'
          }
          failure {
            slackSend channel: 'app_updates', color: 'good', message: "Attention: ${env.JOB_NAME} #${env.BUILD_NUMBER} has failed."
          }
          success {
            slackSend channel: 'app_updates', color: 'good', message: "The pipeline ${currentBuild.fullDisplayName} completed successfully."
          }
          unstable {
            echo 'I am unstable :/'
          }
        }
      }
}
