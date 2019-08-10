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
        // globals: these should be defined in Jenkins global config
        // JENKINS_TEST_PROJECT (GCP project Jenkins runs in)
        // JENKINS_TEST_BUCKET (GCS bucket for saving intermediate artifacts)
        // JENKINS_TEST_CRED_ID (name of GCP credential for Jenkins service acct)

        // different steps use different names for this
        PROJECT = "${JENKINS_TEST_PROJECT}"
        PROJECT_ID = "${PROJECT}"

        // build vars
        BUILD_CONTEXT_WEB = "build-context-web-${BUILD_ID}.tar.gz"
        GCR_IMAGE_WEB = "gcr.io/${PROJECT}/cookieshop-web:${BUILD_ID}"
        GCR_IMAGE_DB = "gcr.io/${PROJECT}/cookieshop-db:${BUILD_ID}"

        // deploy vars
        CLUSTER_NAME_STAGING = "cookieshop-staging"
        LOCATION = "us-central1-a"
        CREDENTIALS_ID = "${JENKINS_TEST_CRED_ID}"
        STAGING_NAMESPACE = "test-jenkins-${BUILD_ID}"
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
        stage('integration tests') {
            parallel {
                stage('gke staging') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'deploy-gke'
                            yamlFile 'jenkins/podspecs/deploy.yaml'
                        }
                    }
                    steps {
                        container('jenkins-gke') { // create namespace
                            sh("sed -i 's#__NAMESPACE__#${STAGING_NAMESPACE}#' jenkins/manifests/create-namespace.yaml") //TODO: replace with kustomize?
                            // sh('cat jenkins/manifests/create-namespace.yaml')
                            step([ // TODO: replace this with simple kubectl?
                                $class: 'KubernetesEngineBuilder',
                                projectId: env.PROJECT_ID,
                                clusterName: env.CLUSTER_NAME_STAGING,
                                location: env.LOCATION,
                                manifestPattern: 'jenkins/manifests/create-namespace.yaml',
                                credentialsId: env.CREDENTIALS_ID,
                                verifyDeployments: true])
                            sh("kubectl version")
                        }
                        // test app
                    }
                }
                stage('gke per test') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'ubuntu-gke-per-test'
                            yamlFile 'jenkins/podspecs/ubuntu.yaml'
                        }
                    }
                    steps {
                        container('ubuntu') {
                            sh('echo dedicated gke')
                        }
                        container('ubuntu') {
                            sh('echo test dedicated gke')
                        }
                    }
                }
            }
        }
    }
}