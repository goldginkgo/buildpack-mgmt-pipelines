# Automated Buildpack Management Pipelines

This repository is based on [vzickner/ci-buildpacks](https://github.com/vzickner/ci-buildpacks) and [pivotal-cf/pcf-pipelines](https://github.com/pivotal-cf/pcf-pipelines/tree/master/upgrade-buildpacks).

The advantage of this repository is that buildpacks can be updated in a controlled manner to avoid major version update of buildpacks automatically.

It allows platform administrators to define a set of fixed buildpack versions so that they can get approval from a change process.

And it also provides a way to roll back to a previous buildpack version when the testing fails. It is useful especially when customized buildpack  are provided.

## Quick Start

1. Setup your Concourse environment and other support tools (Artifactory, RocketChat).
2. Place your buildpack configurations inside the `buildpacks/` folder.
3. Install the requirement command line tools:
   * [bosh-cli](https://github.com/cloudfoundry/bosh-cli)
   * [spruce](https://github.com/geofffranks/spruce)
   * fly (download from your Concourse installation)
4. Execute `./build-pipeline.sh`
5. Login to Concourse with the `fly` CLI
6. Upload the pipeline `buildpack-installation-pipeline.yml` to Concourse.
7. Define a set of buildpack versions in CMDB repository.

## CredHub Settings

Inside this repository, there are a lot of variables which are used but not directly defined.
The best option to provide these variables is CredHub.

Add the following variables to your CredHub installation with the specific team prefix:

| Name                          | Type     | Example                                                                                     |
|-------------------------------|----------|---------------------------------------------------------------------------------------------|
| buildpack-mgmt-pipelines-url  | value    | https://github.com/goldginkgo/buildpack-mgmt-pipelines                                      |
| buildpack-mgmt-cmdb-url       | value    | https://github.com/goldginkgo/buildpack-mgmt-cmdb                                           |
| cf-test-app-staticfile-url    | value    | https://github.com/goldginkgo/cf-test-app-staticfile.git                                    |
| git-username                  | value    |                                                                                             |
| git-password                  | password |                                                                                             |
| cf-api-uri                    | value    | https://api.`<domain>`                                                                      |
| cf-apps-url                   | value    | apps.`<domain>`                                                                             |
| cf-username                   | value    |                                                                                             |
| cf-password                   | password |                                                                                             |
| cf-organization               | value    | system                                                                                      |
| cf-space                      | value    | buildpack_test                                                                              |
| artifactory-endpoint          | value    | http://`<ip>`:8081/artifactory                                                              |
| artifactory-username          | value    | admin                                                                                       |
| artifactory-password          | password |                                                                                             |
| artifactory-repo              | value    | "/generic-local"                                                                            |
| pivnet-token                  | password |                                                                                             |
| rocket-chat-url               | value    | https://rocketchat.`<domain>`                                                               |
| rocket-chat-username          | value    |                                                                                             |
| rocket-chat-password          | password |                                                                                             |
| channel                       | value    | buildpack_mgmt_test                                                                         |
| stack                         | value    | cflinuxfs3                                                                                  |
| environment                   | value    | QA                                                                                          |
| fly-host                      | value    | http://`<ip>`:8080                                                                          |
| fly-team                      | value    | main                                                                                        |
| fly-username                  | value    |                                                                                             |
| fly-password                  | password |                                                                                             |
| pipeline                      | value    | buildpack-mgmt                                                                              |

For the login to the pivotal network, you need a token from the [Pivotal Network](https://network.pivotal.io/).
There you can go to the profile and request a token (the deprecated token).