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

bq mk ecommerce

echo "${GREEN}${BOLD}

Task 2 Completed

${RESET}"

bq query --use_legacy_sql=false "
SELECT
  SKU,
  name,
  sentimentScore,
  sentimentMagnitude
FROM
  \`data-to-insights.ecommerce.products\`
ORDER BY
  sentimentScore DESC
LIMIT 5
"

bq query --use_legacy_sql=false "
SELECT
  SKU,
  name,
  sentimentScore,
  sentimentMagnitude
FROM
  \`data-to-insights.ecommerce.products\`
WHERE sentimentScore IS NOT NULL
ORDER BY
  sentimentScore
LIMIT 5
"

echo "${GREEN}${BOLD}

Task 5 Completed

${RESET}"

# pull what sold on 08/01/2017
bq query --use_legacy_sql=false "
CREATE OR REPLACE TABLE ecommerce.sales_by_sku_20170801 AS
SELECT
  productSKU,
  SUM(IFNULL(productQuantity,0)) AS total_ordered
FROM
  \`data-to-insights.ecommerce.all_sessions_raw\`
WHERE date = '20170801'
GROUP BY productSKU
ORDER BY total_ordered DESC #462 skus sold
"


# join against product inventory to get name
bq query --use_legacy_sql=false "
SELECT DISTINCT
  website.productSKU,
  website.total_ordered,
  inventory.name,
  inventory.stockLevel,
  inventory.restockingLeadTime,
  inventory.sentimentScore,
  inventory.sentimentMagnitude
FROM
  ecommerce.sales_by_sku_20170801 AS website
  LEFT JOIN \`data-to-insights.ecommerce.products\` AS inventory
  ON website.productSKU = inventory.SKU
ORDER BY total_ordered DESC
"

# calculate ratio and filter
bq query --use_legacy_sql=false "
SELECT DISTINCT
  website.productSKU,
  website.total_ordered,
  inventory.name,
  inventory.stockLevel,
  inventory.restockingLeadTime,
  inventory.sentimentScore,
  inventory.sentimentMagnitude,
  SAFE_DIVIDE(website.total_ordered, inventory.stockLevel) AS ratio
FROM
  ecommerce.sales_by_sku_20170801 AS website
  LEFT JOIN \`data-to-insights.ecommerce.products\` AS inventory
  ON website.productSKU = inventory.SKU
# gone through more than 50% of inventory for the month
WHERE SAFE_DIVIDE(website.total_ordered,inventory.stockLevel) >= .50
ORDER BY total_ordered DESC
"

echo "${GREEN}${BOLD}

Task 6 Completed

${RESET}"


bq query --use_legacy_sql=false "
CREATE OR REPLACE TABLE ecommerce.sales_by_sku_20170802
(
productSKU STRING,
total_ordered INT64
);
"

bq query --use_legacy_sql=false "
INSERT INTO ecommerce.sales_by_sku_20170802
(productSKU, total_ordered)
VALUES('GGOEGHPA002910', 101)
"

bq query --use_legacy_sql=false "
SELECT * FROM ecommerce.sales_by_sku_20170801
UNION ALL
SELECT * FROM ecommerce.sales_by_sku_20170802
"

bq query --use_legacy_sql=false "
SELECT * FROM \`ecommerce.sales_by_sku_2017*\`
"

bq query --use_legacy_sql=false "
SELECT * FROM \`ecommerce.sales_by_sku_2017*\`
WHERE _TABLE_SUFFIX = '0802'
"

echo "${GREEN}${BOLD}

Task 7 Completed

${RESET}"

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
