#!/bin/bash

# Initialize variables with default values
task_family=""
region=""
new_image=""
cluster=""
service=""
# Function to display usage information
usage() {
    echo "Usage: $0 --task-family <task-family> --region <region> --new-image <new_image> --cluster <cluster> --service <service>"
    exit 1
}

# Function to handle errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Function to display command descriptions
show_command_description() {
echo "$@"
}
# Check if no arguments are provided
if [ $# -eq 0 ]; then
    usage
fi

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --task-family)
            task_family="$2"
            shift 2 # Move to the next key-value pair
            ;;
        --new-image)
            new_image="$2"
            shift 2
            ;;
        --region)
            region="$2"
            shift 2
            ;;
        --cluster)
            cluster="$2"
            shift 2
            ;;
        --service)
        service="$2"
            shift 2
            ;;
        *) # Unknown option
            usage
            ;;
    esac
done

# Check if required arguments are missing
if [ -z "$task_family" ] || [ -z "$new_image" ] || [ -z "$region" ] ||[ -z "$cluster" ]||[ -z "$service" ]; then
    echo "Error: Missing required argument(s)."
    usage
fi

show_command_description "Getting task JSON for task family ..."
# Get and save task-def in var
TASK_DEFINITION=$(aws ecs describe-task-definition --task-definition "$task_family" --region "$region")
# Check if the command failed
if [ $? -ne 0 ]; then
    handle_error "Failed to retrieve task JSON for task family."
fi
show_command_description "Modifying task JSON with new image: $new_image"
# Modify  the json with new values
NEW_TASK_DEFINITION=$(echo $TASK_DEFINITION | jq --arg IMAGE "$new_image" \
    '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')
# Check if the command failed
if [ $? -ne 0 ]; then
handle_error "Failed to modify the task JSON for task family."
fi
show_command_description "Register the new task definition..."
NEW_TASK_INFO=$(aws ecs register-task-definition \
    --region "$region" \
    --cli-input-json "$NEW_TASK_DEFINITION")
# Check if the command failed
if [ $? -ne 0 ]; then
handle_error "Failed to register new task definition."
fi
# Extract the revision number of the newly registered task definition
REVISION=$(echo "$NEW_TASK_INFO" | jq -r '.taskDefinition.revision')
TASK_DEFINITION_NAME=$(echo "$NEW_TASK_INFO" | jq -r '.taskDefinition.family')

show_command_description "Update service with new revesion: $REVISION"
UPDATE_SERVICE=$(aws ecs update-service \
--region "$region" \
--cluster "$cluster" \
--service "$service" \
--task-definition "$TASK_DEFINITION_NAME":${REVISION} \
--force-new-deployment)

echo "Success"
