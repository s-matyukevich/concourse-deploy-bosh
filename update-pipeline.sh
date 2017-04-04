#!/bin/bash

fly -t $FOUNDATION_NAME set-pipeline -p deploy-bosh -c ci/bosh-pipeline.yml  -l setup/pipeline-vars.yml
