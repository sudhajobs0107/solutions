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
echo "🧩 ${BG_MAGENTA}${BOLD_TEXT}Project ID is:-${RESET_FORMAT} $PROJECT_ID"

gcloud auth list

set -euo pipefail

HUB_NAME=ncc-hub

echo "Detecting region from existing VPN tunnels..."
REGION=$(gcloud compute vpn-tunnels list --format="value(region)" --limit=1)

if [[ -z "$REGION" ]]; then
  echo "Unable to detect region from VPN tunnels."
  exit 1
fi

echo "Region detected: $REGION"

# Create NCC Hub (location global)
if gcloud network-connectivity hubs describe $HUB_NAME --project=$PROJECT_ID >/dev/null 2>&1; then
  echo "Hub $HUB_NAME already exists, skipping creation."
else
  echo "Creating NCC hub $HUB_NAME..."
  gcloud network-connectivity hubs create $HUB_NAME \
    --project=$PROJECT_ID \
    --description="Global NCC Hub"
fi

# Gather VPN tunnels for On-Prem Offices
OFFICE1_TUNNELS=$(gcloud compute vpn-tunnels list --filter="name~'office1'" --format="value(name)")
OFFICE2_TUNNELS=$(gcloud compute vpn-tunnels list --filter="name~'office2'" --format="value(name)")

if [[ -z "$OFFICE1_TUNNELS" ]]; then
  echo "No Office 1 VPN tunnels found!"
  exit 1
fi

if [[ -z "$OFFICE2_TUNNELS" ]]; then
  echo "No Office 2 VPN tunnels found!"
  exit 1
fi

# Task 1: Connect two On-Prem VPCs using NCC (VPN spokes)

echo "Creating spokes for On-Prem Office 1 VPN tunnels..."
i=1
while read -r tunnel_name; do
  tunnel_full="projects/$PROJECT_ID/regions/$REGION/vpnTunnels/$tunnel_name"
  spoke_name="office-1-spoke-$i"
  echo "Creating spoke $spoke_name for tunnel $tunnel_name"

  gcloud alpha network-connectivity spokes create $spoke_name \
    --project=$PROJECT_ID \
    --hub=$HUB_NAME \
    --region=$REGION \
    --vpn-tunnel=$tunnel_full \
    --description="Spoke for On-Prem Office 1 tunnel $i" || echo "⚠️ $spoke_name may already exist."

  ((i++))
done <<< "$OFFICE1_TUNNELS"

echo "Creating spokes for On-Prem Office 2 VPN tunnels..."
i=1
while read -r tunnel_name; do
  tunnel_full="projects/$PROJECT_ID/regions/$REGION/vpnTunnels/$tunnel_name"
  spoke_name="office-2-spoke-$i"
  echo "Creating spoke $spoke_name for tunnel $tunnel_name"

  gcloud alpha network-connectivity spokes create $spoke_name \
    --project=$PROJECT_ID \
    --hub=$HUB_NAME \
    --region=$REGION \
    --vpn-tunnel=$tunnel_full \
    --description="Spoke for On-Prem Office 2 tunnel $i" || echo "⚠️ $spoke_name may already exist."

  ((i++))
done <<< "$OFFICE2_TUNNELS"


WORKLOAD_VPC1="workload-vpc-1"
WORKLOAD_VPC2="workload-vpc-2"

echo "Creating workload VPC spokes..."

gcloud network-connectivity spokes linked-vpc-network create workload-1-spoke \
  --project=$PROJECT_ID \
  --hub=$HUB_NAME \
  --vpc-network=$WORKLOAD_VPC1 \
  --global \
  --description="Spoke for Workload VPC 1" || echo "⚠️ workload-1-spoke may already exist."

gcloud network-connectivity spokes linked-vpc-network create workload-2-spoke \
  --project=$PROJECT_ID \
  --hub=$HUB_NAME \
  --vpc-network=$WORKLOAD_VPC2 \
  --global \
  --description="Spoke for Workload VPC 2" || echo "⚠️ workload-2-spoke may already exist."



echo "Creating hybrid spoke for Workload VPC 1..."

# gcloud alpha network-connectivity spokes create hybrid-workload-1-spoke \
#   --project=$PROJECT_ID \
#   --hub=$HUB_NAME \
#   --region=$REGION \
#   --vpc-network=projects/$PROJECT_ID/global/networks/$WORKLOAD_VPC1 \
#   --description="Hybrid spoke for Workload VPC 1" || echo "⚠️ hybrid-workload-1-spoke may already exist."

echo "Creating hybrid spokes for On-Prem Office 1 VPN tunnels..."
i=1
while read -r tunnel_name; do
  tunnel_full="projects/$PROJECT_ID/regions/$REGION/vpnTunnels/$tunnel_name"
  spoke_name="hybrid-office-1-spoke-$i"
  echo "Creating hybrid spoke $spoke_name for tunnel $tunnel_name"

  gcloud alpha network-connectivity spokes create $spoke_name \
    --project=$PROJECT_ID \
    --hub=$HUB_NAME \
    --region=$REGION \
    --vpn-tunnel=$tunnel_full \
    --description="Hybrid spoke for On-Prem Office 1 tunnel $i" || echo "⚠️ $spoke_name may already exist."

  ((i++))
done <<< "$OFFICE1_TUNNELS"



# Completion Message
echo
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
echo ""
