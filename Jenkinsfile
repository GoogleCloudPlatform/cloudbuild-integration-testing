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
        // stage("echo") {
    	//     agent {
    	//     	kubernetes {
      	// 	    cloud 'kubernetes'
      	// 	    label 'ubuntupod'
      	// 	    yamlFile 'jenkins/podspecs/ubuntu.yaml'
		//         }
	    //     }
	    //     steps {
	    // 	    container('ubuntu') {
        //               sh "echo hello"
		//        }
		//    }
	    // }
        stage('build and test containers'){
            parallel {
                stage('web') {
                    agent {
                        kubernetes {
                            cloud 'kubernetes'
                            label 'ubuntupod'
                            yamlFile 'jenkins/podspecs/ubuntu.yaml'
                        }
                    }
                    steps {
                        container('ubuntu') {
                            sh "echo building web"
                        }
                        container('ubuntu') {
                            sh "echo testing web"
                        }
                        container('ubuntu') {
                            sh "echo pushing web to registry"
                        }
                    }
                }
            }
        }
    }
}