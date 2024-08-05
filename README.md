# ECS Task Definition Updater

This repository contains a Bash script designed to update an AWS ECS service with a new Docker image. The script automates the process of modifying an ECS task definition with a new image, registering the updated task definition, and updating the ECS service to use the new task definition.

## Script Overview

The `script.sh` script performs the following actions:

1. Retrieves the current task definition from AWS ECS.
2. Updates the Docker image in the task definition.
3. Registers the new task definition with AWS ECS.
4. Updates the specified ECS service to use the new task definition.

## Usage

To use the script, provide the following command-line arguments:

```sh
./script.sh --task-family <task-family> --region <region> --new-image <new_image> --cluster <cluster> --service <service>
```

## Arguments

- --task-family : The name of the ECS task family you want to update.
- --region : The AWS region where your ECS service and task family are located.
- --new-image : The Docker image URI to replace the existing image in the task definition.
- --cluster : The name of the ECS cluster containing the service.
- --service : The name of the ECS service to update with the new task definition.

## Example

```sh
./script.sh \
  --task-family my-task-family \
  --region us-west-2 \
  --new-image my-docker-repo/my-new-image:latest \
  --cluster my-cluster \
  --service my-service
```

## Requirements

- AWS CLI: Make sure you have the AWS CLI installed and configured with appropriate credentials.
- jq: This script uses jq for JSON parsing and manipulation. Ensure it is installed on your system.

## Script Details

### Debugging

- You can add set -x at the beginning of the script for debugging purposes to print each command before execution.

## Permissions

Before running the script, ensure it has executable permissions. You can set the executable bit with the following command:

```sh
chmod +x script.sh

```

## License

This script is provided as-is. Use it at your own risk. For any issues or contributions, please refer to the repository's issues page.

## Contributing

Feel free to submit issues or pull requests. Contributions are welcome!
