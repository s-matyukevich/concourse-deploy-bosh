# concourse-deploy-bosh

Deploy BOSH, initialize cloud config and prepare [PCF deployment pipeline](https://github.com/enaml-ops/concourse-deploy-cloudfoundry) with [omg](https://github.com/enaml-ops) in a Concourse pipeline.

## Prerequisites

1. [Git](https://git-scm.com)
1. [Vault](https://www.vaultproject.io)
1. [Concourse](http://concourse.ci)

## Steps to use this pipeline

1. Clone this repository.

    ```
    git clone https://github.com/s-matyukevich/concourse-deploy-bosh.git
    ```

1. Copy example settings to `setup` directory.

    ```
    cd concourse-deploy-bosh
    cp samples/pipeline-vars.yml setup/
    ```

1. Edit `setup/pipeline-vars.yml`, adding the appropriate values.

    ```
    $EDITOR setup/pipeline-vars.yml
    ```

1. Create or update the pipeline.

    ```
    fly -t my-target set-pipeline -p deploy-bosh -c ci/bosh-pipeline.yml -l setup/pipeline-vars.yml 
    fly -t my-target unpause-pipeline -p deploy-bosh
    ```

1. Trigger the deployment jobs in order and observe the output.

    ```
    fly -t my-target trigger-job -j deploy-bosh/create-flavors -w
    fly -t my-target trigger-job -j deploy-bosh/deploy-bosh -w
    fly -t my-target trigger-job -j deploy-bosh/deploy-cloudconfig -w
    fly -t my-target trigger-job -j deploy-bosh/update-pcf-pipeline -w
    ```
