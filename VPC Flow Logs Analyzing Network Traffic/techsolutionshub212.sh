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
echo "${YELLOW_TEXT}||     Welcome to ${BOLD_TEXT}TechSolutionsHub${RESET_FORMAT}${YELLOW_TEXT} Tutorials          ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||        ████████╗ ████████╗ ██╗  ██╗           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██╔══╝ ██╔═════╝ ██║  ██║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ████████╗ ███████║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ╚═════██║ ██╔══██║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ██║    ████████║ ██║  ██║           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ╚═╝    ╚═══════╝ ╚═╝  ╚═╝           ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||      Subscribe to our YouTube Channel :-      ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||      ${CYAN_TEXT}https://www.youtube.com/@techsolutionshub01${RESET_FORMAT}${YELLOW_TEXT}     ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||                                               ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}||           ${BOLD_TEXT}INITIATING EXECUTION...${RESET_FORMAT}${YELLOW_TEXT}             ||${RESET_FORMAT}"
echo "${YELLOW_TEXT}===================================================${RESET_FORMAT}"
echo

# Instruction for setting project ID
echo "${MAGENTA_TEXT}${BOLD_TEXT}Fetching the current project ID...${RESET_FORMAT}"
export PROJECT_ID=$(gcloud config get-value project)
echo $PROJECT_ID
gcloud auth list

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")


gcloud compute networks create vpc-net --project=$DEVSHELL_PROJECT_ID --description="Subscribe to Techcps" --subnet-mode=custom


gcloud compute networks subnets create vpc-subnet --project=$DEVSHELL_PROJECT_ID --network=vpc-net --region=$REGION --range=10.1.3.0/24 --enable-flow-logs


sleep 100


gcloud compute firewall-rules create allow-http-ssh \
  --project=$DEVSHELL_PROJECT_ID \
  --direction=INGRESS \
  --priority=1000 \
  --network=vpc-net \
  --action=ALLOW \
  --rules=tcp:80,tcp:22 \
  --source-ranges=0.0.0.0/0 \
  --target-tags=http-server


gcloud compute instances create web-server \
  --zone=$ZONE \
  --project=$DEVSHELL_PROJECT_ID \
  --machine-type=e2-micro \
  --subnet=vpc-subnet \
  --tags=http-server \
  --image-family=debian-11 \
  --image-project=debian-cloud \
  --metadata=startup-script='#!/bin/bash
    sudo apt update
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo systemctl enable apache2' \
  --labels=server=apache


gcloud compute firewall-rules create allow-http-alt \
    --allow=tcp:80 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server \
    --description="Allow HTTP traffic on alternate rule"



bq mk bq_vpc_flows



CP_IP=$(gcloud compute instances describe web-server --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

export MY_SERVER=$CP_IP

for ((i=1;i<=50;i++)); do curl $MY_SERVER; done

echo
echo -e "\e[1;33mEdit Firewall\e[0m \e[1;34mhttps://console.cloud.google.com/net-security/firewall-manager/firewall-policies/details/allow-http-ssh?project=$DEVSHELL_PROJECT_ID\e[0m"
echo
echo -e "\e[1;33mCreate an export sink\e[0m \e[1;34mhttps://console.cloud.google.com/logs/query;query=resource.type%3D%22gce_subnetwork%22%0Alog_name%3D%22projects%2F$DEVSHELL_PROJECT_ID%2Flogs%2Fcompute.googleapis.com%252Fvpc_flows%22;cursorTimestamp=2024-06-03T07:20:00.734122029Z;duration=PT1H?project=$DEVSHELL_PROJECT_ID\e[0m"
echo


while true; do
    echo -ne "\e[1;93mDo you Want to proceed? (Y/n): \e[0m"
    read confirm
    case "$confirm" in
        [Yy]) 
            echo -e "\e[34mRunning the command...\e[0m"
            break
            ;;
        [Nn]|"") 
            echo "Operation canceled."
            break
            ;;
        *) 
            echo -e "\e[31mInvalid input. Please enter Y or N.\e[0m" 
            ;;
    esac
done


CP_IP=$(gcloud compute instances describe web-server --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

export MY_SERVER=$CP_IP

for ((i=1;i<=50;i++)); do curl $MY_SERVER; done


CP_IP=$(gcloud compute instances describe web-server --zone=$ZONE --format='get(networkInterfaces[0].accessConfigs[0].natIP)')

export MY_SERVER=$CP_IP

for ((i=1;i<=50;i++)); do curl $MY_SERVER; done

# Completion Message
echo
echo "${GREEN_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}||             ${BOLD_TEXT}LAB COMPLETED SUCCESSFULLY!           ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||     Thank you for using ${BOLD_TEXT}TechSolutionsHub${RESET_FORMAT}${GREEN_TEXT} Tutorials     ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||  For more tutorials, visit our YouTube Channel:-  ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||       ${CYAN_TEXT}https://www.youtube.com/@techsolutionshub01${RESET_FORMAT}${GREEN_TEXT}        ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||                                                   ||${RESET_FORMAT}"
echo "${GREEN_TEXT}||      Don't forget to ${RED_TEXT}${BOLD_TEXT}LIKE,${RESET_FORMAT} ${RED_TEXT}${BOLD_TEXT}SHARE${RESET_FORMAT} ${GREEN_TEXT}and${RESET_FORMAT} ${RED_TEXT}${BOLD_TEXT}SUBSCRIBE${RESET_FORMAT}${GREEN_TEXT}    ||${RESET_FORMAT}"
echo "${GREEN_TEXT}=======================================================${RESET_FORMAT}"
echo ""
