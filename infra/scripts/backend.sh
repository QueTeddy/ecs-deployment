#!/bin/bash
set -e

ENV=$1
REGION=$2
PROJECT_NAME=$3
BUCKET="${ENV}-$PROJECT_NAME-terraform-state"
KEY="infrastructure/backend.tfstate"
TABLE="${ENV}-$PROJECT_NAME-terraform-locks"

terraform init \
  -backend-config="bucket=${BUCKET}" \
  -backend-config="key=${KEY}" \
  -backend-config="region=${REGION}"\
  -backend-config="dynamodb_table=${TABLE}"\
  -backend-config="encrypt=true"