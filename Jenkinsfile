
pipeline {

    environment {
      registry = "mattmyers3491"
      registryCredential = "dockerhub"
      image = "jenkins-test"
      curr_image = "${registry}/${image}:${env.BUILD_ID}"
    }

    agent none

    parameters {
      string(name: 'gocode', defaultValue: '*.go')
      string(name: 'dockerfile_Build', defaultValue: 'build.Dockerfile')
      string(name: 'dockerfile_Deploy', defaultValue: 'deploy.Dockerfile')
      string(name: 'docker_compose_main', defaultValue: 'docker-compose.yml')
      string(name: 'docker_compose_override', defaultValue: 'docker-compose.override.yml')
      string(name: 'docker_compose_prod', defaultValue: 'docker-compose.production.yml')
      string(name: 'LOCAL_TEST', defaultValue: 'true')
      string(name: 'DEPLOY_MODE', defaultValue: 'local')
      string(name: 'DEPLOY_VERS', defaultValue: 'blue')
      string(name: 'DEPLOY_PORT', defaultValue: '8060')
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

              stage('Launch') {
                  when {
                    equals expected: 'true',
                    actual: LOCAL_TEST
                  }
                  steps {
                    //start all services
                      echo "Launch Services"
                      sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_override} up -d"

                      //check if consul server is running
                      sh '''
                        echo "Attempting to connect to consul"
                        until $(nc -zv 192.168.60.10 8500); do
                        printf '.'
                        sleep 5
                        done
                      '''
                      //create consul Keys
                      sh '''
                        curl -X PUT -d 0 http://localhost:8500/v1/kv/prod/blue_weight
                        curl -X PUT -d 1 http://localhost:8500/v1/kv/prod/green_weight
                        curl -X PUT -d 0 http://localhost:8500/v1/kv/prod/start_web
                      '''
                      // reload consul template to read key entries and update nginx.conf
                      sh 'docker exec proxy killall -SIGHUP consul-template'

                      // check key value
                      def blue
                      def green
                      sh '''
                        blue = curl -XGET 'http://localhost:8500/v1/kv/prod/blue_weight?raw=1'
                        green = curl -XGET 'http://localhost:8500/v1/kv/prod/green_weight?raw=1'
                      '''
                      echo "blue values is: $blue"
                      echo "green values is: $green"

                      script {
                        error "exit "
                      }

                  }
              }

              stage('Build') {
                  steps {


                      //CHECK CURRENT
                      // 1) check nginx file for current deploy-vers
                      //
                      // shield user from blue/green states
                      // applying weight to new version should shield user from whether blue or green
                      // should do this via bash script e.g old_vers=4, new_vers=1
                      //
                      // 2) update nginx file with consul-template info
                      // 3) create keys
                      //
                      // 4) query consul key states of prod/green_weight and prod/blue_weight
                      //     - if both are greater than/equal 1: send alert message
                      //     -
                      //     - set variable CURRENT_STATE based on nginx analysis to BLUE or GREEN
                      // // setup container for testing
                      //
                      // curl -X PUT -d 1 http://localhost:8500/v1/kv/prod/blue_weight
                      //
                      // curl -X PUT -d 0 http://localhost:8500/v1/kv/prod/green_weight
                      //
                      // curl -X PUT -d 0 http://localhost:8500/v1/kv/prod/start_web
                      //
                      // curl -XGET 'http://localhost:8500/v1/kv/prod/blue_weight?raw=1'
                      //
                      // //run command inside container
                      // docker exec blue scripts/var_kv.sh st=1 v1=1 v2=0
                      //
                      // docker exec -it blue echo "Hello from container!"

                      script {
                        try {
                          customImage = docker.build("${registry}/${image}:${env.BUILD_ID}","--build-arg build_name=${DEPLOY_VERS} --build-arg build_port=${DEPLOY_PORT}  -f ${dockerfile_Build} ." )
                        }
                        catch(e){
                          echo "Caught: ${e}"
                          currentBuild.result = 'FAILURE'
                          error "Build stage failed"
                        }
                        finally{

                        }
                      }
                  }
              }

              stage('Unit Test') {
                  steps {
                      // Unit Testing here
                      script {
                        try {
                          echo 'Unit tests'
                          // sh 'docker-compose -f test.yml up -d --build --remove-orphans'
                          // sh 'sleep 5'
                          // sh 'docker-compose -f test.yml exec -T fpm_test bash build/php_unit.sh'

                            customImage.inside {
                                echo 'running tests'
                                // sh 'go fmt ${gocode}'/*Format code*/
                                // sh 'go vet'/*reports suspicious constructs*/
                                // sh 'goapp test'
                                // sh 'go test -cover' /*check code coverage*/
                                // sh 'go test -cover -coverprofile=c.out'/*html coverage report*/
                                // sh 'go tool cover -html=c.out -o coverage.html'
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
              }

              stage ('Integration Test') {
                // infrastructure test performed on specific testing node (docker node)
                // node needs to be setup to support infrastructure tests
                steps {
                  script {
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
              }

              stage ('Quality Analysis') {
                  steps {
                    // SonarQube
                    echo 'performing Quality Analysis'
                  }
              }

              stage('Publish') {
                  steps {
                      echo 'push docker image'
                      script {
                        try {
                          docker.withRegistry('', registryCredential) {
                            customImage.push("${env.BUILD_NUMBER}")
                            customImage.push("latest")
                          }
                        }
                        catch(e){
                          echo "Caught: ${e}"
                          currentBuild.result = 'FAILURE'
                          error "Publish failed"
                        }finally{

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
            equals expected: 'local',
            actual: DEPLOY_MODE
            beforeAgent true
          }
          steps {
              echo 'Deploy local'
              //first: deploy docker compose to simulate existing infrastructure
              // change nginx conf to allow blue green deployment
              // docker compose up
              // publish to a docker swarm set of nodes
              // make sure that compose pulls the tested and newly uploaded image

              //make sure env variables are correct in docker-compose files
              // NGINX_SERVER_NAME
              // NODE_NAME
              // BIND_IP

              sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_override} build blue"
              sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_override} up --no-deps -d blue"

              sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_override} build green"
              sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_override} up --no-deps -d green"

              // script {
              //   currentBuild.result = 'SUCCESS'
              // }

          }
        }

        stage('Deploy Production'){
          //change to { label production }
          agent { label 'worker' }
          when {
            equals expected: 'production',
            actual: DEPLOY_MODE
            beforeAgent true
          }
          steps {
            echo 'Deploy production entered'
            // change nginx conf to allow blue green deployment
            // docker compose up
            // publish to a docker swarm set of nodes
            // make sure that compose pulls the tested and newly uploaded image

            //using compose in production: https://docs.docker.com/compose/production/
            //rebuilds the image for blue and then stop, destroy, and recreate just the blue service
            //--no-deps flag prevents Compose from also recreating any services which blue depends on
            sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_prod} build blue"
            sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_prod} up --no-deps -d blue"

            sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_prod} build green"
            sh "docker-compose -f ${docker_compose_main} -f ${docker_compose_prod} up --no-deps -d green"

            // script {
            //   currentBuild.result = 'SUCCESS'
            // }
          }
        }
      }

      post {
        always {
          node('worker'){
            //step {
              echo 'post => always section'
              /* clean up our workspace */
              //deleteDir()

              //Cleanup Docker
              //stop all containers:
              // docker stop $(docker ps -aq)
              // delete containers
              // docker container prune -f

              //sh 'docker system prune -a -f'
              //sh 'docker rmi $(docker images --filter=reference="${registry}/${image}:*" -q) -f || true'
            //}

          }

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
