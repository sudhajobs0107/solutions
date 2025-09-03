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

gcloud config set compute/region "$ZONE"

echo "${BG_MAGENTA}${BOLD_TEXT}ZONE is:-${RESET_FORMAT} $ZONE"

# Check if firewall rule 'dev-ports' exists, create if not
if ! gcloud compute firewall-rules describe dev-ports &>/dev/null; then
  echo "🌐 Creating firewall rule 'dev-ports' to allow TCP:8443 from 0.0.0.0/0..."
  gcloud compute firewall-rules create dev-ports \
    --allow=tcp:8443 \
    --source-ranges=0.0.0.0/0 \
    --target-tags=http-server,https-server
else
  echo "🔒 Firewall rule 'dev-ports' already exists, skipping creation."
fi

# Check if VM already exists
if gcloud compute instances describe "$VM_NAME" --zone="$ZONE" &>/dev/null; then
  echo "⚠️ VM '$VM_NAME' already exists in zone '$ZONE'. Skipping VM creation."
else
  echo "🚀 Creating VM '$VM_NAME' in zone '$ZONE'..."
  gcloud compute instances create "$VM_NAME" \
    --zone="$ZONE" \
    --machine-type="$MACHINE_TYPE" \
    --image-family="$IMAGE_FAMILY" \
    --image-project="$IMAGE_PROJECT" \
    --boot-disk-type=pd-balanced \
    --boot-disk-size=10GB \
    --tags=http-server,https-server \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --metadata=enable-oslogin=TRUE \
    --no-shielded-secure-boot \
    --quiet
fi

# Wait for instance to be ready (skip if VM existed)
echo "⏳ Waiting for instance to be ready..."
sleep 15

# SSH install dependencies and clone repo (idempotent)
echo "🔧 Installing packages and cloning repo via SSH..."
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="
  sudo apt-get update -y && \
  sudo apt-get install -y git maven openjdk-11-jdk lsof && \
  if [ ! -d speaking-with-a-webpage ]; then
    git clone https://github.com/googlecodelabs/speaking-with-a-webpage.git
  else
    echo 'Repository already cloned, skipping git clone.'
  fi
"

# Extra wait for VM readiness
echo "⏳ Waiting 30 seconds for VM to initialize..."
sleep 30

# Get external IP
EXTERNAL_IP=$(gcloud compute instances describe "$VM_NAME" --zone="$ZONE" --format='get(networkInterfaces[0].accessConfigs[0].natIP)')
echo "🌍 External IP address: $EXTERNAL_IP"

echo "🚪 Connecting to VM via SSH to start Task 3 Jetty server..."

# Start Task 3 server
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="
  sudo update-alternatives --set java /usr/lib/jvm/java-11-openjdk-amd64/bin/java || true
  cd speaking-with-a-webpage/01-hello-https
  nohup mvn clean jetty:run > jetty.log 2>&1 &
"

echo "🟢 Jetty server for Task 3 started on VM."
echo ""
echo "👉 Open your browser and visit: https://$EXTERNAL_IP:8443"
echo "⚠️ Your browser will warn about the self-signed SSL certificate — this is expected."
echo ""
read -p "✅ After confirming the servlet is working and you've checked your progress in the lab, press Enter to continue to Task 4..."

# Stop Task 3 Jetty server
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="
  PID=\$(sudo lsof -ti tcp:8443)
  if [ -n \"\$PID\" ]; then
    sudo kill \$PID
    echo '✅ Task 3 Jetty server stopped.'
  else
    echo 'No Jetty server found on port 8443.'
  fi
"

# Start Task 4 server
gcloud compute ssh "$VM_NAME" --zone="$ZONE" --command="
  cd speaking-with-a-webpage/02-webaudio
  nohup mvn clean jetty:run > jetty.log 2>&1 &
  echo \$! > jetty.pid
"

echo ""
echo "🟢 Jetty server for Task 4 started on VM."
echo "👉 Open your browser and visit: https://$EXTERNAL_IP:8443"
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
