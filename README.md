# AWS ECR Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-ecr-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-ecr-orb)
CircleCI orb for interacting with Amazon's Elastic Container Registry (ECR).

## Usage
See below for a complete example of this orb's `build_and_push_image` job. For details, see the [listing in the Orb Registry](https://circleci.com/orbs/registry/orb/circleci/aws-ecr).

```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@1.0.0

workflows:
  build_and_push_image:
    jobs:
      # build and push image to ECR
      - aws-ecr/build_and_push_image:

          # required if any necessary secrets are stored via Contexts
          context: myContext

          # defaults to "default"
          profile-name: myProfileName

          # name of env var storing your AWS Access Key ID, defaults to AWS_ACCESS_KEY_ID
          aws-access-key-id: ACCESS_KEY_ID_ENV_VAR_NAME

          # name of env var storing your AWS Secret Access Key, defaults to AWS_SECRET_ACCESS_KEY
          aws-access-key-id: SECRET_ACCESS_KEY_ENV_VAR_NAME

          # name of env var storing your AWS region, defaults to AWS_REGION
          region: AWS_REGION_ENV_VAR_NAME

          # name of env var storing your ECR account URL, defaults to AWS_ECR_ACCOUNT_URL
          account-url: AWS_ECR_ACCOUNT_URL_ENV_VAR_NAME

          # name of your ECR repository
          repo: myECRRepository

          # set this to true to create the repository if it does not already exist, defaults to "false"
          create-repo: true

          # tag for your ECR repository, defaults to "latest"
          tag: myECRRepoTag

          # name of Dockerfile to use, defaults to Dockerfile
          dockerfile: myDockerfile

          # path to Dockerfile, defaults to . (working directory)
          path: pathToMyDockerfile
```
