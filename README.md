# aws-ecr-orb
Orb for interacting with Amazon Elastic Container Registry (ECR) from within a CircleCI build job.

## View in the orb registry
See the [aws-ecr-orb in the registry](https://circleci.com/orbs/registry/orb/circleci/aws-ecr)
for more the full details of jobs, commands, and executors available in this
orb.

## Setup required to use this orb
The following **required** dependencies must be configured in CircleCI in order to use this orb:
* AWS_ACCESS_KEY_ID - environment variable for AWS login
* AWS_SECRET_ACCESS_KEY - environment variable for AWS login

If set, the following **optional** environment variables will serve as default
parameter values:
* AWS_ECR_ACCOUNT_URL

See CircleCI documentation for instructions on storing environment variables
in either your Project settings or a Context:
* [Setting environment variables in CircleCI](https://circleci.com/docs/2.0/env-vars)

## Sample use in CircleCI config.yml
This example uses the `circleci/aws-ecr` orb to build a docker image based on
a Dockerfile in the root directory and push it to Amazon ECR,
based on the parameters provided to the `aws-ecr/build_and_push_image` job:

```yaml
version: 2.1

orbs:
  aws-ecr: circleci/aws-ecr@1.0.0

workflows:
  build_and_push_image:
    jobs:
      # build and push image to ECR
      - aws-ecr/build_and_push_image:
          context: myContext
          region: us-east-1
          account-url: 999999999999.dkr-ecr.us-west-2.amazonaws.com
          repo: myrepo
          tag: latest
          dockerfile: Dockerfile
          path: .
```
