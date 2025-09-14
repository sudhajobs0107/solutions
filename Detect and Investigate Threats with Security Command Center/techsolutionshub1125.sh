#!/bin/bash

# Define color variables
BLACK_TEXT=$'\033[0;90m'
RED_TEXT=$'\033[0;91m'
GREEN_TEXT=$'\033[0;92m'
YELLOW_TEXT=$'\033[0;93m'
BLUE_TEXT=$'\033[0;94m'
MAGENTA_TEXT=$'\033[0;95m'
CYAN_TEXT=$'\033[0;96m'
WHITE_TEXT=$'\033[0;97m'
BG_MAGENTA=$'\033[45m'

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Clear the screen
clear


# Print the welcome message
echo "${YELLOW_TEXT}===================================================${RESET_FORMAT}"
echo "${YELLOW_TEXT}||     Welcome to ${BOLD_TEXT}TechSolutionsHub${RESET_FORMAT}${YELLOW_TEXT} Tutorials     ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||        ████████╗ ████████╗ ██╗  ██╗           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██╔══╝ ██╔═════╝ ██║  ██║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ████████╗ ███████║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ╚═════██║ ██╔══██║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ████████║ ██║  ██║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ╚═╝    ╚═══════╝ ╚═╝  ╚═╝           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||      Subscribe to our YouTube Channel :-      ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||  ${CYAN_TEXT}https://www.youtube.com/@techsolutionshub01${RESET_FORMAT}${YELLOW_TEXT}  ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ${BOLD_TEXT}INITIATING EXECUTION...${RESET_FORMAT}${YELLOW_TEXT}             ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}===================================================${RESET_FORMAT}"
echo

# Instruction for setting project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}Fetching the current project ID...${RESET_FORMAT}"
PROJECT_ID=$(gcloud config get-value project 2> /dev/null)
if [[ "$PROJECT_ID" == "(unset)" || -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud projects list --format="value(projectId)" --limit=1)
  gcloud config set project $PROJECT_ID
fi
export PROJECT_ID
echo "${BG_MAGENTA}${BOLD_TEXT}Project ID is:-${RESET_FORMAT} $PROJECT_ID"

gcloud auth list

export ZONE=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe \
--format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Step 2: Get IAM Policy and Save to JSON
echo "${BLUE_TEXT}${BOLD_TEXT}Retrieving IAM Policy...${RESET_FORMAT}"
gcloud projects get-iam-policy $(gcloud config get-value project) \
    --format=json > policy.json

# Step 3: Update IAM Policy
echo "${GREEN_TEXT}${BOLD_TEXT}Updating IAM Policy...${RESET_FORMAT}"
jq '{ 
  "auditConfigs": [ 
    { 
      "service": "cloudresourcemanager.googleapis.com", 
      "auditLogConfigs": [ 
        { 
          "logType": "ADMIN_READ" 
        } 
      ] 
    } 
  ] 
} + .' policy.json > updated_policy.json

# Step 4: Set Updated IAM Policy
echo "${RED_TEXT}${BOLD_TEXT}Applying Updated IAM Policy...${RESET_FORMAT}"
gcloud projects set-iam-policy $(gcloud config get-value project) updated_policy.json

# Step 5: Enable Security Center API
echo "${CYAN_TEXT}${BOLD_TEXT}Enabling Security Center API...${RESET_FORMAT}"
gcloud services enable securitycenter.googleapis.com --project=$DEVSHELL_PROJECT_ID

# Step 6: Wait for 20 seconds
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for API to be enabled...${RESET_FORMAT}"
sleep 20

# Step 7: Add IAM Binding for BigQuery Admin
echo "${MAGENTA_TEXT}${BOLD_TEXT}Granting BigQuery Admin Role...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 8: Remove IAM Binding for BigQuery Admin
echo "${BLUE_TEXT}${BOLD_TEXT}Revoking BigQuery Admin Role...${RESET_FORMAT}"
gcloud projects remove-iam-policy-binding $DEVSHELL_PROJECT_ID \
--member=user:demouser1@gmail.com --role=roles/bigquery.admin

# Step 9: Add IAM Binding for IAM Admin
echo "${GREEN_TEXT}${BOLD_TEXT}Granting IAM Admin Role...${RESET_FORMAT}"
gcloud projects add-iam-policy-binding $DEVSHELL_PROJECT_ID \
  --member=user:$USER_EMAIL \
  --role=roles/cloudresourcemanager.projectIamAdmin 2>/dev/null

