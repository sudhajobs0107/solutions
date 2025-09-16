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
echo "${BG_MAGENTA}${BOLD_TEXT}🧩Project ID is:-${RESET_FORMAT} $PROJECT_ID"

gcloud auth list

LOCATION="${1:-us}"  # Default to "us" if not passed as argument
DISPLAY_NAME="lab-invoice-parser"
PROCESSOR_TYPE="INVOICE_PROCESSOR"

# 1️⃣ Enable Document AI API (if not already enabled)
echo "1⃣ Enabling Document AI API..."
gcloud services enable documentai.googleapis.com


pip3 install --upgrade pandas

pip3 install --upgrade google-cloud-documentai


echo "📄 Please Follow Video For Creating PROCESSOR"

# Prompt user to input three regions
read -p "${BG_MAGENTA}${BOLD_TEXT}Enter INVOICE_PARSER_ID:-${RESET_FORMAT} " INVOICE_PARSER_ID


# # 3️⃣ Create Processor
# echo "3⃣ Creating Processor..."
# cat <<EOF > create_proc.json
# {
#   "type": "${PROCESSOR_TYPE}",
#   "displayName": "${DISPLAY_NAME}"
# }
# EOF

# PROC_RESPONSE=$(curl -s -X POST \
#   -H "Authorization: Bearer $(gcloud auth print-access-token)" \
#   -H "Content-Type: application/json" \
#   -d @create_proc.json \
#   "https://${LOCATION}-documentai.googleapis.com/v1/projects/${PROJECT_ID}/locations/${LOCATION}/processors")

# PROCESSOR_NAME=$(echo "$PROC_RESPONSE" | grep -o '"name"[ ]*:[ ]*"[^"]*' | cut -d'"' -f4)
# INVOICE_PARSER_ID=$(basename "$PROCESSOR_NAME")

# echo "✅ Processor Created: $INVOICE_PARSER_ID"

# # 3️⃣ Output Results
# echo ""
# echo "✅ Invoice Parser Processor Created!"
# echo "🔗 View in Console:"
# echo "   https://console.cloud.google.com/document-ai/location/${LOCATION}/processors/${INVOICE_PARSER_ID}?project=${PROJECT_ID}"
# echo ""
# echo "📌 Processor ID: $INVOICE_PARSER_ID"

# Optional: export for current shell session
# export INVOICE_PARSER_ID

# echo ""
# echo "✅ Variable INVOICE_PARSER_ID is set."
# echo "=============================="



gcloud storage cp gs://cloud-samples-data/documentai/codelabs/specialized-processors/procurement_multi_document.pdf .

gcloud storage cp gs://cloud-samples-data/documentai/codelabs/specialized-processors/google_invoice.pdf .

cat > extraction.py <<EOF_END
import pandas as pd
from google.cloud import documentai_v1 as documentai


def online_process(
    project_id: str,
    location: str,
    processor_id: str,
    file_path: str,
    mime_type: str,
) -> documentai.Document:
    """
    Processes a document using the Document AI Online Processing API.
    """

    opts = {"api_endpoint": f"{location}-documentai.googleapis.com"}

    # Instantiates a client
    documentai_client = documentai.DocumentProcessorServiceClient(client_options=opts)

    # The full resource name of the processor, e.g.:
    # projects/project-id/locations/location/processor/processor-id
    # You must create new processors in the Cloud Console first
    resource_name = documentai_client.processor_path(project_id, location, processor_id)

    # Read the file into memory
    with open(file_path, "rb") as file:
        file_content = file.read()

    # Load Binary Data into Document AI RawDocument Object
    raw_document = documentai.RawDocument(content=file_content, mime_type=mime_type)

    # Configure the process request
    request = documentai.ProcessRequest(name=resource_name, raw_document=raw_document)

    # Use the Document AI client to process the sample form
    result = documentai_client.process_document(request=request)

    return result.document


PROJECT_ID = "$DEVSHELL_PROJECT_ID"
LOCATION = "us"  # Format is 'us' or 'eu'
PROCESSOR_ID = "$INVOICE_PARSER_ID"  # Create processor in Cloud Console

# The local file in your current working directory
FILE_PATH = "google_invoice.pdf"
# Refer to https://cloud.google.com/document-ai/docs/processors-list
# for supported file types
MIME_TYPE = "application/pdf"

document = online_process(
    project_id=PROJECT_ID,
    location=LOCATION,
    processor_id=PROCESSOR_ID,
    file_path=FILE_PATH,
    mime_type=MIME_TYPE,
)

types = []
raw_values = []
normalized_values = []
confidence = []

# Grab each key/value pair and their corresponding confidence scores.
for entity in document.entities:
    types.append(entity.type_)
    raw_values.append(entity.mention_text)
    normalized_values.append(entity.normalized_value.text)
    confidence.append(f"{entity.confidence:.0%}")

    # Get Properties (Sub-Entities) with confidence scores
    for prop in entity.properties:
        types.append(prop.type_)
        raw_values.append(prop.mention_text)
        normalized_values.append(prop.normalized_value.text)
        confidence.append(f"{prop.confidence:.0%}")

# Create a Pandas Dataframe to print the values in tabular format.
df = pd.DataFrame(
    {
        "Type": types,
        "Raw Value": raw_values,
        "Normalized Value": normalized_values,
        "Confidence": confidence,
    }
)

print(df)
EOF_END

python3 extraction.py

# Create a bucket
export PROJECT_ID=$(gcloud config get-value project)
gsutil mb gs://$PROJECT_ID-docai

# Create and upload the file
python3 extraction.py > docai_outputs.txt
gsutil cp docai_outputs.txt gs://$PROJECT_ID-docai



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
