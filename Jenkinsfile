/*
    execution plan:
    1. [parallel] Build, test, push Containers
        - web
        - db
    2. [parallel] provision and test
        - docker-compose[?]
            - deploy --> int test --> deprovision[?]
        - VM
            - deploy --> int test --> deprovision
        - namespace in staging
            - deploy --> int test --> deprovision[?]
        - dedicated cluster
            - deploy --> int test --> deprovision[?]

*/

pipeline {
    agent none
    triggers {
        cron('H/15 * * * *')
    }

    environment {
        FOO = "bar"
    }

    stages {
        stage('build and push containers'){
            parallel {
                stage('web') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'buld-web-pod'
                            yamlFile 'jenkins/podspecs/build-web.yaml'
                        }
                    }
                    environment {
                        PATH = "/busybox:/kaniko:$PATH"
      	            }
                    steps {
                        container('node') {
                            sh "npm install"
                            sh "npm test"
                            // stash built app
                            // TODO 
                        }
                        container(name: 'kaniko', shell: '/busybox/sh') {
                            sh '''#!/busybox/sh
                            # /kaniko/executor -f `pwd`/gke/Dockerfile -c `pwd` --context="gs://${JENKINS_TEST_BUCKET}/${BUILD_CONTEXT}" --destination="${GCR_IMAGE}" --build-arg JAR_FILE="${APP_JAR}"
                            echo container build and push
                            '''
                        }
                    }
                }
                stage('db') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'ubuntupod'
                            yamlFile 'jenkins/podspecs/ubuntu.yaml'
                        }
                    }
                    steps {
                        container('ubuntu') {
                            sh "echo building db"
                        }
                        container('ubuntu') {
                            sh "echo testing db"
                        }
                        container('ubuntu') {
                            sh "echo pushing db to registry"
                        }
                    }
                }
            }
        }
    }
}