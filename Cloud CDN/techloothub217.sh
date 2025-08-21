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
gcloud auth list
BUCKET_NAME="$PROJECT_ID"

gsutil mb -l US gs://$BUCKET_NAME


gsutil cp gs://cloud-training/gcpnet/cdn/cdn.png gs://$BUCKET_NAME


gsutil iam ch allUsers:objectViewer gs://$BUCKET_NAME


TOKEN=$(gcloud auth application-default print-access-token)

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "bucketName": "'"$PROJECT_ID"'",
    "cdnPolicy": {
      "cacheMode": "CACHE_ALL_STATIC",
      "clientTtl": 60,
      "defaultTtl": 60,
      "maxTtl": 60,
      "negativeCaching": false,
      "serveWhileStale": 0
    },
    "compressionMode": "DISABLED",
    "description": "",
    "enableCdn": true,
    "name": "cdn-bucket"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/backendBuckets"

sleep 20

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "defaultService": "projects/'"$PROJECT_ID"'/global/backendBuckets/cdn-bucket",
    "name": "cdn-lb"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/urlMaps"


sleep 20

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "cdn-lb-target-proxy",
    "urlMap": "projects/'"$PROJECT_ID"'/global/urlMaps/cdn-lb"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/targetHttpProxies"


sleep 20

curl -X POST -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "IPProtocol": "TCP",
    "ipVersion": "IPV4",
    "loadBalancingScheme": "EXTERNAL_MANAGED",
    "name": "cdn-lb-forwarding-rule",
    "networkTier": "PREMIUM",
    "portRange": "80",
    "target": "projects/'"$PROJECT_ID"'/global/targetHttpProxies/cdn-lb-target-proxy"
  }' \
  "https://compute.googleapis.com/compute/v1/projects/$PROJECT_ID/global/forwardingRules"

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
