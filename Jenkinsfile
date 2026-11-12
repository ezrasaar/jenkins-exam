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
    }
}
