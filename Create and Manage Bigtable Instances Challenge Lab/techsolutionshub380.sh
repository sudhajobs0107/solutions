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

export ZONE=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-zone])")

export REGION=$(gcloud compute project-info describe --format="value(commonInstanceMetadata.items[google-compute-default-region])")

gcloud services disable dataflow.googleapis.com --project $DEVSHELL_PROJECT_ID

gcloud config set compute/zone "$ZONE"

gcloud config set compute/region "$REGION"

gcloud services enable dataflow.googleapis.com --project $DEVSHELL_PROJECT_ID

echo
echo -e "\033[1;33mCreate Bigtable instance\033[0m \033[1;34mhttps://console.cloud.google.com/bigtable/create-instance?inv=1&invt=AbzGZg&project=$DEVSHELL_PROJECT_ID\033[0m"
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

gsutil mb gs://$PROJECT_ID

gcloud bigtable instances tables create SessionHistory --instance=ecommerce-recommendations --project=$PROJECT_ID --column-families=Engagements,Sales

sleep 20

#!/bin/bash

while true; do
    gcloud dataflow jobs run import-sessions --region=$REGION --project=$PROJECT_ID --gcs-location gs://dataflow-templates-$REGION/latest/GCS_SequenceFile_to_Cloud_Bigtable --staging-location gs://$PROJECT_ID/temp --parameters bigtableProject=$PROJECT_ID,bigtableInstanceId=ecommerce-recommendations,bigtableTableId=SessionHistory,sourcePattern=gs://cloud-training/OCBL377/retail-engagements-sales-00000-of-00001,mutationThrottleLatencyMs=0

    if [ $? -eq 0 ]; then
        echo -e "\033[1;33mJob has completed successfully. now just wait for succeeded"
        break
    else
        echo -e "\033[1;33mJob retrying."
        sleep 10
    fi
done


gcloud bigtable instances tables create PersonalizedProducts --project=$PROJECT_ID --instance=ecommerce-recommendations --column-families=Recommendations

sleep 20

#!/bin/bash

while true; do
    gcloud dataflow jobs run import-recommendations --region=$REGION --project=$PROJECT_ID --gcs-location gs://dataflow-templates-$REGION/latest/GCS_SequenceFile_to_Cloud_Bigtable --staging-location gs://$PROJECT_ID/temp --parameters bigtableProject=$PROJECT_ID,bigtableInstanceId=ecommerce-recommendations,bigtableTableId=PersonalizedProducts,sourcePattern=gs://cloud-training/OCBL377/retail-recommendations-00000-of-00001,mutationThrottleLatencyMs=0

    if [ $? -eq 0 ]; then
        echo -e "\033[1;33mJob has completed successfully."
        break
    else
        echo -e "\033[1;33mJob retrying."
        sleep 10
    fi
done


gcloud beta bigtable backups create PersonalizedProducts_7 --instance=ecommerce-recommendations --cluster=ecommerce-recommendations-c1 --table=PersonalizedProducts --retention-period=7d 


gcloud beta bigtable instances tables restore --source=projects/$PROJECT_ID/instances/ecommerce-recommendations/clusters/ecommerce-recommendations-c1/backups/PersonalizedProducts_7 --async --destination=PersonalizedProducts_7_restored --destination-instance=ecommerce-recommendations --project=$PROJECT_ID

echo
echo -e "\033[1;33mCheck job status\033[0m \033[1;34mhttps://console.cloud.google.com/dataflow/jobs?referrer=search&inv=1&invt=AbzGZg&project=$DEVSHELL_PROJECT_ID\033[0m"
echo


echo
echo -e "\033[1;33mCheck job status\033[0m \033[1;34mhttps://console.cloud.google.com/dataflow/jobs?referrer=search&inv=1&invt=AbzGZg&project=$DEVSHELL_PROJECT_ID\033[0m"
echo

while true; do
    echo -ne "\e[1;93mDo you Want to proceed For Deleting Tables. Make sure you check all progess till delete step? (Y/n): \e[0m"
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


gcloud bigtable instances tables delete PersonalizedProducts --instance=ecommerce-recommendations --quiet

gcloud bigtable instances tables delete PersonalizedProducts_7_restored --instance=ecommerce-recommendations --quiet

gcloud bigtable instances tables delete SessionHistory --instance=ecommerce-recommendations --quiet

gcloud bigtable backups delete PersonalizedProducts_7 \
  --instance=ecommerce-recommendations \
  --cluster=ecommerce-recommendations-c1 --quiet

gcloud bigtable instances delete ecommerce-recommendations --quiet


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
