# Automated Buildpack Management Pipelines

This repository is based on [vzickner/ci-buildpacks](https://github.com/vzickner/ci-buildpacks) and [pivotal-cf/pcf-pipelines](https://github.com/pivotal-cf/pcf-pipelines/tree/master/upgrade-buildpacks).

The advantage of this repository is that buildpacks can be updated in a controlled manner to avoid automated buildpack update of a major version.

It allows platform administrators to define a set of fixed buildpack versions so that they can get approval from a change process.

And it also provides a way to roll back to a previous buildpack version when the testing fails. It is useful especially when customized buildpack are provided.

## Quick Start

1. Setup your Concourse environment and other software dependancies (Minio, RocketChat, Credhub).
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
| cf-test-app-go-url            | value    | https://github.com/goldginkgo/cf-test-app-go.git                                            |
| cf-test-app-ruby-url          | value    | https://github.com/goldginkgo/cf-test-app-ruby.git                                          |
| cf-test-app-nodejs-url        | value    | https://github.com/goldginkgo/cf-test-app-nodejs.git                                        |
| cf-test-app-binary-url        | value    | https://github.com/goldginkgo/cf-test-app-binary.git                                        |
| git-username                  | value    |                                                                                             |
| git-password                  | password |                                                                                             |
| cf-api-uri                    | value    |                                                                                             |
| cf-apps-url                   | value    |                                                                                             |
| cf-username                   | value    |                                                                                             |
| cf-password                   | password |                                                                                             |
| cf-organization               | value    |                                                                                             |
| cf-space                      | value    |                                                                                             |
| s3-minio-endpoint             | password |                                                                                             |
| s3-access-key-id              | password |                                                                                             |
| s3-secret-access-key          | password |                                                                                             |
| s3-bucket                     | value    |                                                                                             |
| pivnet-token                  | password |                                                                                             |
| rocket-chat-url               | value    |                             `                                                               |
| rocket-chat-username          | value    |                                                                                             |
| rocket-chat-password          | password |                                                                                             |
| channel                       | value    |                                                                                             |
| stack                         | value    | cflinuxfs3                                                                                  |
| environment                   | value    | QA                                                                                          |
| fly-host                      | value    |                                                                                             |
| fly-team                      | value    |                                                                                             |
| fly-username                  | value    |                                                                                             |
| fly-password                  | password |                                                                                             |
| pipeline                      | value    | buildpack-mgmt                                                                              |

For the login to the pivotal network, you need a token from the [Pivotal Network](https://network.pivotal.io/).
There you can go to the profile and request a token (the deprecated token).

## Technical details

### Define desired buildpack Version (CMDB)
Desired buildpacks versions are defined in a Git file like the following, whenever there is a change in the file, our pipelines will be triggered to update buildpacks.
```
staticfile_buildpack: 1.4.42
go_buildpack: 1.25
ruby_buildpack: 2.5
```

### Supported buildpacks
Buildpacks supported by the pipelines are defined in buildpacks folder. A new file should be added if you want to support new buildpacks. Here is an example of the file:
```
buildpack-name: staticfile-buildpack
human-readable-name: Staticfile Buildpack
input-resource-type: pivnet
input-resource-source:
  api_token: ((pivnet-token))
  product_slug: staticfile-buildpack
  product_version: \d+\.\d+\.\d+
buildpack-regex-output: staticfile_buildpack-cached-((stack))-v(.*).zip
buildpack-regex: staticfile_buildpack.*((stack))-v(.*).zip
buildpack-ls: staticfile_buildpack-cached-((stack))-v*.zip
test-app-type: git
test-app-source:
  uri: ((cf-test-app-staticfile-url))
  branch: master
  username: ((git-username))
  password: ((git-password))
  skip_ssl_verification: true
test-app-passed: []
cf-staging-buildpack-name: staticfile_buildpack_staging
cf-buildpack-name: staticfile_buildpack
```

### Pipeline tasks
- download buildpack: Download Buildpacks from Pivotal Network and store in Minio.
- build customized buildpacks: Compile customized buildpacks from downloaded buildpack and store in Minio
- build Java app: Compile Java test app from source code and store jar file to Minio.

- trigger buildpack: Whenever buildpack CMDB is updated, check desired version and current version in our environment, update our pipelines with correct versions and trigger the tasks to update buildpack. Buildpacks will be updated one by one.
- stage buildpack: Stage a new buildpack with desired version in our environment. e.g. a new buildpack called staticfile_buildpack_stage will be added at the last position if staticfile buildpack are to be updated.
- test buildpack: Deploy a testing app with our test app and the staged buildpack in our Cloud Foundry environment. Send requests to defined endpoints to test apps.
- promote buildpack: Delete the old buildpack(staticfile_buildpack), rename the staged buildpack (staticfile_buildpack_stage -> staticfile_buildpack) and put the buldpack to the old position. Send a notification to RocketChat when finished.