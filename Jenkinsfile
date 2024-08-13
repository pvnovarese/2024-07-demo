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
    REGISTRY_USER = "${DOCKER_HUB_USR}"
    REGISTRY_PASSWORD = "${DOCKER_HUB_PSW}"
    //
    // now we'll set up our image name/tag
    //
    REGISTRY = "docker.io"
    REGISTRY_SERVER = "https://index.docker.io/v1/"
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
      steps {
          sh """
            pwd
            ls -l
            env
            ### set up docker .config
            AUTH=$(echo ${DOCKER_HUB_USR}:${DOCKER_HUB_PSW} | tr -d \\n | base64)
            echo ${AUTH}
            jq --null-input --arg auth "$AUTH" --arg registry "$REGISTRY_SERVER" '{ "auths": { $registry: { "auth": $auth } } }' > .docker/config.json
            cat .docker/config.json
            buildctl --addr kube-pod://buildkitd build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${IMAGE},push=true
          """
      } // end steps
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

 //   stage('Push image') {
 //     steps {
 //       docker.withRegistry('https://docker.io', 'docker-hub') {
 //           app.push("${env.BUILD_NUMBER}")
 //           app.push("latest")
 //       } // end docker.withRegistry
 //     } // end steps
 //   } // end stage "Push Image"

    
  } // end stages    
    
} // end pipeline
