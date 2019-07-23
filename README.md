# Buildpack Pipeline for Enterprise Buildpack Management

For further instruction please refer to the [mimacom blog post](https://blog.mimacom.com/enterprise-cf-buildpack-management-with-concourse/) about this repository.

## Quick Start

1. Setup your Concourse environment (see also the blog post "[Deploying Concourse as BOSH Deployment](https://blog.mimacom.com/deploying-concourse-with-bosh/)")
2. Place your buildpack configurations inside the `buildpacks/` folder.
3. Install the requirement command line tools:
   * [bosh-cli](https://github.com/cloudfoundry/bosh-cli)
   * [spruce](https://github.com/geofffranks/spruce)
   * fly (download from your Concourse installation)
4. Execute `./build-pipeline.sh`
5. Login to Concourse with the `fly` CLI
6. Upload the pipeline `buildpack-installation-pipeline.yml` to Concourse.

## CredHub Settings

Inside this repository, there are a lot of variables which are used but not directly defined.
The best option to provide these variables is CredHub.
Therefore, you need to integrate your Concourse to CredHub, an introduction how to do this is available [here](https://blog.mimacom.com/deploying-concourse-with-bosh/).

Add the following variables to your CredHub installation with the specific team prefix:

| Name                  | Type     | Example                                                         |
|-----------------------|----------|-----------------------------------------------------------------|
| slack-webhook-url     | value    | https://hooks.slack.com/services/abcd/efghij/klmnopqrstuvwxyz   |
| cf-organization       | value    | system                                                          |
| cf-space              | value    | mimacom-debug-space                                             |
| cf-api-uri            | value    | https://api.test.mimacom.com/                                   |
| cf-username           | value    | admin                                                           |
| cf-password           | password | mySecretTestPassword                                            |
| cf-prod-api-uri       | value    | https://api.prod.mimacom.com/                                   |
| cf-prod-username      | value    | admin                                                           |
| cf-prod-password      | password | myEvenMoreSecretProductionPassword                              |
| aws-secret-access-key | password |                                                                 |
| aws-access-key-id     | value    |                                                                 |
| aws-bucket            | value    | buildpack-aws-bucket                                            |
| pivnet-token          | password | tokenGeneratedAtThePivnetProfile                                |

For the login to the pivotal network, you need a token from the [Pivotal Network](https://network.pivotal.io/).
There you can go to the profile and request a token (the deprecated token).