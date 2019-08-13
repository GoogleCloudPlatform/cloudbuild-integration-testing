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
        UNIQUE_BUILD_ID = "${BUILD_TAG}" // TODO: this can be too long; make a hashing function
        BUILD_CONTEXT_WEB = "build-context-web-${UNIQUE_BUILD_ID}.tar.gz"
        GCR_IMAGE_WEB = "gcr.io/${PROJECT}/cookieshop-web:${UNIQUE_BUILD_ID}"
        GCR_IMAGE_DB = "gcr.io/${PROJECT}/cookieshop-db:${UNIQUE_BUILD_ID}"

        // deploy vars
        CLUSTER_NAME_STAGING = "cookieshop-staging"
        LOCATION = "us-central1-a"
        CREDENTIALS_ID = "${JENKINS_TEST_CRED_ID}"
        STAGING_NAMESPACE = "${UNIQUE_BUILD_ID}"
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
        stage('write hydrated manifest') {
            agent {
                kubernetes {
                    cloud 'kubernetes'
                    label 'kustomize'
                    yamlFile 'jenkins/podspecs/deploy.yaml'
                }
            }
            steps {
                container('kustomize') {
                    dir('k8s') {
                        // TODO: figure out how to move namespace creation inline to kustomize
                        // (instead of in a discrete step [see further down])
                        sh '''
                            kustomize edit set image __IMAGE-DB__=${GCR_IMAGE_DB}
                            kustomize edit set image __IMAGE-WEB__=${GCR_IMAGE_WEB}
                            kustomize edit set namespace ${STAGING_NAMESPACE}
                            kustomize build . > _kustomized.yaml
                            
                            # debug
                            cat _kustomized.yaml
                        '''
                        stash includes: '_kustomized.yaml', name: 'kustomize' // store hydrated manifest for use in deploy steps
                    }
                }
            }
        }
        stage('integration tests') {
            parallel {
                /*
                stage('gke staging') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'deploy-gke'
                            yamlFile 'jenkins/podspecs/deploy.yaml'
                        }
                    }
                    steps {
                        container('gcloud') { // auth to the cluster
                            sh('''
                                gcloud config set container/use_application_default_credentials true
                                gcloud container clusters get-credentials ${CLUSTER_NAME_STAGING} --zone=${LOCATION}
                                cp ~/.kube/config /workspace/kubeconfig
                                chmod 755 /workspace/kubeconfig
                                ''')
                        }
                        container('jenkins-gke') { 
                            unstash 'kustomize'

                            // create namespace
                            sh("kubectl create namespace ${STAGING_NAMESPACE} --kubeconfig=/workspace/kubeconfig")
                            
                            // deploy app
                            step([
                                $class: 'KubernetesEngineBuilder',
                                projectId: env.PROJECT_ID,
                                clusterName: env.CLUSTER_NAME_STAGING,
                                location: env.LOCATION,
                                manifestPattern: '_kustomized.yaml',
                                credentialsId: env.CREDENTIALS_ID,
                                verifyDeployments: false
                                ])

                            // determine URL of the deployed app and store to /workspace/_app-url
                            sh 'jenkins/util/get-app-url.sh'
                        
                            // test connectivity to and content of application
                            sh('''
                                ### -r = retries; -i = interval; -k = keyword to search for ###
                                test/test-connection.sh -r 20 -i 3 -u $(cat /workspace/_app-url)
                                test/test-content.sh -r 20 -i 3 -u $(cat /workspace/_app-url) -k 'Chocolate Chip'
                            ''')
                            
                            // delete namespace (and all contents)
                            sh("kubectl delete namespace ${STAGING_NAMESPACE} --kubeconfig=/workspace/kubeconfig")
                        }
                    }
                }
                stage('gke per test [unimplemented]') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'deploy-gke-per-test'
                            yamlFile 'jenkins/podspecs/deploy.yaml'
                        }
                    }
                    steps {
                        container('jenkins-gke') {
                            sh('echo implement me')
                        }
                    }
                }                
                stage('docker compose [unimplemented]') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'deploy-compose'
                            yamlFile 'jenkins/podspecs/deploy.yaml'
                        }
                    }
                    steps {
                        container('jenkins-gke') {
                            sh('echo implement me')
                        }
                    }
                }
                */
                stage('microk8s on VM [WIP]') {
                    agent { node { label 'jenkins-docker' } }
                    steps {
                        unstash 'kustomize'
                        withCredentials([file(credentialsId: 'gcp-secret-file', variable: 'GC_KEY')]) {
                            sh('''
                                # pull images
                                cat ${GC_KEY} | docker login -u _json_key --password-stdin https://gcr.io
                                docker pull ${GCR_IMAGE_WEB}
                                docker pull ${GCR_IMAGE_DB}
                                
                                # install k3s
                                sudo curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v0.8.0 sh -s - --write-kubeconfig-mode=755
                                kubectl get pods -A

                                # copy images to k3s (see https://github.com/rancher/k3s/pull/141)
                                sudo docker save -o /var/lib/rancher/k3s/agent/images/cookieshop-web.tar ${GCR_IMAGE_WEB}
                                sudo docker save -o /var/lib/rancher/k3s/agent/images/cookieshop-db.tar ${GCR_IMAGE_DB}
                                
                                # deploy app
                                kubectl create namespace ${UNIQUE_BUILD_ID}
                                kubectl apply -f _kustomized.yaml

                                # get ip of deployed app
                                export APP_IP=$(kubectl get service cookieshop-web -n ${STAGING_NAMESPACE} -o=jsonpath='{.spec.clusterIP}')

                                # determine nodeport of deployed app
                                export APP_PORT=$(kubectl get service cookieshop-web --namespace=${STAGING_NAMESPACE} -o=jsonpath='{.spec.ports[0].nodePort}')

                                export APP_URL="http://$APP_IP:$APP_PORT"

                                # test app
                                ### -r = retries; -i = interval; -k = keyword to search for ###
                                test/test-connection.sh -r 20 -i 3 -u $APP_URL
                                test/test-content.sh -r 20 -i 3 -u $APP_URL -k 'Chocolate Chip'
                            ''')
                        }
                        // 
                        // sh('''
                        //     # install microk8s (TODO: pre-install this and bake image [I tried and failed at this -dave])
                        //     sudo snap install microk8s --classic

                        //     # Patch microk8s configuration so we can connect from the outside
                        //     # This is not a good practice, use it only for the purpose of this lab
                        //     sudo sed -i.sed-bak "s/127.0.0.1/0.0.0.0/" /var/snap/microk8s/current/args/kube-apiserver
                        //     sudo systemctl restart snap.microk8s.daemon-apiserver.service
                        //     sudo microk8s.enable dns

                        //     # deploy application
                        //     sudo microk8s.kubectl apply -f _kustomized.yaml

                        //     # debug
                        //     sudo microk8s.kubectl get pods
                        // ''')
                    }
                }
            }
        }
    }
}