#!/bin/bash

# Purpose:
# - Shell script for GitLab to fetch all members from one repository and add them to another repository except the blocked members.
# Prerequisites:
# - jq is installed.
# Usage Example:
# - bash gitlab-add-members-from-one-repo-to-another.sh "https://gitlab.com" "__REDACTED" "12" "367" "30"

# Define variables
GITLAB_URL="$1"
PRIVATE_TOKEN="$2"
SOURCE_PROJECT_ID="$3"
TARGET_PROJECT_ID="$4"
ACCESS_LEVEL="$5"

# Function to fetch members from a project with pagination
fetch_members() {
  local project_id=$1
  local page=1
  local per_page=100
  local all_members="["

  # Loop until all members are fetched
  while : ; do
    # Fetch members for the current page
    response=$(curl --silent --show-error --request GET "$GITLAB_URL/api/v4/projects/$project_id/members/all?page=$page&per_page=$per_page" \
      --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
      --header "Content-Type: application/json")

    # Check for errors in the response
    if echo "$response" | grep -q "message"; then
      echo "Error fetching members from project $project_id: $response"
      exit 1
    fi

    # Extract relevant member information using jq
    members=$(echo "$response" | jq -c '.[] | {id, username, name, email, state}')

    # Check if there are no more members to fetch
    if [ -z "$members" ]; then
      break
    fi

    # Append members to the JSON array
    all_members+="${members},"

    page=$((page + 1))
  done

  # Replace "} {" with "}, {" to form a valid JSON array
  all_members=$(echo $all_members | sed 's/} {/}, {/g')

  # Remove the trailing comma and close the JSON array
  all_members="${all_members%,}]"

  echo "$all_members"
}

# Fetch members from the source project
members=$(fetch_members $SOURCE_PROJECT_ID)

# Loop through each member and add them to the target project
echo "$members" | jq -c '.[]' | while read -r member; do
  USER_ID=$(echo "$member" | jq '.id')
  USERNAME=$(echo "$member" | jq -r '.username')
  NAME=$(echo "$member" | jq -r '.name')
  EMAIL=$(echo "$member" | jq -r '.email')
  STATE=$(echo "$member" | jq -r '.state')

  # Check if the member is blocked, if yes, skip adding
  if [ "$STATE" == "blocked" ]; then
    echo "Member (USERNAME: $USERNAME, NAME: $NAME, EMAIL: $EMAIL) is in $STATE state. So, skipping it."
    continue
  fi

  # GitLab API endpoint to add a member to the target project
  API_URL="$GITLAB_URL/api/v4/projects/$TARGET_PROJECT_ID/members"

  # Add the member to the target project
  response=$(curl --silent --show-error --request POST "$API_URL" \
    --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" \
    --header "Content-Type: application/json" \
    --data "{
      \"user_id\": $USER_ID,
      \"access_level\": $ACCESS_LEVEL
    }")

  # Check if the response contains an error
  if echo "$response" | grep -q "message"; then
    if echo "$response" | grep -q "Member already exists"; then
      echo "Member (USERNAME: $USERNAME, NAME: $NAME, EMAIL: $EMAIL) already exists in target project."
    else
      echo "Error adding member (USERNAME: $USERNAME, NAME: $NAME, EMAIL: $EMAIL) to target project: $response"
    fi
  else
    echo "Member (USERNAME: $USERNAME, NAME: $NAME, EMAIL: $EMAIL) added successfully to target project."
  fi
done
