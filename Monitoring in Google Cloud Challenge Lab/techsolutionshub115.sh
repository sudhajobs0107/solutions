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

# Section 1: Retrieve Zone and Instance ID
echo "${BOLD}Retrieving instance zone...${RESET}"
ZONE=$(gcloud compute instances list --project="$DEVSHELL_PROJECT_ID" --format='value(ZONE)' | head -n 1)
echo "Zone: $ZONE"

echo "${BOLD}Fetching instance ID for 'apache-vm'...${RESET}"
INSTANCE_ID=$(gcloud compute instances describe apache-vm --zone="$ZONE" --format='value(id)')
echo "Instance ID: $INSTANCE_ID"
echo

# Section 2: Monitoring Agent Installation Script
echo "${BOLD}Preparing agent installation script...${RESET}"
cat > cp_disk.sh <<'EOF'
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh --also-install

curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh --also-install

(cd /etc/stackdriver/collectd.d/ && sudo curl -O https://raw.githubusercontent.com/Stackdriver/stackdriver-agent-service-configs/master/etc/collectd.d/apache.conf)

sudo service stackdriver-agent restart
EOF

echo "Transferring script to apache-vm..."
gcloud compute scp cp_disk.sh apache-vm:/tmp --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --quiet

echo "Executing script on apache-vm..."
gcloud compute ssh apache-vm --project="$DEVSHELL_PROJECT_ID" --zone="$ZONE" --quiet --command="bash /tmp/cp_disk.sh"
echo

# Section 3: Uptime Check
echo "${BOLD}Creating uptime check...${RESET}"
gcloud monitoring uptime create apache-check \
  --resource-type="gce-instance" \
  --resource-labels=project_id="$DEVSHELL_PROJECT_ID",instance_id="$INSTANCE_ID",zone="$ZONE"
echo

# Section 4: Notification Channel
echo "${BOLD}Creating email notification channel...${RESET}"
read -p "${BG_MAGENTA}${BOLD_TEXT}Enter your email address for notifications:-${RESET_FORMAT} " USER_EMAIL

cat > email-channel.json <<EOF
{
  "type": "email",
  "displayName": "apache-alerts",
  "description": "Email alerts for apache-vm",
  "labels": {
    "email_address": "$USER_EMAIL"
  }
}
EOF

gcloud beta monitoring channels create --channel-content-from-file="email-channel.json"
echo

# Section 5: Alert Policy
echo "${BOLD}Creating alert policy...${RESET}"
CHANNEL_ID=$(gcloud beta monitoring channels list --format="value(name)" | head -n 1)

cat > alert-policy.json <<EOF
{
  "displayName": "High Apache Traffic Alert",
  "conditions": [
    {
      "displayName": "Apache Traffic Threshold",
      "conditionThreshold": {
        "filter": "resource.type=\"gce_instance\" AND metric.type=\"agent.googleapis.com/apache/traffic\"",
        "aggregations": [
          {
            "alignmentPeriod": "60s",
            "crossSeriesReducer": "REDUCE_NONE",
            "perSeriesAligner": "ALIGN_RATE"
          }
        ],
        "comparison": "COMPARISON_GT",
        "duration": "300s",
        "trigger": {
          "count": 1
        },
        "thresholdValue": 3072
      }
    }
  ],
  "alertStrategy": {
    "autoClose": "1800s"
  },
  "combiner": "OR",
  "enabled": true,
  "notificationChannels": [
    "$CHANNEL_ID"
  ]
}
EOF

gcloud alpha monitoring policies create --policy-from-file="alert-policy.json"
echo

# Section 6: Dashboard Links
echo "${BOLD}Useful Links:${RESET}"
echo "Monitoring Dashboards: https://console.cloud.google.com/monitoring/dashboards?project=$DEVSHELL_PROJECT_ID"
echo "Custom Metrics Editor: https://console.cloud.google.com/logs/metrics/edit?project=$DEVSHELL_PROJECT_ID"
echo
echo
echo
echo



echo "*****************************************Copy- For Step 5 **********************************"
echo
echo
echo 
echo -e "resource.type=\"gce_instance\"\nlogName=\"projects/${DEVSHELL_PROJECT_ID}/logs/apache-access\"\ntextPayload:\"200\""
echo
echo
echo "***************************************** **********************************"


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
