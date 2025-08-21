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

NO_COLOR=$'\033[0m'
RESET_FORMAT=$'\033[0m'
BOLD_TEXT=$'\033[1m'
UNDERLINE_TEXT=$'\033[4m'

# Clear the screen
clear


# Print the welcome message
echo "${YELLOW_TEXT}===================================================${RESET_FORMAT}"
echo "${YELLOW_TEXT}||     Welcome to ${BOLD_TEXT}TechLootHub${RESET_FORMAT}${YELLOW_TEXT} Tutorials          ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||        ████████╗ ██╗      ██╗  ██╗            ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██╔══╝ ██║      ██║  ██║            ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ██║      ███████║            ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ██║      ██╔══██║            ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ███████╗ ██║  ██║            ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ╚═╝    ╚══════╝ ╚═╝  ╚═╝            ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||      Subscribe to our YouTube Channel :-      ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||      ${CYAN_TEXT}https://www.youtube.com/@techloothub${RESET_FORMAT}${YELLOW_TEXT}     ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ${BOLD_TEXT}INITIATING EXECUTION...${RESET_FORMAT}${YELLOW_TEXT}             ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}===================================================${RESET_FORMAT}"
echo

# Instruction for setting project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}Fetching the current project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
echo $PROJECT_ID
read -p "${YELLOW}${BOLD}Enter your ZONE: " ZONE
export ZONE
gcloud auth list
gcloud config set compute/zone $ZONE
export REGION=${ZONE%-*}
gcloud config set compute/region $REGION
gsutil mb gs://$PROJECT_ID

gsutil cp -r gs://spls/gsp087/* gs://$PROJECT_ID


gcloud compute instance-templates create autoscaling-instance01 --metadata=startup-script-url=gs://$PROJECT_ID/startup.sh,gcs-bucket=gs://$PROJECT_ID


gcloud beta compute instance-groups managed create autoscaling-instance-group-1 --project=$PROJECT_ID --zone=$ZONE --base-instance-name=autoscaling-instance-group-1 --size=1 --template=projects/$PROJECT_ID/global/instanceTemplates/autoscaling-instance01 --list-managed-instances-results=PAGELESS --no-force-update-on-repair --default-action-on-vm-failure=repair


gcloud beta compute instance-groups managed set-autoscaling autoscaling-instance-group-1 --project=$PROJECT_ID --zone=$ZONE --cool-down-period=60  --max-num-replicas=3 --min-num-replicas=1 --mode=on --target-cpu-utilization=0.6 --stackdriver-metric-filter=resource.type\ =\ \"gce_instance\" --update-stackdriver-metric=custom.googleapis.com/appdemo_queue_depth_01 --stackdriver-metric-utilization-target=150.0 --stackdriver-metric-utilization-target-type=gauge


# Completion Message
echo
echo "${GREEN_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}||             ${BOLD_TEXT}LAB COMPLETED SUCCESSFULLY!           ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||     Thank you for using ${BOLD_TEXT}TechLootHub${RESET_FORMAT}${GREEN_TEXT} Tutorials     ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||  For more tutorials, visit our YouTube Channel:-  ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||       ${CYAN_TEXT}https://www.youtube.com/@techloothub${RESET_FORMAT}${GREEN_TEXT}        ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||      Don't forget to ${RED_TEXT}${BOLD_TEXT}LIKE,${RESET_FORMAT} ${RED_TEXT}${BOLD_TEXT}SHARE${RESET_FORMAT} ${GREEN_TEXT}and${RESET_FORMAT} ${RED_TEXT}${BOLD_TEXT}SUBSCRIBE${RESET_FORMAT}${GREEN_TEXT}    ||${RESET_FORMAT}"
echo "${GREEN_TEXT}=======================================================${RESET_FORMAT}"
echo ""
