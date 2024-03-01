# devops-helper-scripts
Repository having various helper scripts related to DevOps and AWS.

## List of DevOps Helper Scripts

* [Terraform](./terraform)
  * [wait_for_aws_ec2_instance_to_be_running_and_ready.tf](./terraform/wait_for_aws_ec2_instance_to_be_running_and_ready.tf)
    * Purpose: Terraform template to wait for an AWS EC2 instance to be running and complete status checks.
* [Shell](./shell)
  * [get-latest-compatible-aws-eks-addon-version.sh](./shell/get-latest-compatible-aws-eks-addon-version.sh)
    * Purpose: Shell script to fetch the latest compatible version of all the AWS EKS Add-ons installed on the AWS EKS cluster for a specific Kubernetes version.
* [Shell](./shell)
  * [print-all-aws-ssm-parameters-values.sh](./shell/print-all-aws-ssm-parameters-values.sh)
    * Purpose: Shell script to fetch all the AWS SSM parameters from Parameter Store and print their decrypted values.
