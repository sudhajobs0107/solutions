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

export PROJECT_ID=$DEVSHELL_PROJECT_ID

echo "Please set the required values for the lab"
read -p "📍 ${BG_MAGENTA}${BOLD_TEXT}Enter your ZONE 1:-${RESET_FORMAT} " ZONE_1
read -p "📍 ${BG_MAGENTA}${BOLD_TEXT}Enter your ZONE 2:-${RESET_FORMAT} " ZONE_2
read -p "📍 ${BG_MAGENTA}${BOLD_TEXT}Enter VPN Shared Secret:-${RESET_FORMAT} " VPN_SECRET

# Export variables after collecting input
export ZONE_1
export ZONE_2
export REGION_1="${ZONE_1%-*}"
export REGION="${ZONE_2%-*}"

echo
echo "${GREEN_TEXT}${BOLD_TEXT}Setting up environment...${RESET_FORMAT}"
echo "${BG_MAGENTA}${BOLD_TEXT}ZONE 1:- ${RESET_FORMAT} $ZONE_1"
echo "${BG_MAGENTA}${BOLD_TEXT}REGION 1:- ${RESET_FORMAT} $REGION_1"
echo "${BG_MAGENTA}${BOLD_TEXT}ZONE 2:- ${RESET_FORMAT} $ZONE_2"
echo "${BG_MAGENTA}${BOLD_TEXT}REGION 2:- ${RESET_FORMAT} $REGION"

# Create cloud network
echo
echo "${MAGENTA_TEXT}This lab is part of TechSolutionsHub Cloud Tutorials${RESET_FORMAT}"
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating Cloud network...${RESET_FORMAT}"
gcloud compute networks create cloud --subnet-mode custom

# Create firewall rules for cloud
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating firewall rules for cloud network...${RESET_FORMAT}"
gcloud compute firewall-rules create cloud-fw --network cloud --allow tcp:22,tcp:5001,udp:5001,icmp

# Create cloud subnet
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating cloud-east subnet...${RESET_FORMAT}"
gcloud compute networks subnets create cloud-east --network cloud \
    --range 10.0.1.0/24 --region $REGION_1

# Create on-prem network
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating On-prem network...${RESET_FORMAT}"
gcloud compute networks create on-prem --subnet-mode custom

# Create firewall rules for on-prem
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating firewall rules for on-prem network...${RESET_FORMAT}"
gcloud compute firewall-rules create on-prem-fw --network on-prem --allow tcp:22,tcp:5001,udp:5001,icmp

# Create on-prem subnet
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating on-prem-central subnet...${RESET_FORMAT}"
gcloud compute networks subnets create on-prem-central \
    --network on-prem --range 192.168.1.0/24 --region $REGION

# Create VPN gateways
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating VPN Gateways...${RESET_FORMAT}"
gcloud compute target-vpn-gateways create on-prem-gw1 --network on-prem --region $REGION
gcloud compute target-vpn-gateways create cloud-gw1 --network cloud --region $REGION_1

# Create static IP addresses
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating static IP addresses...${RESET_FORMAT}"
gcloud compute addresses create cloud-gw1 --region $REGION_1
gcloud compute addresses create on-prem-gw1 --region $REGION

# Get IP addresses
cloud_gw1_ip=$(gcloud compute addresses describe cloud-gw1 \
    --region $REGION_1 --format='value(address)')

on_prem_gw_ip=$(gcloud compute addresses describe on-prem-gw1 \
    --region $REGION --format='value(address)')

echo "${BLUE_TEXT}Cloud Gateway IP: $cloud_gw1_ip${RESET_FORMAT}"
echo "${BLUE_TEXT}On-prem Gateway IP: $on_prem_gw_ip${RESET_FORMAT}"

# Create forwarding rules for cloud gateway
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating forwarding rules for Cloud Gateway...${RESET_FORMAT}"
gcloud compute forwarding-rules create cloud-1-fr-esp --ip-protocol ESP \
    --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region $REGION_1

gcloud compute forwarding-rules create cloud-1-fr-udp500 --ip-protocol UDP \
    --ports 500 --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region $REGION_1

gcloud compute forwarding-rules create cloud-fr-1-udp4500 --ip-protocol UDP \
    --ports 4500 --address $cloud_gw1_ip --target-vpn-gateway cloud-gw1 --region $REGION_1

