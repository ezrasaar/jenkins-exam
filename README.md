# Jenkins Flask project

Jenkins builds and tests a small Flask app. Changes merged into `main` are deployed on the VM.

## Jenkins setup

1. Create a Multibranch Pipeline job named `jenkins-exam`.
2. Under **Branch Sources**, select **Git** and enter `https://github.com/ezrasaar/jenkins-exam.git`.
3. Set **Script Path** to `Jenkinsfile`. The build agent needs the `docker` label and access to Docker.
4. In Jenkins Credentials, add a **Username with password** credential. Use your Docker Hub username and a Docker Hub token with write access as the password. Set the ID to `dockerhub-jenkins-exam`.
5. Click **Scan Multibranch Pipeline Now** to find the branches.

## Branches

- `dev` builds the development image and checks that `/health` returns HTTP 200.
- `feature/*` builds the same Docker stage as `dev`.
- `test` runs the unit tests during the build and again inside a container. A failed test stops the pipeline.
- `main` builds the `final` image, checks `/health`, and deploys `exam-app` on port `8080`. Jenkins then checks that `/` returns the current build number as the app version.

Any other branch stops with an `Unsupported branch` error.

## Docker Hub

Jenkins pushes images to `ezrasaar/jenkins-exam` with a tag such as `test-5`. A slash in a branch name becomes a dash. On `main`, Jenkins also pushes `latest`. At the end of the run, it logs out.

## Image sizes

The development image is 235 MB. The final image is 207 MB, about 12% smaller because it leaves out pytest and its dependencies.

[Docker image size output](evidence/images.txt)
