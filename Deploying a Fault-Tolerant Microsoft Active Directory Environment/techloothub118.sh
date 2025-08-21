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
read -p "${YELLOW}${BOLD}Enter your REGION1: " region1
export region1
read -p "${YELLOW}${BOLD}Enter your REGION2: " region2
export region2
read -p "${YELLOW}${BOLD}Enter your ZONE_1: " zone_1
export zone_1
read -p "${YELLOW}${BOLD}Enter your ZONE_2: " zone_2
export zone_2
read -p "${YELLOW}${BOLD}Enter your VPC_NAME: " vpc_name
export vpc_name
export project_id=$(gcloud config get-value project)

gcloud auth list
gcloud config set compute/region ${region1}
gcloud compute networks create ${vpc_name}  \
    --description "VPC network to deploy Active Directory" \
    --subnet-mode custom


gcloud compute networks subnets create private-ad-zone-1 \
    --network ${vpc_name} \
    --range 10.1.0.0/24 \
    --region ${region1}


gcloud compute networks subnets create private-ad-zone-2 \
    --network ${vpc_name} \
    --range 10.2.0.0/24 \
    --region ${region2}


gcloud compute firewall-rules create allow-internal-ports-private-ad \
    --network ${vpc_name} \
    --allow tcp:1-65535,udp:1-65535,icmp \
    --source-ranges  10.1.0.0/24,10.2.0.0/24


gcloud compute firewall-rules create allow-rdp \
    --network ${vpc_name} \
    --allow tcp:3389 \
    --source-ranges 0.0.0.0/0

gcloud compute instances create ad-dc1 --machine-type e2-standard-2 \
    --boot-disk-type pd-ssd \
    --boot-disk-size 50GB \
    --image-family windows-2016 --image-project windows-cloud \
    --network ${vpc_name} \
    --zone ${zone_1} --subnet private-ad-zone-1 \
    --private-network-ip=10.1.0.100


export project_id=$(gcloud config get-value project)
gcloud config set compute/region ${region2}


gcloud compute instances create ad-dc2 --machine-type e2-standard-2 \
    --boot-disk-size 50GB \
    --boot-disk-type pd-ssd \
    --image-family windows-2016 --image-project windows-cloud \
    --can-ip-forward \
    --network ${vpc_name} \
    --zone ${zone_2} \
    --subnet private-ad-zone-2 \
    --private-network-ip=10.2.0.100

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
