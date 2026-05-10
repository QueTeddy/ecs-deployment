#!/bin/bash
set -e

ENV=$1
REGION=$2
PROJECT_NAME=$3
STACK_NAME="$ENV-$PROJECT_NAME-terraform-infrastructure"
TEMPLATE_FILE="cf_templates/tf_template.yaml"

handle_error() {
    echo "🚨 ERROR: $1"
    exit 1
}

echo "--- CloudFormation Deployment Script ---"

# 1. Validation
if [ ! -f "$TEMPLATE_FILE" ]; then
    handle_error "Template file '$TEMPLATE_FILE' not found."
fi

echo "1. Validating template syntax...."
aws cloudformation validate-template --template-body file://"$TEMPLATE_FILE" --region "$REGION" > /dev/null || handle_error "Template validation failed."

# 2. Determine Change Set Type
# Check if stack exists to decide between CREATE or UPDATE
if aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" >/dev/null 2>&1; then
    ACTION_TYPE="UPDATE"
    echo "Stack exists. Preparing an UPDATE change set..."
else
    ACTION_TYPE="CREATE"
    echo "Stack does not exist. Preparing a CREATE change set..."
fi

CHANGESET_NAME="${STACK_NAME}-$(date +%s)"

# 3. Create Change Set
echo "Creating change set..."
aws cloudformation create-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME" \
    --template-body file://"$TEMPLATE_FILE" \
    --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM \
    --change-set-type "$ACTION_TYPE" \
    --parameters "[
        {\"ParameterKey\":\"Enviroment\",\"ParameterValue\":\"$ENV\"},
        {\"ParameterKey\":\"ProjectName\",\"ParameterValue\":\"$PROJECT_NAME\"}
    ]" \
    --region "$REGION" || handle_error "Failed to create change set."

# 4. Wait for Change Set Creation
echo "Waiting for change set to be ready..."
aws cloudformation wait change-set-create-complete \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME" \
    --region "$REGION" || true

# 5. Check if there are actually changes to apply
DESCRIBE_STATUS=$(aws cloudformation describe-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME" \
    --region "$REGION")

STATUS_REASON=$(echo $DESCRIBE_STATUS | jq -r '.StatusReason')
EXECUTION_STATUS=$(echo $DESCRIBE_STATUS | jq -r '.ExecutionStatus')

if [[ "$STATUS_REASON" == *"The submitted information didn't contain any changes"* ]] || [[ "$EXECUTION_STATUS" == "UNAVAILABLE" ]]; then
    echo "✅ No changes detected. Nothing to deploy."
    aws cloudformation delete-change-set \
        --stack-name "$STACK_NAME" \
        --change-set-name "$CHANGESET_NAME" \
        --region "$REGION"
    exit 0
fi

# If it failed for any OTHER reason, then actually exit with error
if [[ $(echo $DESCRIBE_STATUS | jq -r '.Status') == "FAILED" ]]; then
    handle_error "Change set creation failed: $STATUS_REASON"
fi

# 6. Execute Change Set
echo "Executing Change Set..."
aws cloudformation execute-change-set \
    --stack-name "$STACK_NAME" \
    --change-set-name "$CHANGESET_NAME" \
    --region "$REGION" || handle_error "Failed to execute change set."

# 7. Wait for Completion
echo "Waiting for stack operation to finish..."
if [ "$ACTION_TYPE" == "CREATE" ]; then
    aws cloudformation wait stack-create-complete --stack-name "$STACK_NAME" --region "$REGION"
else
    aws cloudformation wait stack-update-complete --stack-name "$STACK_NAME" --region "$REGION"
fi

echo "--- Deployment Complete! ---"
aws cloudformation describe-stacks --stack-name "$STACK_NAME" --region "$REGION" --query "Stacks[0].Outputs" --output table