# Create forwarding rules for on-prem gateway
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating forwarding rules for On-prem Gateway...${RESET_FORMAT}"
gcloud compute forwarding-rules create on-prem-fr-esp --ip-protocol ESP \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region $REGION

gcloud compute forwarding-rules create on-prem-fr-udp500 --ip-protocol UDP --ports 500 \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region $REGION

gcloud compute forwarding-rules create on-prem-fr-udp4500 --ip-protocol UDP --ports 4500 \
    --address $on_prem_gw_ip --target-vpn-gateway on-prem-gw1 --region $REGION

# Create VPN tunnels
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating VPN Tunnels...${RESET_FORMAT}"
gcloud compute vpn-tunnels create on-prem-tunnel1 --peer-address $cloud_gw1_ip \
    --target-vpn-gateway on-prem-gw1 --ike-version 2 --local-traffic-selector 0.0.0.0/0 \
    --remote-traffic-selector 0.0.0.0/0 --shared-secret=$VPN_SECRET --region $REGION

gcloud compute vpn-tunnels create cloud-tunnel1 --peer-address $on_prem_gw_ip \
    --target-vpn-gateway cloud-gw1 --ike-version 2 --local-traffic-selector 0.0.0.0/0 \
    --remote-traffic-selector 0.0.0.0/0 --shared-secret=$VPN_SECRET --region $REGION_1

# Create routes
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating Network Routes...${RESET_FORMAT}"
gcloud compute routes create on-prem-route1 --destination-range 10.0.1.0/24 \
    --network on-prem --next-hop-vpn-tunnel on-prem-tunnel1 \
    --next-hop-vpn-tunnel-region $REGION

gcloud compute routes create cloud-route1 --destination-range 192.168.1.0/24 \
    --network cloud --next-hop-vpn-tunnel cloud-tunnel1 --next-hop-vpn-tunnel-region $REGION_1

# Create test instances
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Creating Test Instances...${RESET_FORMAT}"
gcloud compute instances create "cloud-loadtest" --zone $ZONE_1 \
    --machine-type "e2-standard-4" --subnet "cloud-east" \
    --image-family "debian-11" --image-project "debian-cloud" --boot-disk-size "10" \
    --boot-disk-type "pd-standard" --boot-disk-device-name "cloud-loadtest"

gcloud compute instances create "on-prem-loadtest" --zone $ZONE_2 \
    --machine-type "e2-standard-4" --subnet "on-prem-central" \
    --image-family "debian-11" --image-project "debian-cloud" --boot-disk-size "10" \
    --boot-disk-type "pd-standard" --boot-disk-device-name "on-prem-loadtest"

echo
echo -e "${GREEN_TEXT}${BOLD_TEXT}Waiting for instances to be ready...${RESET_FORMAT}"
echo "Waiting 1 minute for instances to be ready..."

for i in {1..60}; do
    printf "\r%02d/60 seconds elapsed...$(tput el)" "$i"
    sleep 1
done


echo ""
# Run network performance test
echo
echo "${YELLOW_TEXT}${BOLD_TEXT}Starting Network Performance Test...${RESET_FORMAT}"
echo "${MAGENTA_TEXT}Testing VPN connectivity between cloud and on-prem networks${RESET_FORMAT}"

# Start iperf server on on-prem instance
echo "${BLUE_TEXT}Starting iperf server on on-prem instance...${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE_2" "on-prem-loadtest" --project "$PROJECT_ID" --quiet --command "sudo apt-get update && sudo apt-get install -y iperf && iperf -s -i 5" &

echo "${BLUE_TEXT}Waiting for server to start...${RESET_FORMAT}"
echo "Waiting 10 sec for server to start..."

for i in {1..10}; do
    printf "\r%02d/10 seconds elapsed...$(tput el)" "$i"
    sleep 1
done


# Run iperf client from cloud instance
echo "${BLUE_TEXT}Running iperf client from cloud instance...${RESET_FORMAT}"
gcloud compute ssh --zone "$ZONE_1" "cloud-loadtest" --project "$PROJECT_ID" --quiet --command "sudo apt-get update && sudo apt-get install -y iperf && iperf -c 192.168.1.2 -P 20 -x C"


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
