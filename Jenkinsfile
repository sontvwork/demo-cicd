def getDevEnvironments() {
    return [
        APP_ENV: 'dev',
    ]
}

def getStgEnvironments() {
    return [
        APP_ENV: 'staging',
    ]
}

def getProductionEnvironments() {
    return [
        APP_ENV: 'production',
        APP_DEBUG: true,
        APP_URL: 'http://localhost',
        LOG_LEVEL: "debug",
        ECR_HOST: '845923198673.dkr.ecr.ap-southeast-1.amazonaws.com',
        BACKEND_PRIVATE_KEY_FILE: getFileCredential('backend_private_key_file'),
        BACKEND_SERVER_IP: '47.130.3.18',
    ]
}

/**
 * Pipeline
 */
pipeline {
    agent any
    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
    }
    parameters {
        string(name: 'COMMIT_ID_TO_BUILD', defaultValue: '', description: 'CommitID')
        booleanParam(name: 'BUILD_DOCKER_NO_CACHE', defaultValue: false, description: 'Build dockerfile with no cache')
    }
    environment {
        ENV = getEnvName(env.BRANCH_NAME)
        BRANCH_CODE = getBranchCode(COMMIT_ID_TO_BUILD, env.BRANCH_NAME)
        _ENVS = initEnvironments(ENV, this)
    }
    stages {
        stage('Git Clone') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[
                        name: env.BRANCH_CODE
                    ]],
                    extensions: [],
                    userRemoteConfigs: [[
                        credentialsId: 'github_key',
                        url: 'git@github.com:sontvwork/demo-cicd.git'
                    ]]
                ])
            }
        }

        stage('Setup .env file') {
            steps {
                sh '''#!/usr/bin/env bash
                    set -euo pipefail
                    IFS=$'\\t\\n'
                    shopt -s expand_aliases
                    #---------------------------------------
                    _my_temp_dir=$(mktemp -d -t tmp.XXXXXXXXXX)
                    export _my_temp_dir
                    #---------------------------------------
                    function _my_on_trap_err {
                      local error_code=$?
                      set +x
                      local command=${1:-}
                      local line_no=${2:-}
                      printf "\\e[31mGot error with exit status %b at line no %b with command: %b\\e[0m\\n" "${error_code}" "${line_no}" "${command}"
                    }
                    trap '_my_on_trap_err "${BASH_COMMAND:-}" "${LINENO:-}"' ERR
                    #: <<-'MY_TRAP_ERR_COMMENT_BLOCK'
                    export _my_disable_trap_count=${_my_disable_trap_count:-0}
                    alias _my_disable_trap_err="_my_disable_trap_count=\\\$((_my_disable_trap_count + 1)); set +e; trap - ERR"
                    alias _my_enable_trap_err="if [[ \\\${_my_disable_trap_count} -gt 0 ]]; then _my_disable_trap_count=\\\$((_my_disable_trap_count - 1)); fi; if [[ \\\${_my_disable_trap_count} -le 0 ]]; then set -e; trap '_my_on_trap_err \\"\\\${BASH_COMMAND:-}\\" \\"\\\${LINENO:-}\\"' ERR; fi"
                    #MY_TRAP_ERR_COMMENT_BLOCK
                    #---------------------------------------
                    function _my_on_trap_exit {
                      local error_code=$?
                      set +x
                      local command=${1:-}
                      if [[ "${error_code}" != "0" ]]; then
                        printf "\\e[31mGot error with exit status %b with command: %b\\e[0m\\n" "${error_code}" "${command}"
                      fi
                      rm -Rf "${_my_temp_dir}"
                      printf "EXIT %b\\n" "$0"
                      exit "${error_code}"
                    }
                    trap '_my_on_trap_exit "${BASH_COMMAND:-}"' EXIT
                    #-------------------------------------------------------------------------------
                    echo ""
                    echo "git -c color.ui=always --no-pager log -n 9"
                    echo ""
                    git -c color.ui=always --no-pager log -n 9
                    echo ""

                    if [ ! -f ".cloud.env" ];then
                        echo "Cannot found .cloud.env file for deploy to $ENV env"
                        exit 2
                    fi

                    cp .cloud.env .env

                    listEnvNeedFilled=(
                        "APP_ENV"
                        "APP_DEBUG"
                        "APP_URL"
                        "LOG_LEVEL"
                     )
                    mySedCommand=$(which gsed || which sed)
                    for envName in "${listEnvNeedFilled[@]}"; do
                        set +u
                        envValue="${!envName}"
                        set -u
                        envValueEscapedForEnv=$(echo "${envValue}" | "${mySedCommand}" -e "s|[']|&&|g")
                        envValueEscapedForSed=$(echo "${envValueEscapedForEnv}" | "${mySedCommand}" -e 's|[/\\&]|\\\\&|g')
                        "${mySedCommand}" -i -e "s/^${envName}[\\s]*=[^\\n]*/${envName}='${envValueEscapedForSed}'/g" .env
                    done
                '''
            }
        }

        stage('Build docker image') {
            steps {
                sh '''#!/usr/bin/env bash
                    set -euo pipefail
                    IFS=$'\\t\\n'
                    shopt -s expand_aliases
                    #---------------------------------------
                    _my_temp_dir=$(mktemp -d -t tmp.XXXXXXXXXX)
                    export _my_temp_dir
                    #---------------------------------------
                    function _my_on_trap_err {
                      local error_code=$?
                      set +x
                      local command=${1:-}
                      local line_no=${2:-}
                      printf "\\e[31mGot error with exit status %b at line no %b with command: %b\\e[0m\\n" "${error_code}" "${line_no}" "${command}"
                    }
                    trap '_my_on_trap_err "${BASH_COMMAND:-}" "${LINENO:-}"' ERR
                    #: <<-'MY_TRAP_ERR_COMMENT_BLOCK'
                    export _my_disable_trap_count=${_my_disable_trap_count:-0}
                    alias _my_disable_trap_err="_my_disable_trap_count=\\\$((_my_disable_trap_count + 1)); set +e; trap - ERR"
                    alias _my_enable_trap_err="if [[ \\\${_my_disable_trap_count} -gt 0 ]]; then _my_disable_trap_count=\\\$((_my_disable_trap_count - 1)); fi; if [[ \\\${_my_disable_trap_count} -le 0 ]]; then set -e; trap '_my_on_trap_err \\"\\\${BASH_COMMAND:-}\\" \\"\\\${LINENO:-}\\"' ERR; fi"
                    #MY_TRAP_ERR_COMMENT_BLOCK
                    #---------------------------------------
                    function _my_on_trap_exit {
                      local error_code=$?
                      set +x
                      local command=${1:-}
                      if [[ "${error_code}" != "0" ]]; then
                        printf "\\e[31mGot error with exit status %b with command: %b\\e[0m\\n" "${error_code}" "${command}"
                      fi
                      rm -Rf "${_my_temp_dir}"
                      printf "EXIT %b\\n" "$0"
                      exit "${error_code}"
                    }
                    trap '_my_on_trap_exit "${BASH_COMMAND:-}"' EXIT
                    #-------------------------------------------------------------------------------
                    
                    echo "Remove git, gitlab, README.md, .env.example"
                    rm -rf .git .gitlab README.md .env.example

                    dockerPath="docker/$ENV"
                    echo 'cp -vf docker/.dockerignore ./'
                    cp -vf docker/.dockerignore ./

                    if [[ -f "${dockerPath}/Dockerfile" ]]; then
                        printf "\\n\\n\\n\\n"
                        echo "cp -vf ${dockerPath}/Dockerfile ./"
                        cp -vf "${dockerPath}/Dockerfile" ./
                    fi

                    dockerImageName="demo-cicd"
                    dockerNoCacheOption=''
                    if [[ "\${BUILD_DOCKER_NO_CACHE}" == "true" ]]; then
                        dockerNoCacheOption='--no-cache'
                    fi
                    echo docker build ${dockerNoCacheOption} -t "$dockerImageName" .
                    docker build ${dockerNoCacheOption} -t "$dockerImageName" .
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                withCredentials([
                    string(credentialsId: 'aws_iam_jenkins_secret_key', variable: 'IAM_JENKINS_SECRET_KEY')
                ]) {
                    sh '''#!/usr/bin/env bash
                        set -euo pipefail
                        IFS=$'\\t\\n'
                        shopt -s expand_aliases
                        #---------------------------------------
                        _my_temp_dir=$(mktemp -d -t tmp.XXXXXXXXXX)
                        export _my_temp_dir
                        #---------------------------------------
                        function _my_on_trap_err {
                          local error_code=$?
                          set +x
                          local command=${1:-}
                          local line_no=${2:-}
                          printf "\\e[31mGot error with exit status %b at line no %b with command: %b\\e[0m\\n" "${error_code}" "${line_no}" "${command}"
                        }
                        trap '_my_on_trap_err "${BASH_COMMAND:-}" "${LINENO:-}"' ERR
                        #: <<-'MY_TRAP_ERR_COMMENT_BLOCK'
                        export _my_disable_trap_count=${_my_disable_trap_count:-0}
                        alias _my_disable_trap_err="_my_disable_trap_count=\\\$((_my_disable_trap_count + 1)); set +e; trap - ERR"
                        alias _my_enable_trap_err="if [[ \\\${_my_disable_trap_count} -gt 0 ]]; then _my_disable_trap_count=\\\$((_my_disable_trap_count - 1)); fi; if [[ \\\${_my_disable_trap_count} -le 0 ]]; then set -e; trap '_my_on_trap_err \\"\\\${BASH_COMMAND:-}\\" \\"\\\${LINENO:-}\\"' ERR; fi"
                        #MY_TRAP_ERR_COMMENT_BLOCK
                        #---------------------------------------
                        function _my_on_trap_exit {
                          local error_code=$?
                          set +x
                          local command=${1:-}
                          if [[ "${error_code}" != "0" ]]; then
                            printf "\\e[31mGot error with exit status %b with command: %b\\e[0m\\n" "${error_code}" "${command}"
                          fi
                          rm -Rf "${_my_temp_dir}"
                          printf "EXIT %b\\n" "$0"
                          exit "${error_code}"
                        }
                        trap '_my_on_trap_exit "${BASH_COMMAND:-}"' EXIT
                        #-------------------------------------------------------------------------------
                        export AWS_ACCESS_KEY_ID="\${IAM_JENKINS_ACCESS_KEY_ID}"
                        export AWS_SECRET_ACCESS_KEY="\${IAM_JENKINS_SECRET_KEY}"
                        export AWS_DEFAULT_REGION="ap-southeast-1"

                        CREDENTIALS=$(aws sts assume-role \
                          --role-arn "${IAM_JENKINS_ROLE_ARN}" \
                          --role-session-name "JenkinsDeployBackendSession")

                        export AWS_ACCESS_KEY_ID=$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')
                        export AWS_SECRET_ACCESS_KEY=$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')
                        export AWS_SESSION_TOKEN=$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')

                        dockerImageName="demo-cicd"
                        dockerImageNameWithTag="${dockerImageName}:latest"
                        echo "docker tag $dockerImageName \${ECR_HOST}/$dockerImageNameWithTag"
                        docker tag "$dockerImageNameWithTag" "\${ECR_HOST}/$dockerImageNameWithTag"

                        aws ecr get-login-password --region "${AWS_DEFAULT_REGION}" | docker login --username AWS --password-stdin "\${ECR_HOST}"

                        echo docker push "\${ECR_HOST}/$dockerImageNameWithTag"
                        docker push "\${ECR_HOST}/$dockerImageNameWithTag"
                    '''
                }
            }
        }

        stage('Publish to EC2') {
            steps {
                sh '''#!/usr/bin/env bash
                    set -euo pipefail
                    IFS=$'\\t\\n'
                    shopt -s expand_aliases
                    #---------------------------------------
                    _my_temp_dir=$(mktemp -d -t tmp.XXXXXXXXXX)
                    export _my_temp_dir
                    #---------------------------------------
                    function _my_on_trap_err {
                      local error_code=$?
                      set +x
                      local command=${1:-}
                      local line_no=${2:-}
                      printf "\\e[31mGot error with exit status %b at line no %b with command: %b\\e[0m\\n" "${error_code}" "${line_no}" "${command}"
                    }
                    trap '_my_on_trap_err "${BASH_COMMAND:-}" "${LINENO:-}"' ERR
                    #: <<-'MY_TRAP_ERR_COMMENT_BLOCK'
                    export _my_disable_trap_count=${_my_disable_trap_count:-0}
                    alias _my_disable_trap_err="_my_disable_trap_count=\\\$((_my_disable_trap_count + 1)); set +e; trap - ERR"
                    alias _my_enable_trap_err="if [[ \\\${_my_disable_trap_count} -gt 0 ]]; then _my_disable_trap_count=\\\$((_my_disable_trap_count - 1)); fi; if [[ \\\${_my_disable_trap_count} -le 0 ]]; then set -e; trap '_my_on_trap_err \\"\\\${BASH_COMMAND:-}\\" \\"\\\${LINENO:-}\\"' ERR; fi"
                    #MY_TRAP_ERR_COMMENT_BLOCK
                    #---------------------------------------
                    function _my_on_trap_exit {
                      local error_code=$?
                      set +x
                      local command=${1:-}
                      if [[ "${error_code}" != "0" ]]; then
                        printf "\\e[31mGot error with exit status %b with command: %b\\e[0m\\n" "${error_code}" "${command}"
                      fi
                      rm -Rf "${_my_temp_dir}"
                      printf "EXIT %b\\n" "$0"
                      exit "${error_code}"
                    }
                    trap '_my_on_trap_exit "${BASH_COMMAND:-}"' EXIT
                    #-------------------------------------------------------------------------------
                    export SSH_KEY="${WORKSPACE}/_tmp_/${BACKEND_PRIVATE_KEY_FILE##*/}"

                    echo "SSH to EC2, pull new image and restart container"
                    ssh -o StrictHostKeyChecking=no -i "${SSH_KEY}" ec2-user@${BACKEND_SERVER_IP} << 'EOF'
                        # Đăng nhập vào ECR
                        aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin ${ECR_HOST}
                        
                        # Pull image mới nhất
                        docker pull ${ECR_HOST}/demo-cicd:latest
                        
                        # Dừng và xóa container hiện tại nếu có
                        docker stop demo-cicd-container || true
                        docker rm demo-cicd-container || true
                        
                        # Chạy container với image mới
                        docker run -d --name demo-cicd-container -p 80:80 ${ECR_HOST}/demo-cicd:latest
                        
                        # Xóa images cũ không sử dụng
                        docker image prune -f
EOF
                    echo "Deployment completed successfully"
                '''
            }
        }

    }
    post {
        // Clean after build
        always {
            sh '''#!/bin/bash
                # Xóa các image docker cục bộ 
                echo "Cleaning up docker images..."
                docker rmi -f "demo-cicd:latest" || true
                docker rmi -f "${ECR_HOST}/demo-cicd:latest" || true
                docker image prune -f
            '''
            
            cleanWs(
                cleanWhenAborted: true,
                cleanWhenFailure: true,
                cleanWhenNotBuilt: true,
                cleanWhenSuccess: true,
                cleanWhenUnstable: true,
                deleteDirs: true,
                disableDeferredWipeout: true,
                notFailBuild: true,
                patterns: [[pattern: '**/_tmp_', type: 'INCLUDE']]
            )
        }
    }}

/**
 * Shared lib
 * @param branchName
 * @return
 */
def getEnvName(branchName) {
    def envMapping = [
        'development': 'dev',
        'staging'    : 'stg',
        'production' : 'prod',
        'update_jenkins_pipeline': 'dev'
    ]
    def env = envMapping.get(branchName)
    println("DEBUG:: Build for ${env} env...")
    return env
}

def getBranchCode(commitId, branchName) {
    branchCode = commitId ?: branchName
    println("DEBUG:: Get source from ${branchCode}")
    return branchCode
}

def initEnvironments(env, final Script script) {
    envs = []
    switch (env) {
        case 'update_Jenkins_pipeline':
        case 'dev':
            println("DEBUG:: Setup dev env")
            envs = getDevEnvironments()
            break;
        case 'stg':
            println("DEBUG:: Setup Staging env")
            envs = getStgEnvironments()
            break;
        case 'prod':
            println("DEBUG:: Setup production env")
            envs = getProductionEnvironments()
            break;
    }
    envs.each { k, v -> script.env."$k" = v }
}

def getStringCredential(id) {
    withCredentials([
        string(
            credentialsId: id,
            variable: 'resp'
        )
    ]) {
        return resp
    }
}

def getFileCredential(id) {
    withCredentials([
        file(
            credentialsId: id,
            variable: 'resp'
        )
    ]) {
        sh '''#!/bin/bash
            mkdir -p "${WORKSPACE}/_tmp_"
            cp -f "${resp}" "${WORKSPACE}/_tmp_/${resp##*/}"
        '''
        return resp
    }
}
