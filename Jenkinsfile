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
      steps {
        script {
          // login to docker hub (or whatever registry)
          // build image and push it to registry
          //
          // alternatively, if you want to scan the image locally without pushing 
          // it somewhere first, we can do that (see the next stage for details)
          //
          sh """
            echo "${DOCKER_HUB_PSW}" | docker login ${REGISTRY} -u ${DOCKER_HUB_USR} --password-stdin
            docker build -t ${IMAGE} --pull -f ./Dockerfile .
            # we don't need to push since we're using anchorectl, but if you wanted to you could do this:
            # docker push ${IMAGE}
          """
          // I don't like using the docker plugin but if you want to use it, here ya go
          // DOCKER_IMAGE = docker.build REPOSITORY + ":" + TAG
          // //docker.withRegistry( '', HUB_CREDENTIAL ) { 
          // DOCKER_IMAGE.push() 
          // }
        } // end script
      } // end steps
    } // end stage "Build Image"

    stage('Scan Image') {
      steps {
        script {
          sh """
            curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ${HOME}/.local/bin
            curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b ${HOME}/.local/bin
            export PATH="${HOME}/.local/bin:${PATH}"
            syft -o json ${IMAGE} > sbom.json
            grype sbom:sbom.json
          """          
        } // end script
      } // end steps
    } // end stage "Build Image"
    
    
    // optional stage, this just deletes the image locally so I don't end up with 300 old images
    //
    stage('Clean Up') {
      // delete the images locally
      steps {
        sh 'docker rmi ${IMAGE} || failure=1' 
        //
        // the "|| failure=1" at the end of this line just catches problems with the :prod
        // tag not existing if we didn't uncomment the optional "re-tag as prod" stage
        //
      } // end steps
    } // end stage "clean up"

  } // end stages    
    
  post {
    always {
      // archive the sbom
      archiveArtifacts artifacts: 'sbom.json'
      // and, just to be sure, let's clean up after ourselves, 
      // remove any sboms we've created from the workspace
      sh 'rm -f *sbom*'
    } // end always
  } //end post
    
} // end pipeline
