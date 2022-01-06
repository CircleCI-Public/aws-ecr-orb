# AWS ECR Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-ecr-orb.svg?style=shield "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-ecr-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/aws-ecr)](https://circleci.com/orbs/registry/orb/circleci/aws-ecr) [![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/aws-ecr-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)
CircleCI orb for interacting with Amazon's Elastic Container Registry (ECR).

## Usage

See the [orb registry listing](https://circleci.com/orbs/registry/orb/circleci/aws-ecr) for usage guidelines.

## Examples
See below for both simple and complete examples of this orb's `build_and_push_image` job. For details, see the [listing in the Orb Registry](https://circleci.com/orbs/registry/orb/circleci/aws-ecr).

### Simple
```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@x.y.z

workflows:
  simple_build_and_push:
    jobs:
      # with default parameter values, the following would be sufficient to build and push an image to ECR
      - aws-ecr/build-and-push-image:
          repo: myRepositoryName

```

# Complete
```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@x.y.z

workflows:
  complete_build_and_push:
    jobs:
      # build and push image to ECR
      - aws-ecr/build-and-push-image:

          # required if any necessary secrets are stored via Contexts
          context: myContext

          # AWS profile name, defaults to "default"
          profile-name: myProfileName

          # AWS role profile should assume
          role-arn: arn:aws:iam::123456789:role/some-role

          # name of env var storing your AWS Access Key ID, defaults to AWS_ACCESS_KEY_ID
          aws-access-key-id: ACCESS_KEY_ID_ENV_VAR_NAME

          # name of env var storing your AWS Secret Access Key, defaults to AWS_SECRET_ACCESS_KEY
          aws-secret-access-key: SECRET_ACCESS_KEY_ENV_VAR_NAME

          # name of env var storing your AWS region, defaults to AWS_REGION
          region: AWS_REGION_ENV_VAR_NAME

          # name of env var storing your ECR account URL, defaults to AWS_ECR_ACCOUNT_URL
          account-url: AWS_ECR_ACCOUNT_URL_ENV_VAR_NAME

          # name of your ECR repository
          repo: myECRRepository

          # set this to use CircleCI's remote Docker environment for Docker and docker-compose commands,
          # defaults to "false"
          setup-remote-docker: true

          # when setup-remote-docker is true, customize docker engine version (default is `19.03.13`)
          remote-docker-version: 19.03.13

          # set this to enable Docker layer caching if using remote Docker engine.
          # defaults to "false"
          remote-docker-layer-caching: true

          # set this to enable dockerhub authenticated pulls, defaults to false.
          docker-login: true

          # name of env var storing your dockerhub username, defaults to DOCKERHUB_USERNAME.
          dockerhub-username: DOCKERHUB_USERNAME

          # name of env var storing your dockerhub password, defaults to DOCKERHUB_PASSWORD.
          dockerhub-password: DOCKERHUB_PASSWORD

          # set this to true to create the repository if it does not already exist, defaults to "false"
          create-repo: true

          # set this to true to scan the created repository for CVEs on push, defaults to "true"
          repo-scan-on-push: true

          # ECR image tags (comma-separated string), defaults to "latest"
          tag: latest,myECRRepoTag

          # name of Dockerfile to use, defaults to "Dockerfile"
          dockerfile: myDockerfile

          # path to Dockerfile, defaults to . (working directory)
          path: pathToMyDockerfile

          # The amount of time to allow the docker build command to run before timing out (default is `10m`)
          no-output-timeout: 15m

          # Set to true if you don't want to build the image if it already exists in the ECR repo, for example when
          # you are tagging with the git commit hash. Specially useful for faster code reverts.
          skip-when-tags-exist: false

          # Set the resource_class option on the executor, defaults to "medium"
          resource-class: medium
```

## Contributing
We welcome [issues](https://github.com/CircleCI-Public/aws-ecr-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/aws-ecr-orb/pulls) against this repository! For further questions/comments about this or other orbs, visit [CircleCI's Orbs discussion forum](https://discuss.circleci.com/c/orbs).
