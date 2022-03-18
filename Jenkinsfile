#!/usr/bin/env groovy
@Library(['com.abc.jenkins.pipeline.library@master','com.abc.jenkins.pipelines.templates.terraform@master']) _
emailContent = "asd Terraform"
proceedToBuild = true

regions = ["prod"  : [
                    "EmailNotifyList"     : "lakshmiujwala_golla@abc.com",
                    "TagName"             : "prod",
                    "ApproverList"        : "lakshmiujwala_golla@abc.com",
                    "ApprovalWaitTimeUnit": "MINUTES",
                    "ApprovalWaitTime"    : 5],
            "dev"  : [
                   "EmailNotifyList"     : "lakshmiujwala_golla@abc.com",
                   "TagName"             : "dev",
                   "ApproverList"        : "lakshmiujwala_golla@abc.com",
                   "ApprovalWaitTimeUnit": "MINUTES",
                   "ApprovalWaitTime"    : 5],
            "stg"  : [
                   "EmailNotifyList"     : "lakshmiujwala_golla@abc.com",
                   "TagName"             : "stg",
                   "ApproverList"        : "lakshmiujwala_golla@abc.com",
                   "ApprovalWaitTimeUnit": "MINUTES",
                   "ApprovalWaitTime"    : 5],
            "sit"  : [
                   "EmailNotifyList"     : "lakshmiujwala_golla@abc.com",
                   "TagName"             : "sit",
                   "ApproverList"        : "lakshmiujwala_golla@abc.com",
                   "ApprovalWaitTimeUnit": "MINUTES",
                   "ApprovalWaitTime"    : 5]

]

pipeline {
    agent {
        label 'docker-maven-slave'
    }
    parameters {
        string(name: 'REPO_NAME', defaultValue: 'asd-terraform', description: 'Terraform Repository Name')
        choice(choices: ['prod','dev','stg','sit'], description: 'Terraform Environment for deployment', name: 'TERRAFORM_ENVIRONMENT')
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'master', name: 'BRANCH', type: 'PT_BRANCH'
    }
    tools {
        terraform 'Terraform-14'
    }
    stages{

        stage('Git Checkout')
                {
                    steps{
                        git credentialsId: 'lgolla1' , url: 'https://github.abc.com/gov-prog-asd/asd-terraform.git' ,  branch: "${params.BRANCH}"
                    }

                }

        stage('Build Binding Extensions') {
            steps {
                script {
                    sh '''
                    # Run mixins (provides the `dotnet` binary)
                    . /etc/profile.d/jenkins.sh
                    '''
                    def envvariables = readJSON file: "environmentvariables.json"
                    def tfEnv = params.TERRAFORM_ENVIRONMENT
                    switch("${tfEnv}") {
                    case "dev":
                        TFVARS_INIT_PATH = envvariables.dev['TFVARS_INIT_PATH']
                        TFVARS_PLAN_APPLY_PATH = envvariables.dev['TFVARS_PLAN_APPLY_PATH']
                        TENV = tfEnv
                        break
                    case "sit":
                        TFVARS_INIT_PATH = envvariables.sit['TFVARS_INIT_PATH']
                        TFVARS_PLAN_APPLY_PATH = envvariables.sit['TFVARS_PLAN_APPLY_PATH']
                        TENV = tfEnv
                        break
                    case "stg":
                        TFVARS_INIT_PATH = envvariables.stg['TFVARS_INIT_PATH']
                        TFVARS_PLAN_APPLY_PATH = envvariables.stg['TFVARS_PLAN_APPLY_PATH']
                        TENV = tfEnv
                        break
                    case "prod":
                        TFVARS_INIT_PATH = envvariables.prod['TFVARS_INIT_PATH']
                        TFVARS_PLAN_APPLY_PATH = envvariables.prod['TFVARS_PLAN_APPLY_PATH']
                        TENV = tfEnv
                        break
                    }
                    env.INIT_PATH = "${TFVARS_INIT_PATH}"
                    env.APPLY_PATH = "${TFVARS_PLAN_APPLY_PATH}"
                    env.TF_ENV = "${TENV}"
                }
            }
        }

        /* Terraform Init */
        stage('Terraform Init') {
            steps{
                terraformStep('init', params.TERRAFORM_ENVIRONMENT)
            }
        }
        /* Terraform Validate*/
        stage('Terraform Validate') {
            steps{
                //sh "terraform  validate"
                terraformStep('validate', params.TERRAFORM_ENVIRONMENT)
            }
        }
        /* Terraform Plan */
        stage('Terraform Plan') {
            steps{
                terraformStep('plan', params.TERRAFORM_ENVIRONMENT)
                //approvalWorkflow(params.TERRAFORM_ENVIRONMENT)
            }
        }

        /* Terraform Apply*/
        stage('Terraform Apply') {
            when { expression { return proceedToBuild }}
            steps{
                terraformStep('apply', params.TERRAFORM_ENVIRONMENT)
            }
        }

    }
}


