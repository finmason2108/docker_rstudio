def makeDockerImageVersion(){
  if(env.BRANCH_NAME == 'master'){
    return 'latest'
  }
  return env.BRANCH_NAME
}

pipeline{
  agent {
    label "engineering"
  }

  options {
    timestamps()
  }

  environment {
    registry = "finmason/docker_rstudio"
    registryCredential = 'hub.docker.com'
  }

  stages{
    stage("Prepare building environment"){
      steps{
        script{
          sh 'env'
          sh 'bash addons/render.sh'
          sh '''#!/bin/bash
          for i in dv rbase rstudio; do
            echo $i;
            cp addons/* $i/
            cp Packages_analytics.R $i/
          done;
          cp Packages_datavalidation.R dv/
          '''
        }
      }
    }
    stage("Build base images"){
      parallel{
        stage("Datavalidation image"){
          steps{
            script{
              ansiColor('xterm') {
                dvImage = docker.build("${registry}:dv-${makeDockerImageVersion()}", "./dv")
              }
            }
          }
        }

        stage("RStudio"){
          steps{
            script{
              ansiColor('xterm') {
                rstudioImage = docker.build("${registry}:${makeDockerImageVersion()}", "./rstudio")
              }
            }
          }
        }

        stage("Analytical team image"){
          steps{
            script{
              ansiColor('xterm') {
                rbaseImage = docker.build("${registry}:rbase-${makeDockerImageVersion()}", "./rbase")
              }
            }
          }
        }

      }
    }

    stage("Build development image"){
      steps{
        script{
          ansiColor('xterm') {
            sh "sed -r 's!%%CONTAINER_VERSION%%!${makeDockerImageVersion()}!g;' test/Dockerfile.template > test/Dockerfile"
            testImage = docker.build("${registry}:test-${makeDockerImageVersion()}", "./test")
          }
        }
      }
    }


    stage("Publish to hub.docker.com"){
      // Skip docker image publish when pull request
      when{
        not { branch 'PR-*' }
      }
      steps{
        script{
          docker.withRegistry( '', registryCredential ) {
            dvImage.push()
            rstudioImage.push()
            rbaseImage.push()
            testImage.push()
          }
        }
      }
    }
  }

  post{
    always{
      script{
        deleteDir()
      }
    }
    failure{
      script {
        emailext subject: "Build# ${env.BUILD_NUMBER} Docker image ${registry} failed",
                   body: '${SCRIPT, template="groovy-html.template"}',
                   mimeType: 'text/html',
                   from: "jenkins@finmason.com",
                   replyTo: "ops@finmason.com",
                   recipientProviders: [
                            [$class: 'CulpritsRecipientProvider'],
                            [$class: 'DevelopersRecipientProvider'],
                            [$class: 'RequesterRecipientProvider']]
      }
    }
  }
}
