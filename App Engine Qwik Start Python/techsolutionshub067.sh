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


# --------------------------
# Function: Retry API enabling
# --------------------------
enable_api_with_retry() {
  local api=$1
  local retries=5
  local wait=5
  local count=0
  until gcloud services enable "$api" --quiet; do
    count=$((count+1))
    if [ $count -ge $retries ]; then
      echo "❌ Failed to enable $api after $retries attempts"
      exit 1
    fi
    echo "🔁 Retrying to enable $api ($count/$retries)..."
    sleep $wait
  done
}

# --------------------------
# Auth Check
# --------------------------
echo "🔐 Checking authenticated accounts..."
gcloud auth list

# --------------------------
# Enable App Engine API
# --------------------------
echo "⚙️ Enabling App Engine Admin API..."
enable_api_with_retry appengine.googleapis.com

# --------------------------
# Set ZONE and REGION
# --------------------------
echo "📍 Fetching zone and region from project metadata..."
ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])" || true)

if [[ -z "$ZONE" ]]; then
  read -p "⚠️ Default zone not found. Please enter your compute zone (e.g., us-central1-a): " ZONE
  if [[ -z "$ZONE" ]]; then
    echo "❌ Zone is required to continue."
    exit 1
  fi
fi

REGION="${ZONE%-*}"
echo "✅ ${BG_MAGENTA}${BOLD_TEXT}Zone:-${RESET_FORMAT} $ZONE"
echo "✅ ${BG_MAGENTA}${BOLD_TEXT}Derived Region:-${RESET_FORMAT} $REGION"

gcloud config set compute/zone "$ZONE"
gcloud config set compute/region "$REGION"

# --------------------------
# Clone sample repo (if needed)
# --------------------------
if [[ ! -d "python-docs-samples" ]]; then
  echo "📥 Cloning Python sample app..."
  git clone https://github.com/GoogleCloudPlatform/python-docs-samples.git
fi

cd python-docs-samples/appengine/standard_python3/hello_world

# --------------------------
# Modify app content
# --------------------------
echo "✏️ Updating app message..."
sed -i 's/Hello World!/Hello, Cruel World!/g' main.py

# --------------------------
# Create App Engine app (if not already created)
# --------------------------
if gcloud app describe --project="$PROJECT_ID" &> /dev/null; then
  echo "✅ App Engine app already exists in this project."
else
  echo "🚀 Creating App Engine app in region: $REGION..."
  gcloud app create --region="$REGION"
fi

# --------------------------
# Deploy with retry logic
# --------------------------
deploy_with_retry() {
  local retries=3
  local wait=10
  local count=0
  until gcloud app deploy --quiet; do
    count=$((count+1))
    if [ $count -ge $retries ]; then
      echo "❌ Deployment failed after $retries attempts"
      exit 1
    fi
    echo "🔁 Retrying deployment ($count/$retries)..."
    sleep $wait
  done
}

echo "🚀 Deploying App Engine application..."
deploy_with_retry

echo "✅ Deployment complete."
gcloud app browse


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


