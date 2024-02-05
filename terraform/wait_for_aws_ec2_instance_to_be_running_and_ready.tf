# Purpose:
# - Terraform template to wait for an AWS EC2 instance to be running and complete status checks.
# Prerequisites:
# - AWS CLI is installed and configured.
# - Terraform is installed.
# Usage Instruction:
# - var.aws_ec2_instance_id needs to be replaced with the actual AWS EC2 instance id.

resource "null_resource" "wait_for_instance" {
  triggers = {
    instance_id = var.aws_ec2_instance_id
  }

  provisioner "local-exec" {
    command = <<EOF
      timeout=600  # Timeout in seconds
      start_time=$(date +%s)

      until [ "$(aws ec2 describe-instance-status --instance-id ${self.triggers.instance_id} --query 'InstanceStatuses[0].InstanceStatus.Status' --output text)" = "ok" ] && \
            [ "$(aws ec2 describe-instance-status --instance-id ${self.triggers.instance_id} --query 'InstanceStatuses[0].SystemStatus.Status' --output text)" = "ok" ] && \
            [ "$(aws ec2 describe-instances --instance-ids ${self.triggers.instance_id} --query 'Reservations[0].Instances[0].State.Name' --output text)" = "running" ]; do
        current_time=$(date +%s)
        elapsed_time=$((current_time - start_time))

        if [ "$elapsed_time" -ge "$timeout" ]; then
          echo "Timeout reached. Instance didn't reach the desired state within $timeout seconds."
          exit 1
        fi

        sleep 5
        echo "Waiting for instance to be running and complete status checks..."
      done

      echo "Instance is now running fine and status checks have been completed!"
    EOF
  }
}
