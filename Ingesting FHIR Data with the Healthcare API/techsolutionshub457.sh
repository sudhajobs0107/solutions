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
#!/bin/bash

# Fetch project
PROJECT_ID=$(gcloud config get-value project 2> /dev/null)
if [[ "$PROJECT_ID" == "(unset)" || -z "$PROJECT_ID" ]]; then
  PROJECT_ID=$(gcloud projects list --format="value(projectId)" --limit=1)
  gcloud config set project "$PROJECT_ID"
fi
export PROJECT_ID

PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format="value(projectNumber)")
export PROJECT_NUMBER

# Try region from gcloud config
export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

# Set in gcloud config
gcloud config set compute/region "$REGION"
export REGION

# Use REGION for LOCATION too
export LOCATION="$REGION"

# Other variables
export DATASET_ID=dataset1
export FHIR_STORE_ID=fhirstore1
export TOPIC=fhir-topic
export HL7_STORE_ID=hl7v2store1

# Print values
echo "${BG_MAGENTA}${BOLD_TEXT}Project ID =${RESET_FORMAT} $PROJECT_ID"
echo "${BG_MAGENTA}${BOLD_TEXT}PROJECT NUMBER =${RESET_FORMAT} $PROJECT_NUMBER"
echo "${BG_MAGENTA}${BOLD_TEXT}LOCATION =${RESET_FORMAT} $LOCATION"
echo "${BG_MAGENTA}${BOLD_TEXT}DATASET ID =${RESET_FORMAT} $DATASET_ID"
echo "${BG_MAGENTA}${BOLD_TEXT}FHIR STORE ID =${RESET_FORMAT} $FHIR_STORE_ID"
echo "${BG_MAGENTA}${BOLD_TEXT}HL7 STORE ID =${RESET_FORMAT} $HL7_STORE_ID"
echo "${BG_MAGENTA}${BOLD_TEXT}TOPIC =${RESET_FORMAT} $TOPIC"

gcloud services enable healthcare.googleapis.com


bq --location=$REGION mk --dataset --description HCAPI-dataset $PROJECT_ID:$DATASET_ID

bq --location=$REGION mk --dataset --description HCAPI-dataset-de-id $PROJECT_ID:de_id


gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com \
--role=roles/bigquery.dataEditor
gcloud projects add-iam-policy-binding $PROJECT_ID \
--member=serviceAccount:service-$PROJECT_NUMBER@gcp-sa-healthcare.iam.gserviceaccount.com \
--role=roles/bigquery.jobUser


gcloud healthcare datasets create $DATASET_ID \
--location=$LOCATION


gcloud pubsub topics create fhir-topic


gcloud healthcare fhir-stores create ${FHIR_STORE_ID} --project=$DEVSHELL_PROJECT_ID --dataset=${DATASET_ID} --location=${LOCATION} --version=R4 --pubsub-topic=projects/${PROJECT_ID}/topics/${TOPIC} --enable-update-create --disable-referential-integrity


gcloud healthcare fhir-stores create de_id --project=$DEVSHELL_PROJECT_ID --dataset=${DATASET_ID} --location=${LOCATION} --version=R4 --pubsub-topic=projects/${PROJECT_ID}/topics/${TOPIC} --enable-update-create --disable-referential-integrity


gcloud healthcare fhir-stores import gcs $FHIR_STORE_ID \
--dataset=$DATASET_ID \
--location=$LOCATION \
--gcs-uri=gs://spls/gsp457/fhir_devdays_gcp/fhir1/* \
--content-structure=BUNDLE_PRETTY


gcloud healthcare fhir-stores export bq $FHIR_STORE_ID \
--dataset=$DATASET_ID \
--location=$LOCATION \
--bq-dataset=bq://$PROJECT_ID.$DATASET_ID \
--schema-type=analytics

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

echo ""

echo "${BG_MAGENTA}${BOLD_TEXT}Open this link :-${RESET_FORMAT}https://console.cloud.google.com/healthcare/browser/locations/$REGION/datasets/dataset1/datastores?invt=AbuLrg&project=$DEVSHELL_PROJECT_ID"

echo ""


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
