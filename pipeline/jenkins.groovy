pipeline {
    agent any
    environment{
        REPO = 'https://github.com/AnnaHurtovenko/kbot'
        BRANCH = 'develop'
        DOCKER='22annagurt11'
    }
    parameters {
        choice(name: 'OS', choices: ['linux', 'darwin', 'windows', 'all'], description: 'Pick OS')
        choice(name: 'ARCH', choices: ['amd64', 'arch64'], description: 'Pick Arch')

    }
    stages {
        stage('clone') {
            steps {
                echo "Clone repo"
                git branch: "${BRANCH}", url: "${REPO}"
            }
        }
        stage('test'){
            steps{
                echo "Test Build"
                sh 'make test'
            }
        }
        stage('build'){
            steps{
                script{
                    echo "Start build application"
                    if (params.OS == "linux" && params.ARCH == "amd64"){
                        sh 'make linux'
                    }
                    else if (params.OS == "linux" && params.ARCH == "arm64"){
                        sh 'make linux_arm'
                    }
                    else if (params.OS == "windows" && params.ARCH == "amd64"){
                        sh 'make windows'
                    }
                    else if (params.OS == "windows" && params.ARCH == "arm64"){
                        echo "Sorry, ARM arch not supported for windows"
                    }
                    else if (params.OS == "macos"){
                        echo "Sorry, MacOS not supported"
                    }
                }
            }
        }
        stage('image'){
            steps{
                script{
                    echo "Start build docker image"
                    if (params.OS == "linux" && params.ARCH == "amd64"){
                        sh 'make image_linux'
                    }
                    else if (params.OS == "linux" && params.ARCH == "arm64"){
                        sh 'make image_linux_arm'
                    }
                    else if (params.OS == "windows" && params.ARCH == "amd64"){
                        sh 'make image_windows'
                    }
                    else if (params.OS == "windows" && params.ARCH == "arm64"){
                        echo "Sorry, ARM arch not supported for windows"
                    }
                    else if (params.OS == "macos"){
                        echo "Sorry, MacOS not supported"
                    }
                }
            }
        }
        stage('push'){
            steps{
                script{
                    docker.withRegistry('', 'dockerhub'){
                        sh 'make push'
                    }
                }
            }
        }
    }
}
