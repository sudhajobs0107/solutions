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

# Print the welcome message
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}         INITIATING EXECUTION...  ${RESET_FORMAT}"
echo "${BLUE_TEXT}${BOLD_TEXT}=======================================${RESET_FORMAT}"

# Fetch region
REGION=$(gcloud compute project-info describe \
  --format="value(commonInstanceMetadata.items[google-compute-default-region])")
PROJECT_ID=$(gcloud config get-value project)



gcloud config set project $PROJECT_ID

gcloud config set compute/region $REGION


gcloud services enable secretmanager.googleapis.com run.googleapis.com artifactregistry.googleapis.com
gcloud secrets create arcade-secret --replication-policy=automatic
echo -n "t0ps3cr3t!" | gcloud secrets versions add arcade-secret --data-file=-

cat > app.py <<EOF_END
import os
from flask import Flask, jsonify, request
from google.cloud import secretmanager
import logging

app = Flask(__name__)

# Configure logging
logging.basicConfig(level=logging.INFO)

# Initialize Secret Manager client
# The client will automatically use the service account credentials of the Cloud Run service
secret_manager_client = secretmanager.SecretManagerServiceClient()

# Hardcoded Project ID and Secret ID as per your request
PROJECT_ID = "$PROJECT_ID" # Project ID
SECRET_ID = "arcade-secret"   # Secret Identifier

@app.route('/')
def get_secret():
    """
    Retrieves the specified secret from Secret Manager and returns its payload.
    The SECRET_ID and $PROJECT_ID are now hardcoded in the application.
    """
    if not SECRET_ID or not PROJECT_ID:
        logging.error("SECRET_ID or $PROJECT_ID not configured (should be hardcoded).")
        return jsonify({"error": "Secret ID or $Project ID not configured."}), 500

    secret_version_name = f"projects/{$PROJECT_ID}/secrets/{SECRET_ID}/versions/latest"

    try:
        logging.info(f"Accessing secret: {secret_version_name}")
        # Access the secret version
        response = secret_manager_client.access_secret_version(request={"name": secret_version_name})
        secret_payload = response.payload.data.decode("UTF-8")

        # IMPORTANT: In a real application, you would process or use the secret
        # here, not return it directly in an HTTP response, especially if the
        # secret is sensitive. This example is for demonstration purposes only.
        return jsonify({"secret_id": SECRET_ID, "secret_value": secret_payload})

    except Exception as e:
        logging.error(f"Failed to retrieve secret '{SECRET_ID}': {e}")
        return jsonify({"error": f"Failed to retrieve secret: {str(e)}"}), 500

if __name__ == '__main__':
    # When running locally, Flask will use the hardcoded values directly.
    # In Cloud Run, these values are used without needing environment variables.
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
EOF_END



cat > requirements.txt <<EOF_END
Flask==3.*
google-cloud-secret-manager==2.*
EOF_END



cat > Dockerfile <<EOF_END
FROM python:3.9-slim-buster

WORKDIR /app

COPY requirements.txt .
RUN pip3 install -r requirements.txt

COPY . .

CMD ["python3", "app.py"]
EOF_END

gcloud artifacts repositories create arcade-images --repository-format=docker --location=$REGION --description="Docker repository"
docker build -t $REGION-docker.pkg.dev/$PROJECT_ID/arcade-images/arcade-secret:latest .

docker run --rm -p 8080:8080 $REGION-docker.pkg.dev/$PROJECT_ID/arcade-images/arcade-secret:latest

sleep 20

docker push $REGION-docker.pkg.dev/$PROJECT_ID/arcade-images/arcade-secret:latest

gcloud iam service-accounts create arcade-service \
  --display-name="Arcade Service Account" \
  --description="Service account for Cloud Run application"
  
gcloud secrets add-iam-policy-binding arcade-secret \
--member="serviceAccount:arcade-service@$PROJECT_ID.iam.gserviceaccount.com" \
--role="roles/secretmanager.secretAccessor"

gcloud run deploy arcade-service \
  --image=$REGION-docker.pkg.dev/$PROJECT_ID/arcade-images/arcade-secret:latest \
  --region=$REGION \
  --set-secrets SECRET_ENV_VAR=arcade-secret:latest \
  --service-account arcade-service@$PROJECT_ID.iam.gserviceaccount.com \
  --allow-unauthenticated

gcloud run services describe arcade-service --region=$REGION --format='value(status.url)'

curl $(gcloud run services describe arcade-service --region=$REGION --format='value(status.url)') | jq


# Completion Message
echo
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}              LAB COMPLETED SUCCESSFULLY!              ${RESET_FORMAT}"
echo "${GREEN_TEXT}${BOLD_TEXT}=======================================================${RESET_FORMAT}"
echo ""
echo -e "${RED_TEXT}${BOLD_TEXT}Subscribe my Channel (TechLootHub):${RESET_FORMAT} ${BLUE_TEXT}${BOLD_TEXT}https://www.youtube.com/@techloothub${RESET_FORMAT}"


