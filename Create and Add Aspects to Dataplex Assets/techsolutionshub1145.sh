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

read -p "${BG_MAGENTA}${BOLD_TEXT}Enter your REGION:-${RESET_FORMAT} " REGION
export REGION

# Variables
LAKE_NAME="orders-lake"
LAKE_DISPLAY_NAME="Orders Lake"
ZONE_NAME="customer-curated-zone"
ZONE_DISPLAY_NAME="Customer Curated Zone"
ASSET_NAME="customer-details-dataset"
ASSET_DISPLAY_NAME="Customer Details Dataset"
ASPECT_TYPE_ID="protected-data-aspect"
ASPECT_TYPE_DISPLAY_NAME="Protected Data Aspect"
ASPECT_JSON_FILE="aspect_type.json"

# 1. Create Lake
echo "Creating Dataplex lake..."
gcloud dataplex lakes create $LAKE_NAME \
  --project=$PROJECT_ID --location=$REGION --display-name="$LAKE_DISPLAY_NAME"

echo_warn "Waiting for lake to become ACTIVE..."
ATT=0
while true; do
  STATE=$(gcloud dataplex lakes describe $LAKE_NAME --project=$PROJECT_ID --location=$REGION --format='value(state)' 2>/dev/null)
  if [[ "$STATE" == "ACTIVE" ]]; then
    echo_success "Lake is ACTIVE."
    break
  fi
  ((ATT++)); [[ $ATT -ge 20 ]] && echo_error "Lake did not become ACTIVE in time." && exit 1
  echo_warn "Current state: $STATE. Retrying in 30s..."
  sleep 30
done

# 2. Create Curated Zone
echo "Creating curated zone..."
gcloud dataplex zones create $ZONE_NAME \
  --project=$PROJECT_ID --location=$REGION --lake=$LAKE_NAME \
  --display-name="$ZONE_DISPLAY_NAME" --type=CURATED --resource-location-type=SINGLE_REGION

echo_warn "Waiting for zone to become ACTIVE..."
ATT=0
while true; do
  STATE=$(gcloud dataplex zones describe $ZONE_NAME --project=$PROJECT_ID --lake=$LAKE_NAME --location=$REGION --format='value(state)' 2>/dev/null)
  if [[ "$STATE" == "ACTIVE" ]]; then
    echo_success "Zone is ACTIVE."
    break
  fi
  ((ATT++)); [[ $ATT -ge 20 ]] && echo_error "Zone did not become ACTIVE in time." && exit 1
  echo_warn "Current state: $STATE. Retrying in 30s..."
  sleep 30
done

# 3. Attach BigQuery Dataset as Asset
echo "Attaching BigQuery dataset asset..."
gcloud dataplex assets create $ASSET_NAME \
  --project=$PROJECT_ID --location=$REGION --lake=$LAKE_NAME --zone=$ZONE_NAME \
  --display-name="$ASSET_DISPLAY_NAME" --resource-type=BIGQUERY_DATASET \
  --resource-name=projects/$PROJECT_ID/datasets/customers --discovery-enabled

echo "Asset created."

echo "Proceed to the UI to apply aspects to table columns."

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
