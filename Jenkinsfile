/*
    execution plan:
    1. [parallel] Build, test, push Containers
        - web √
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

    environment {
        PROJECT = "${JENKINS_TEST_PROJECT}"
        BUILD_CONTEXT_WEB = "build-context-web-${BUILD_ID}.tar.gz"
        GCR_IMAGE_WEB = "gcr.io/${PROJECT}/cookieshop-web:${BUILD_ID}"
        GCR_IMAGE_DB = "gcr.io/${PROJECT}/cookieshop-db:${BUILD_ID}"
    }

    stages {
        stage('build and push containers'){
            parallel {
                stage('web') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'buld-pod-web'
                            yamlFile 'jenkins/podspecs/build.yaml'
                        }
                    }
                    environment {
                        PATH = "/busybox:/kaniko:$PATH"
      	            }
                    steps {
                        container('node') {
                            dir("web") {
                                sh "npm install"
                                sh "npm test"
                                // stash built app to GCS
                                sh "tar --exclude='./.git' -zcf /tmp/$BUILD_CONTEXT_WEB ." // save to tmp to avoid 'file changed as we read it'
                                sh "mv /tmp/$BUILD_CONTEXT_WEB ." // bubble from tmp
                                step([$class: 'ClassicUploadStep', credentialsId: env.JENKINS_TEST_CRED_ID, bucket: "gs://${JENKINS_TEST_BUCKET}", pattern: env.BUILD_CONTEXT_WEB])
                            }
                        }
                        container(name: 'kaniko', shell: '/busybox/sh') {
                            sh '''#!/busybox/sh 
                            /kaniko/executor -f `pwd`/jenkins/dockerfiles/web.Dockerfile --context="gs://${JENKINS_TEST_BUCKET}/${BUILD_CONTEXT_WEB}" --destination="${GCR_IMAGE_WEB}"
                            '''
                        }
                    }
                }
                stage('db') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'build-pod-db'
                            yamlFile 'jenkins/podspecs/build.yaml'
                        }
                    }
                    steps {
                        container(name: 'kaniko', shell: '/busybox/sh') {

                            sh '''#!/busybox/sh
                            /kaniko/executor -f `pwd`/jenkins/dockerfiles/mysql.Dockerfile --context="dir://`pwd`/mysql" --destination="${GCR_IMAGE_DB}"
                            '''
                        }
                    }
                }
            }
        }
    }
}