pipeline {
    agent none
    triggers {
        cron('H/15 * * * *')
    }

    environment {
        FOO = "bar"
    }

    stages {
        stage("echo") {
    	    agent {
    	    	kubernetes {
      		    cloud 'kubernetes'
      		    label 'ubuntupod'
      		    yamlFile 'jenkins/podspecs/ubuntu.yaml'
		        }
	        }
	        steps {
	    	    container('ubuntu') {
                      sh "echo hello"
		       }
		   }
	    }
    }
}