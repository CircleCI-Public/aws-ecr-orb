# AWS ECR Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-ecr-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-ecr-orb)
CircleCI orb for interacting with Amazon's Elastic Container Registry (ECR).

## Parameters
Following is the full list of parameters required by this orb's various commands and jobs. For details, see the [listing in the Orb Registry](https://circleci.com/orbs/registry/orb/circleci/aws-ecr).

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `account-url` | `env_var_name` | `AWS_ECR_ACCOUNT_URL` | name of env var storing your ECR account URL |
| `aws-access-key-id` | `env_var_name` | `AWS_ACCESS_KEY_ID` | name of env var storing your AWS Access Key ID |
| `aws-secret-access-key` | `env_var_name` | `AWS_SECRET_ACCESS_KEY` | name of env var storing your AWS Secret Access Key |
| `create-repo` | `boolean` | `false` | set this to true to create the repository if it does not already exist |
| `dockerfile` | `string` | `Dockerfile` | name of Dockerfile to use |
| `executor` | `executor` | `default` | name of any custom executor (default is `machine: true`) |
| `extra-build-args` | `string` | `""` | Extra flags to pass to `docker build` (see [docs.docker.com/engine/reference/commandline/build](https://docs.docker.com/engine/reference/commandline/build)) |
| `path` | `string` | `.` | path to Dockerfile, defaults to the working directory |
| `profile-name` | `string` | `default` | AWS profile name |
| `region` | `env_var_name` |  `AWS_REGION` | name of env var storing your AWS region |
| `repo` | `string` |  N/A | name of your ECR repository |
| `tag` | `string` |  `latest` | ECR image tag |
| `after_checkout` | `steps` |  `[]` | Optional steps to run after checking out the code. |
| `before_build` | `steps` |  `[]` | Optional steps to run before building the docker image. |
| `after_build` | `steps` |  `[]` | Optional steps to run after building the docker image. |

## Usage
See below for both simple and complete examples of this orb's `build_and_push_image` job. For details, see the [listing in the Orb Registry](https://circleci.com/orbs/registry/orb/circleci/aws-ecr).

### Simple
```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@1.0.0

workflows:
  simple_build_and_push:
    jobs:
      # with default parameter values, the following would be sufficient to build and push an image to ECR
      - aws-ecr/build_and_push_image:
          repo: myRepositoryName

```

# Complete
```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@1.0.0

workflows:
  complete_build_and_push:
    jobs:
      # build and push image to ECR
      - aws-ecr/build_and_push_image:

          # required if any necessary secrets are stored via Contexts
          context: myContext

          # AWS profile name, defaults to "default"
          profile-name: myProfileName

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

          # set this to true to create the repository if it does not already exist, defaults to "false"
          create-repo: true

          # ECR image tag, defaults to "latest"
          tag: myECRRepoTag

          # name of Dockerfile to use, defaults to "Dockerfile"
          dockerfile: myDockerfile

          # path to Dockerfile, defaults to . (working directory)
          path: pathToMyDockerfile

          # Optional steps to run after checking out the code, defaults to []
          after_checkout:
            - run:
                name: Do this after checkout.
                command: echo "Did this after checkout"

          # Optional steps to run before building the docker image, defaults to []
          before_build:
            - run:
                name: Do this before the build.
                command: echo "Did this before the build"

          # Optional steps to run after building the docker image, default to []
          after_build:
            - run:
                name: Do this after the build.
                command: echo "Did this after the build"
```

## Contributing
We welcome [issues](https://github.com/CircleCI-Public/aws-ecr-orb/issues) to and [pull requests](https://github.com/CircleCI-Public/aws-ecr-orb/pulls) against this repository! For further questions/comments about this or other orbs, visit [CircleCI's Orbs discussion forum](https://discuss.circleci.com/c/orbs).