# Step 10: Create Compute Instance
echo "${BLUE_TEXT}${BOLD_TEXT}Creating Compute Instance...${RESET_FORMAT}"
gcloud compute instances create instance-1 \
--zone=$ZONE \
--machine-type=e2-medium \
--network-interface=network-tier=PREMIUM,stack-type=IPV4_ONLY,subnet=default \
--metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD \
--scopes=https://www.googleapis.com/auth/cloud-platform --create-disk=auto-delete=yes,boot=yes,device-name=instance-1,image=projects/debian-cloud/global/images/debian-11-bullseye-v20230912,mode=rw,size=10,type=projects/$DEVSHELL_PROJECT_ID/zones/$ZONE/diskTypes/pd-balanced

# Step 11: Create DNS Policy
echo "${CYAN_TEXT}${BOLD_TEXT}Creating DNS Policy...${RESET_FORMAT}"
gcloud dns --project=$DEVSHELL_PROJECT_ID policies create dns-test-policy --description="techsolutionshub" --networks="default" --private-alternative-name-servers="" --no-enable-inbound-forwarding --enable-logging

# Step 12: Wait for 30 seconds
echo "${YELLOW_TEXT}${BOLD_TEXT}Waiting for DNS Policy to take effect...${RESET_FORMAT}"
sleep 30

# Step 13: SSH into Compute Instance and Execute Commands
echo "${MAGENTA_TEXT}${BOLD_TEXT}Connecting to Compute Instance...${RESET_FORMAT}"
gcloud compute ssh instance-1 --zone=$ZONE --tunnel-through-iap --project "$DEVSHELL_PROJECT_ID" --quiet --command "gcloud projects get-iam-policy \$(gcloud config get project) && curl etd-malware-trigger.goog"

# Function to prompt user to check their progress
function check_progress {
    while true; do
        echo
        echo -n "${BOLD_TEXT}${YELLOW_TEXT}Have you checked your progress for Task 1 & Task 2? (Y/N): ${RESET_FORMAT}"
        read -r user_input
        if [[ "$user_input" == "Y" || "$user_input" == "y" ]]; then
            echo
            echo "${BOLD_TEXT}${GREEN_TEXT}Great! Proceeding to the next steps...${RESET_FORMAT}"
            echo
            break
        elif [[ "$user_input" == "N" || "$user_input" == "n" ]]; then
            echo
            echo "${BOLD_TEXT}${RED_TEXT}Please check your progress for Task 1 & Task 2 and then press Y to continue.${RESET_FORMAT}"
        else
            echo
            echo "${BOLD_TEXT}${MAGENTA_TEXT}Invalid input. Please enter Y or N.${RESET_FORMAT}"
        fi
    done
}

# Call function to check progress before proceeding
check_progress

# Step 14: Delete Compute Instance
echo "${BLUE}${BOLD}Deleting Compute Instance...${RESET}"
gcloud compute instances delete instance-1 --zone=$ZONE --quiet

echo

function show_subscription_prompt() {
    echo "${GREEN_TEXT}=======================================================${RESET_FORMAT}"
    echo "${GREEN_TEXT}||             ${BOLD_TEXT}LAB COMPLETED SUCCESSFULLY!           ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||   Thank you for using ${BOLD_TEXT}TechSolutionsHub${RESET_FORMAT}${GREEN_TEXT} Tutorials  ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||  For more tutorials, visit our YouTube Channel:-  ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||    ${CYAN_TEXT}https://www.youtube.com/@techsolutionshub01${RESET_FORMAT}${GREEN_TEXT}    ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}||      Don't forget to ${RED_TEXT}${BOLD_TEXT}LIKE,${RESET_FORMAT} ${RED_TEXT}${BOLD_TEXT}SHARE${RESET_FORMAT} ${GREEN_TEXT}and${RESET_FORMAT} ${RED_TEXT}${BOLD_TEXT}SUBSCRIBE${RESET_FORMAT}${GREEN_TEXT}    ||${RESET_FORMAT}"
    echo "${GREEN_TEXT}=======================================================${RESET_FORMAT}"
    }

# Display subscription prompt
show_subscription_prompt

echo -e "\n"  # Adding one blank line

cd

remove_files() {
    # Loop through all files in the current directory
    for file in *; do
        # Check if the file name starts with "gsp", "arc", or "shell"
        if [[ "$file" == gsp* || "$file" == arc* || "$file" == shell* ]]; then
            # Check if it's a regular file (not a directory)
            if [[ -f "$file" ]]; then
                # Remove the file and echo the file name
                rm "$file"
                echo "File removed: $file"
            fi
        fi
    done
}

remove_files

