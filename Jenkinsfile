// requires anchorectl
// requires anchore enterprise 
//
pipeline {
  environment {
    //
    // Initial variable setup
    //
    // you need a credential named 'docker-hub' with your DockerID/password to push images
    // we will create DOCKER_HUB_USR and DOCKER_HUB_PSW from the docker-hub credential
    CREDENTIAL = "docker-hub"
    DOCKER_HUB = credentials("$CREDENTIAL")
    //
    // now we'll set up our image name/tag
    //
    REGISTRY = "docker.io"
    REPOSITORY = "${DOCKER_HUB_USR}/${JOB_BASE_NAME}"
    BRANCH_NAME = "${GIT_BRANCH.split("/")[1]}"
    TAG = "${BRANCH_NAME}"
    IMAGE = "${REGISTRY}/${REPOSITORY}:${TAG}"
    //
  } // end environment

  agent any
  
  stages {
    stage('Checkout SCM') {
      steps {
        checkout scm
      } // end steps
    } // end stage "checkout scm"    
    
    stage('Build Image') {
      app = docker.build("docker.io/pvnovarese/2024-07-demo")
    } // end stage "Build Image"

//    stage('Scan Image') {
//      steps {
//        script {
//          sh """
//            curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ${HOME}/.local/bin
//            curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ${HOME}/.local/bin
//            export PATH="${HOME}/.local/bin:${PATH}"
//            syft -o json ${IMAGE} > sbom.json
//            grype sbom:sbom.json
//          """          
//        } // end script
//      } // end steps
//    } // end stage "Build Image"

    stage('Push image') {
        docker.withRegistry('https://docker.io', 'docker-hub') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        } // end docker.withRegistry
    } // end stage "Push Image"

    
  } // end stages    
    
} // end pipeline