def approvalWorkflow(region) {
    echo "Approval"
    emailext body: "Approval Needed for Terraform Apply of " + emailContent + " to $region " +
            "environment. Approval link: ${BUILD_URL}input/",
            subject: "Approval Needed for " + emailContent + " Deployment - $JOB_NAME",
            to: regions[region].EmailNotifyList,
            //cc: uatEmailNotifyList,- Need to check for CC
            from: "noreply@abc.com"

    stage('Deployment Approval') {
        try {
            glApproval message: "Approve deployment to $region?",
                    submitter: regions[region].ApproverList,
                    time: regions[region].ApprovalWaitTime,
                    unit: regions[region].ApprovalWaitTimeUnit
        } catch (e) {
            currentBuild.result = 'SUCCESS'
            proceedToBuild = false
            return
        }
    }
}

def terraformStep(tfStep, tfEnv)
{
    echo "Executing Terraform Step " + tfStep + " on ${tfEnv} :"
    credId = params.TERRAFORM_ENVIRONMENT == "prod" ? "prd-sp" : "nprd-sp"
    
    echo "Using Credential : " + credId
    stage("Terraform $tfStep"){
        withCredentials([azureServicePrincipal(
                credentialsId: credId,
                subscriptionIdVariable: 'ARM_SUBSCRIPTION_ID',
                clientIdVariable: 'ARM_CLIENT_ID',
                clientSecretVariable: 'ARM_CLIENT_SECRET',
                tenantIdVariable: 'ARM_TENANT_ID'
        )]){
            //echo "client ID is $AZURE_CLIENT_ID"
            echo "client ID is $ARM_CLIENT_ID"
            sh "az login --service-principal -u ${ARM_CLIENT_ID} -p ${ARM_CLIENT_SECRET} -t ${ARM_TENANT_ID} --allow-no-subscriptions"
            switch (tfStep) {
                case "init":
                    echo "Executing Terraform init :"
                    sh "ls -la"
                    sh """
                    terraform init -backend-config="${INIT_PATH}"
                    """
                    //sh "terraform  init "
                    //-backend-config="${INIT_PATH}"
                    break
                case "validate":
                    echo "Executing Terraform Validate :"
                    sh """
                    terraform  validate
                    """
                    break
                case "plan":
                    echo "Executing Terraform plan :"
                    sh """
                    terraform  plan -out=./output -var-file="${APPLY_PATH}"
                    """
                    break
                case "apply":
                    echo "Executing Terraform apply :"
                    sh """
                    terraform apply -input=false -auto-approve -var-file="${APPLY_PATH}" -var='client_id=${ARM_CLIENT_ID}' -var='client_secret=${ARM_CLIENT_SECRET}' -var='tenant_id=${ARM_TENANT_ID}'
                    """
                    break
                default:
                    proceedToBuild = false
            }

        }
    }
}
