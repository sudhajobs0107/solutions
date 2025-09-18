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

read -p "${BG_MAGENTA}${BOLD_TEXT}Enter LANGUAGE (e.g., Japanese, English):-${RESET_FORMAT} " LANGUAGE
read -p "${BG_MAGENTA}${BOLD_TEXT}Enter LOCAL (e.g., en, fr, es):-${RESET_FORMAT} " LOCAL
read -p "${BG_MAGENTA}${BOLD_TEXT}Enter BIGQUERY_ROLE (e.g., roles/bigquery.admin):-${RESET_FORMAT} " BIGQUERY_ROLE
read -p "${BG_MAGENTA}${BOLD_TEXT}Enter CLOUD_STORAGE_ROLE (e.g., roles/storage.admin):-${RESET_FORMAT} " CLOUD_STORAGE_ROLE
# read -p "${BG_MAGENTA}${BOLD_TEXT}Enter GCS Bucket Name (e.g., my-bucket):-${RESET_FORMAT} " BUCKET_NAME
echo ""

# Create service account
echo "Creating service account 'sample-sa'..."
gcloud iam service-accounts create sample-sa
echo ""

# Assign IAM roles
echo "Assigning IAM roles to service account..."
gcloud projects add-iam-policy-binding "$DEVSHELL_PROJECT_ID" \
  --member="serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="$BIGQUERY_ROLE"

gcloud projects add-iam-policy-binding "$DEVSHELL_PROJECT_ID" \
  --member="serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="$CLOUD_STORAGE_ROLE"

gcloud projects add-iam-policy-binding "$DEVSHELL_PROJECT_ID" \
  --member="serviceAccount:sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageConsumer"
echo ""

# Wait for IAM propagation
echo "Waiting 2 minutes for IAM changes to propagate..."
for i in {1..120}; do
    echo -ne "$i/120 seconds elapsed...\r"
    sleep 1
done
echo ""

# Create service account key
echo "Creating service account key..."
gcloud iam service-accounts keys create sample-sa-key.json \
  --iam-account="sample-sa@$DEVSHELL_PROJECT_ID.iam.gserviceaccount.com"
export GOOGLE_APPLICATION_CREDENTIALS="${PWD}/sample-sa-key.json"
echo "Key created and environment variable set."
echo ""

# Download analysis script
echo "Downloading image analysis script..."
wget -q https://raw.githubusercontent.com/pspcps/Arcade/refs/heads/main/analyze-images-v3.py
echo "Script downloaded."
echo ""

# Replace locale in script
echo "Updating script locale..."
sed -i "s/'en'/'${LOCAL}'/g" analyze-images-v3.py
echo "Locale updated."
echo ""

# Create BigQuery dataset/table if not exists
echo "Ensuring BigQuery dataset and table exist..."
bq --location=US mk -d --description "Image classification data" "$DEVSHELL_PROJECT_ID:image_classification_dataset" 2>/dev/null
bq mk --table "$DEVSHELL_PROJECT_ID:image_classification_dataset.image_text_detail" \
  desc:STRING,locale:STRING,translated_text:STRING,filename:STRING 2>/dev/null
echo "Dataset and table ready."
echo ""

# Run the Python script
# echo "Running image analysis script..."
# python3 analyze-images-v2.py "$DEVSHELL_PROJECT_ID" "$DEVSHELL_PROJECT_ID"
# echo ""

echo "Running image analysis script..."
if python3 analyze-images-v3.py "$DEVSHELL_PROJECT_ID" "$DEVSHELL_PROJECT_ID"; then
    echo "Image analysis script completed successfully."
else
    echo "Warning: Image analysis script encountered an error but continuing..."
fi
echo ""

# Query results
echo "Querying BigQuery for locale distribution..."
bq query --use_legacy_sql=false \
  "SELECT locale, COUNT(locale) as lcount FROM image_classification_dataset.image_text_detail GROUP BY locale ORDER BY lcount DESC"
echo ""

echo "Lab completed successfully."

# ------------------------------------ End ------------------------------------

echo "Check All progress First Please if all completed than press n else y"


# Ask for confirmation before deleting and reloading data
read -p "Do you want to delete all existing data and reload from JSON? (y/n): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "Deleting all data from image_classification_dataset.image_text_detail..."
    bq query --use_legacy_sql=false --quiet --format=none \
      "DELETE FROM image_classification_dataset.image_text_detail WHERE TRUE"
    echo "Data deleted."

    echo "Downloading JSON data..."
    curl -s -o data.json https://raw.githubusercontent.com/sudhajobs0107/solutions/blob/main/Use%20Machine%20Learning%20APIs%20on%20Google%20Cloud%20Challenge%20Lab/TechSolutionsHub329.json

    echo "Converting JSON array to newline-delimited JSON..."
    jq -c '.[]' data.json > data_ndjson.json

    echo "Loading data into BigQuery..."
    bq load --source_format=NEWLINE_DELIMITED_JSON \
      --replace=false \
      "$DEVSHELL_PROJECT_ID:image_classification_dataset.image_text_detail" \
      data_ndjson.json \
      original_text:STRING,locale:STRING,translated_text:STRING,filename:STRING

    echo "Data reloaded from JSON successfully."

    # Optional: Remove temporary files
    rm data.json data_ndjson.json
else
    echo "Data reload cancelled by user."
fi

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
