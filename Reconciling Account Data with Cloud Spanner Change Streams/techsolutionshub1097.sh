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

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud config set compute/zone "$ZONE"

gcloud config set compute/region "$REGION"

gcloud spanner databases create finance \
  --instance=bitfoon-dev \
  --ddl="CREATE TABLE Account (
            AccountId BYTES(16) NOT NULL,
            CreationTimestamp TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
            AccountStatus INT64 NOT NULL,
            Balance NUMERIC NOT NULL
         ) PRIMARY KEY (AccountId);"


ACCOUNT_IDS=("ACCOUNTID11123" "ACCOUNTID12345" "ACCOUNTID24680" "ACCOUNTID135791")

for ID in "${ACCOUNT_IDS[@]}"; do
  echo "Inserting AccountId: $ID"
  ENCODED_ID=$(echo -n "$ID" | base64)
  gcloud spanner databases execute-sql finance \
    --instance=bitfoon-dev \
    --sql="INSERT INTO Account (AccountId, CreationTimestamp, AccountStatus, Balance) VALUES (FROM_BASE64('$ENCODED_ID'), PENDING_COMMIT_TIMESTAMP(), 1, 22);"
done


gcloud spanner databases ddl update finance \
  --instance=bitfoon-dev \
  --ddl="CREATE CHANGE STREAM AccountUpdateStream FOR Account(AccountStatus, Balance);"


bq --location="$REGION" mk --dataset "$PROJECT_ID:changestream"

echo
echo -e "\033[1;33mCreate a Dataflow\033[0m \033[1;34mhttps://console.cloud.google.com/dataflow/createjob?inv=1&invt=Ab2T9A&project=$DEVSHELL_PROJECT_ID\033[0m"
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


while true; do
  JOB_STATE=$(gcloud dataflow jobs list \
    --region="$REGION" \
    --filter="name=change-stream-pipeline" \
    --format="value(state)")

  if [[ "$JOB_STATE" == "Running" ]]; then
    echo "Dataflow job is running."
    break
  else
    echo -e "Waiting for job to start, Subscribe to TechSolutionsHub."
    sleep 10
  fi
done


ACCOUNT_ID="ACCOUNTID98765"
ENCODED_ID=$(echo -n "$ACCOUNT_ID" | base64)
gcloud spanner databases execute-sql finance \
  --instance=bitfoon-dev \
  --sql="INSERT INTO Account (
           AccountId,
           CreationTimestamp,
           AccountStatus,
           Balance
         ) VALUES (
           FROM_BASE64('$ENCODED_ID'),
           PENDING_COMMIT_TIMESTAMP(),
           1,
           22
         );"


TARGET_ID="ACCOUNTID11123"
ENCODED_TARGET=$(echo -n "$TARGET_ID" | base64)
BALANCES=(255 300 500 600)

for BALANCE in "${BALANCES[@]}"; do
  gcloud spanner databases execute-sql finance \
    --instance=bitfoon-dev \
    --sql="UPDATE Account
           SET CreationTimestamp = PENDING_COMMIT_TIMESTAMP(),
               AccountStatus = 4,
               Balance = $BALANCE
           WHERE AccountId = FROM_BASE64('$ENCODED_TARGET');"
  echo "Updated balance to $BALANCE"
  sleep 1
done

echo
echo -e "\033[1;33mGo to BigQuery\033[0m \033[1;34mhttps://console.cloud.google.com/bigquery?referrer=search&inv=1&invt=Ab2T9A&project==$DEVSHELL_PROJECT_ID&ws=!1m0\033[0m"
echo

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
