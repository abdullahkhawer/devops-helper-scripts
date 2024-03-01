#!/bin/bash

# Purpose:
# - Shell script to fetch all the AWS SSM parameters from Parameter Store and print their decrypted values.
# Prerequisites:
# - AWS CLI is installed and configured.
# - jq is installed.
# Usage Example:
# - bash print-all-aws-ssm-parameters-values.sh

# get list of all parameter names
parameter_names=$(aws ssm describe-parameters --query 'Parameters[*].Name' --output json | jq -r '.[]')

# loop through each parameter name and print its value
echo "$parameter_names" | while IFS= read -r param_name; do
    param_value=$(aws ssm get-parameter --name "$param_name" --query 'Parameter.Value' --with-decryption --output text)
    echo "Parameter: $param_name - Value: $param_value"
done
