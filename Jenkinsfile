pipeline {
    agent { label 'docker' }

    stages {
        stage('Select Docker target') {
            steps {
                script {
                    def targets = [
                        'dev':       'dev',
                        'feature/*': 'dev',
                        'test':      'test',
                        'main':      'final'
                    ]

                    def branch = env.BRANCH_NAME
                    def key = branch.startsWith('feature/') ? 'feature/*' : branch
                    def target = targets[key]

                    if (!target) {
                        error("Unsupported branch: ${branch}")
                    }

                    env.DOCKER_TARGET = target
                    echo "Branch ${branch} builds Docker stage ${target}"
                }
            }
        }
        stage('Build Docker image') {
            steps {
                script {
                    // Docker tags use a dash in place of the slash in feature branch names.
                    def tagBranch = env.BRANCH_NAME.replaceAll('[^A-Za-z0-9_.-]', '-')
                    def suffix = "-${env.BUILD_NUMBER}"
                    def maxLength = 128 - suffix.length()
                    env.IMAGE_TAG = tagBranch.take(maxLength) + suffix
                }

                sh 'docker build --target "$DOCKER_TARGET" --build-arg "APP_VERSION=$BUILD_NUMBER" -t "jenkins-exam:$IMAGE_TAG" .'
            }
        }
        stage('Run test image') {
            when { branch 'test' }
            steps {
                sh 'docker run --rm "jenkins-exam:$IMAGE_TAG"'
            }
        }
        stage('Check application health') {
            when {
                anyOf {
                    branch 'dev'
                    branch 'main'
                }
            }
            steps {
                sh 'bash ci/check-health.sh "jenkins-exam:$IMAGE_TAG"'
            }
        }
        stage('Publish to Docker Hub') {
            steps {
                script {
                    env.HUB_AUTH_DIR = "${pwd(tmp: true)}/dockerhub-${env.BUILD_NUMBER}"
                }

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-jenkins-exam',
                    usernameVariable: 'HUB_USER',
                    passwordVariable: 'HUB_TOKEN'
                )]) {
                    sh '''
                        set +x
                        set -eu
                        export DOCKER_CONFIG="$HUB_AUTH_DIR"
                        umask 077
                        mkdir -p "$DOCKER_CONFIG"

                        printf '%s' "$HUB_TOKEN" | docker login --username "$HUB_USER" --password-stdin

                        repo=ezrasaar/jenkins-exam
                        docker tag "jenkins-exam:$IMAGE_TAG" "$repo:$IMAGE_TAG"
                        docker push "$repo:$IMAGE_TAG"

                        if [ "$BRANCH_NAME" = main ]; then
                            docker tag "$repo:$IMAGE_TAG" "$repo:latest"
                            docker push "$repo:latest"
                        fi
                    '''
                }
            }
        }
    }
    post {
        always {
            sh '''
                if [ -n "${HUB_AUTH_DIR:-}" ] && [ -d "$HUB_AUTH_DIR" ]; then
                    export DOCKER_CONFIG="$HUB_AUTH_DIR"
                    trap 'rm -rf -- "$DOCKER_CONFIG"' EXIT
                    docker logout
                fi
            '''
        }
    }
}
