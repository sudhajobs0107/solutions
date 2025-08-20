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
read -p "Enter your PROCESSOR_ID: " PROCESSOR_ID
read -p "Enter your LOCATION: " LOCATION
export PROCESSOR_ID LOCATION
gcloud auth list
export GOOGLE_CLOUD_PROJECT=$(gcloud config get-value core/project)

gcloud iam service-accounts create my-docai-sa \
  --display-name "my-docai-service-account"

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/documentai.admin"

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding ${GOOGLE_CLOUD_PROJECT} \
    --member="serviceAccount:my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com" \
    --role="roles/serviceusage.serviceUsageConsumer"

sleep 15

gcloud iam service-accounts keys create ~/key.json \
  --iam-account  my-docai-sa@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com

export GOOGLE_APPLICATION_CREDENTIALS=$(realpath key.json)

pip3 install --upgrade google-cloud-documentai
pip3 install --upgrade google-cloud-storage

sleep 15

gcloud storage cp gs://cloud-samples-data/documentai/codelabs/ocr/Winnie_the_Pooh_3_Pages.pdf .

sleep 20

cat > online_processing.py <<EOF_CP
# ... (unchanged Python code)
EOF_CP

python3 online_processing.py

gcloud storage buckets create gs://$GOOGLE_CLOUD_PROJECT
gcloud storage cp gs://cloud-samples-data/documentai/codelabs/ocr/Winnie_the_Pooh.pdf gs://$GOOGLE_CLOUD_PROJECT/

sleep 20

cat > batch_processing.py <<EOF_CP
# ... (unchanged Python code)
EOF_CP

python3 batch_processing.py

sleep 20

gcloud storage cp --recursive gs://cloud-samples-data/documentai/codelabs/ocr/multi-document gs://$GOOGLE_CLOUD_PROJECT/

cat > batch_processing_directory.py <<EOF_CP
# ... (unchanged Python code)
EOF_CP

python3 batch_processing_directory.py

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

