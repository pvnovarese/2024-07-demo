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

    stage('Build and Push Image') {
      steps {
        sh '''
          ## you'll need a kubeconfig for buildctl to reach the pod where buildkit is running (probably will just stash this in a credential
          ## but right now I'm just setting this up manually when I stand up the jenkins deployment)
          KUBECONFIG="${JENKINS_HOME}/.kube/config"
          ### going to construct a docker auth config so buildctl can push the image (this could also just be a credential I guess)
          if [ ! -d "${JENKINS_HOME}/.docker" ]; then
            mkdir ${JENKINS_HOME}/.docker
          fi
          AUTH=$(echo ${DOCKER_HUB_USR}:${DOCKER_HUB_PSW} | tr -d '\n' | base64)
          jq --null-input --arg auth "$AUTH" --arg registry "$REGISTRY_SERVER" '{ "auths": { $registry: { "auth": $auth } } }' > ${JENKINS_HOME}/.docker/config.json
          ### and now we'll build and push
          buildctl --addr kube-pod://buildkitd build --frontend dockerfile.v0 --local context=. --local dockerfile=. --output type=image,name=${IMAGE},push=true
        '''
      } // end steps
    } // end stage "build and push"
    


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
