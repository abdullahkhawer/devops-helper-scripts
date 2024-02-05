#!/bin/bash

# Purpose:
# - To fetch the latest compatitble version of all the AWS EKS Add-ons installed on the AWS EKS cluster for a specific Kubernetes version.
# Prerequisites:
# - AWS CLI is installed and configured.
# - jq is installed.
# Usage Example:
# - bash get-latest-compatible-aws-eks-addon-version.sh "eks-prod" "us-east-1" "1.26"

cluster_name="$1"
region="$2"
kubernetes_version="$3"

addons=($(aws eks list-addons --cluster-name "$cluster_name" --region "$region" | jq -r '.addons[]'))

for addon in "${addons[@]}"
do
    aws eks describe-addon-versions \
        --kubernetes-version "$kubernetes_version" \
        --addon-name "$addon" \
        | jq --arg addon_name "$addon" \
        '.addons[] | select(.addonName == $addon_name) | {addonName: $addon_name, latestVersion: (.addonVersions | max_by(.addonVersion).addonVersion)}'
done
