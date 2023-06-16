String cron_only_on_master = env.BRANCH_NAME == "master" ? "@daily" : ""

pipeline {
    agent {
      docker {
         image 'docker-upstream-rnd-artifacts.intelerad.com/hashicorp/terraform:0.12.31'
         args "--entrypoint=''"
         label 'aws-slave && docker'
      }
      // FIXME: Once we get the time to build our own custom container to work properly in the CI system
      //        Currently we have issues with git pull from GitHub as the local user doesn't exist
      //dockerfile {
      //    filename 'Dockerfile.build'
      //    label 'generic-slave && docker'
      //    dir 'build'
      //    additionalBuildArgs  '--build-arg terraformVersion=0.12.19 --build-arg ansibleVersion=2.8.5'
      //    args "--entrypoint=''"
      //}
    }
    triggers {
        cron(cron_only_on_master)
    }
    stages {
        stage('Terraform init') {
            steps {
                runTerraform('init')
            }
        }
        stage('Terraform plan') {
            steps {
                script {
                    def exitCode = runTerraform('plan', ['-out=plan.out', '-detailed-exitcode'])

                    if ( exitCode == 2 ) {
                        timeout(time: 10, unit: 'MINUTES') {
                            input message: 'Found terraform changes. Do you want to apply them?', ok: 'Apply'
                        }
                    }
                }
            }
        }
        // The apply stage will be executed if there is no changes but won't affect the environment anyways
        stage('Terraform apply') {
            steps {
                runTerraform('apply', ['-lock=true', 'plan.out'])
            }
        }
    }
    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
        timestamps()
        timeout(time: 1, unit: 'HOURS')
    }
}

def getStageFromBranch() {
    def branchName = env.BRANCH_NAME ?: 'dev'

    if( branchName == 'master' ) {
        return 'prod'
    }

    if( branchName == 'develop' ) {
        return 'staging'
    }

    return 'dev'
}

def runTerraform(String command) {
    return runTerraform(command, [])
}

def runTerraform(String command, List<String> commandArgs) {
    String stage = getStageFromBranch()

    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                              credentialsId: "bc-${stage}-aws-account",
                              accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                              secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
        def exitCode = sh returnStatus: true, script: "cd terraform/bc-${stage}-base-infra && terraform ${command} -input=false " + commandArgs.join(' ')
        if ( exitCode == 0 || exitCode == 2 ) {
            return exitCode
        }
        error 'Terraform exited with status code ' + exitCode
    }
}
