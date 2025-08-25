library identifier: 'fm_general@master', retriever: modernSCM(
  [$class: 'GitSCMSource',
   remote: 'https://github.com/finmason2108/Automation-SharedLibraryGeneral.git',
   credentialsId: 'gh_finmasonbot1'])

def rbaseImage
def rstudioImage
def testImage

def makeDockerImageVersion(){
  if(env.BRANCH_NAME == 'master'){
    return 'latest'
  }
  /* https://docs.docker.com/engine/reference/commandline/tag/
   * A tag name must be valid ASCII and may contain lowercase and uppercase
   * letters, digits, underscores, periods and dashes.  A tag name may not start
   * with a period or a dash and may contain a maximum of 128 characters.
   */
  return env.BRANCH_NAME.replaceAll(/[^A-Za-z0-9_.-]/, '').replaceFirst(/^[.-]*/, '').take(128)
}

pipeline{
  agent {
    label "analytics"
  }

  options {
    disableResume()
    timestamps()
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
            cp Packages_analytics.* $i/
            touch $i/Packages_dummy.py
          done;
          rm dv/Packages_analytics.*
          cp Packages_datavalidation.* dv/
          touch dv/Packages_dummy.py
          '''

          milestone()
        }
      }
    }
    stage("Build base images"){
      parallel{
        // stage("Datavalidation image"){
        //   steps{
        //     script{
        //       ansiColor('xterm') {
        //         dvImage = docker.build("${fm_policy.ecr_host}/rstudio:dv-${makeDockerImageVersion()}", "./dv")
        //       }
        //     }
        //   }
        // }

        stage("RStudio"){
          steps{
            script{
              ansiColor('xterm') {
                rstudioImage = docker.build("${fm_policy.ecr_host}/rstudio:${makeDockerImageVersion()}", "./rstudio")
              }
            }
          }
        }

        stage("Analytical team image"){
          steps{
            script{
              ansiColor('xterm') {
                rbaseImage = docker.build("${fm_policy.ecr_host}/rstudio:rbase-${makeDockerImageVersion()}", "./rbase")
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
            testImage = docker.build("${fm_policy.ecr_host}/rstudio:test-${makeDockerImageVersion()}", "./test")
          }
        }
      }
    }


    stage("Publish to ECR"){
      // Skip docker image publish when pull request
      when{
        not { branch 'PR-*' }
      }
      steps{
        script{
          docker.withRegistry(fm_policy.ecr_registry_url, fm_policy.ecr_registry_credentials_id) {
            // dvImage.push()
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
        emailext subject: "Docker image ${fm_policy.ecr_host}/rstudio build #${env.BUILD_NUMBER} failed",
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
