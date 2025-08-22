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
export PROJECT_ID=$(gcloud config get-value project)
echo $PROJECT_ID

# Define colors and bold formatting using ANSI escape codes
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)
echo  "${BOLD}${RED}Task 1. Total confirmed cases${RESET}"

# Prompt user for the month and day input
echo -n "${BOLD}${GREEN_TEXT}Please enter the month (format: MM): ${RESET_FORMAT}"
read input_month

echo -n "${BOLD}${GREEN_TEXT}Please enter the date (format: DD): ${RESET_FORMAT}"
read input_day

# Fixed year
year="2020"

# Combine year, month, and day to form the full date
input_date="${year}-${input_month}-${input_day}"

# Run the query on BigQuery using the user-provided date
bq query --use_legacy_sql=false \
"SELECT sum(cumulative_confirmed) as total_cases_worldwide
 FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
 WHERE date='${input_date}'"



#TASK 2

echo  "${BOLD}${RED}Task 2. Worst affected areas${RESET}"


#!/bin/bash
# Define colors and bold formatting using ANSI escape codes
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Prompt user for the death count threshold
echo -n "${BOLD}${GREEN_TEXT}Please enter the death count threshold:${RESET}"
read death_threshold

# Fixed year
year="2020"

# Combine year, month, and day to form the full date
input_date="${year}-${input_month}-${input_day}"

# Run the query on BigQuery using the user-provided date and death threshold
bq query --use_legacy_sql=false \
"WITH deaths_by_states AS (
    SELECT subregion1_name as state, sum(cumulative_deceased) as death_count
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name='United States of America' 
      AND date='${input_date}' 
      AND subregion1_name IS NOT NULL
    GROUP BY subregion1_name
)
SELECT count(*) as count_of_states
FROM deaths_by_states
WHERE death_count > ${death_threshold}"


#TASK 3

echo  "${BOLD}${RED}Task 3. Identify hotspots${RESET}"


#!/bin/bash
# Define colors and bold formatting using ANSI escape codes
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Prompt user for the confirmed case threshold
echo -n "${BOLD}${GREEN_TEXT}Please enter the confirmed case threshold:${RESET}"
read case_threshold

# Fixed year
year="2020"

# Combine year, month, and day to form the full date
input_date="${year}-${input_month}-${input_day}"

# Run the query on BigQuery using the user-provided date and case threshold
bq query --use_legacy_sql=false \
"SELECT * FROM (
    SELECT subregion1_name as state, sum(cumulative_confirmed) as total_confirmed_cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_code='US' AND date='${input_date}' AND subregion1_name IS NOT NULL
    GROUP BY subregion1_name
    ORDER BY total_confirmed_cases DESC
)
WHERE total_confirmed_cases > ${case_threshold}"


#TASK 4

echo  "${BOLD}${RED}Task 4. Fatality ratio${RESET}"


#!/bin/bash

# Define colors and bold formatting using ANSI escape codes
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)


# Prompt user for the start date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN_TEXT}Please enter the start date (format: YYYY-MM-DD): ${RESET}"
read start_date

# Prompt user for the end date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN_TEXT}Please enter the end date (format: YYYY-MM-DD): ${RESET}"
read end_date

# Run the query on BigQuery using the user-provided country and date range
bq query --use_legacy_sql=false \
"SELECT sum(cumulative_confirmed) as total_confirmed_cases,
       sum(cumulative_deceased) as total_deaths,
       (sum(cumulative_deceased)/sum(cumulative_confirmed))*100 as case_fatality_ratio
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE country_name='Italy' AND date BETWEEN '${start_date}' AND '${end_date}'"


#TASK 5

echo  "${BOLD}${RED}Task 5. Identifying specific day${RESET}"


# Prompt user for the death threshold
echo -n "${BOLD}${GREEN}Please enter the death threshold: ${RESET}"
read death_threshold

# Run the query on BigQuery using the user-provided country and death threshold
bq query --use_legacy_sql=false \
"SELECT date
 FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
 WHERE country_name='Italy' AND cumulative_deceased > ${death_threshold}
 ORDER BY date ASC
 LIMIT 1"



#TASK 6

echo  "${BOLD}${RED}Task 6. Finding days with zero net new cases${RESET}"



# Prompt user for the start date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN}Please enter the start date (format: YYYY-MM-DD): ${RESET}"
read start_date

# Prompt user for the end date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN}Please enter the end date (format: YYYY-MM-DD): ${RESET}"
read end_date

# Run the query on BigQuery using the user-provided date range
bq query --use_legacy_sql=false \
"WITH india_cases_by_date AS (
    SELECT date, SUM(cumulative_confirmed) AS cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name ='India' AND date BETWEEN '${start_date}' AND '${end_date}'
    GROUP BY date
    ORDER BY date ASC
), india_previous_day_comparison AS (
    SELECT date, cases, LAG(cases) OVER(ORDER BY date) AS previous_day, cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases
    FROM india_cases_by_date
)
SELECT count(*)
FROM india_previous_day_comparison
WHERE net_new_cases = 0"


#TASK 7


echo  "${BOLD}${RED}Task 7. Doubling rate${RESET}"


# Prompt user for the percentage threshold
echo -n "${BOLD}${GREEN}Please enter the percentage increase threshold: ${RESET}"
read percentage_threshold

# Run the query on BigQuery using the user-provided date range and percentage threshold
bq query --use_legacy_sql=false \
"WITH us_cases_by_date AS (
    SELECT date, SUM(cumulative_confirmed) AS cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name='United States of America' AND date BETWEEN '2020-03-22' AND '2020-04-20'
    GROUP BY date
    ORDER BY date ASC
), us_previous_day_comparison AS (
    SELECT date, cases, LAG(cases) OVER(ORDER BY date) AS previous_day,
           cases - LAG(cases) OVER(ORDER BY date) AS net_new_cases,
           (cases - LAG(cases) OVER(ORDER BY date))*100/LAG(cases) OVER(ORDER BY date) AS percentage_increase
    FROM us_cases_by_date
)
SELECT Date, cases AS Confirmed_Cases_On_Day, previous_day AS Confirmed_Cases_Previous_Day, percentage_increase AS Percentage_Increase_In_Cases
FROM us_previous_day_comparison
WHERE percentage_increase > ${percentage_threshold}"



#TASK 8


echo  "${BOLD}${RED}Task 8. Recovery rate${RESET}"


#!/bin/bash

# Define colors and bold formatting using ANSI escape codes
BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RESET=$(tput sgr0)

# Prompt user for the limit value
echo -n "${BOLD}${GREEN}Please enter the limit : ${RESET}"
read limit

# Run the query on BigQuery using the user-provided limit
bq query --use_legacy_sql=false \
"WITH cases_by_country AS (

  SELECT

    country_name AS country,

    sum(cumulative_confirmed) AS cases,

    sum(cumulative_recovered) AS recovered_cases

  FROM

    bigquery-public-data.covid19_open_data.covid19_open_data

  WHERE

    date = '2020-05-10'

  GROUP BY

    country_name

 ), recovered_rate AS

(SELECT

  country, cases, recovered_cases,

  (recovered_cases * 100)/cases AS recovery_rate

FROM cases_by_country

)
SELECT country, cases AS confirmed_cases, recovered_cases, recovery_rate

FROM recovered_rate

WHERE cases > 50000

ORDER BY recovery_rate DESC

LIMIT ${limit}"


# TASK 9


echo  "${BOLD}${RED}Task 9. CDGR - Cumulative daily growth rate${RESET}"


# Prompt user for the second date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN}Please enter the second date (format: YYYY-MM-DD): ${RESET}"
read second_date

# Run the query on BigQuery using the user-provided second date
bq query --use_legacy_sql=false \
"WITH france_cases AS (
    SELECT date, SUM(cumulative_confirmed) AS total_cases
    FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
    WHERE country_name='France' AND date IN ('2020-01-24', '${second_date}')
    GROUP BY date
    ORDER BY date
), summary AS (
    SELECT total_cases AS first_day_cases, LEAD(total_cases) OVER(ORDER BY date) AS last_day_cases,
           DATE_DIFF(LEAD(date) OVER(ORDER BY date), date, day) AS days_diff
    FROM france_cases
    LIMIT 1
)
SELECT first_day_cases, last_day_cases, days_diff,
       POWER((last_day_cases/first_day_cases),(1/days_diff))-1 AS cdgr
FROM summary"


#TASK 10


echo  "${BOLD}${RED}Task 10. Create a Looker Studio report${RESET}"


# Prompt user for the start date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN}Please enter the start date (format: YYYY-MM-DD): ${RESET}"
read start_date

# Prompt user for the end date (YYYY-MM-DD)
echo -n "${BOLD}${GREEN}Please enter the end date (format: YYYY-MM-DD): ${RESET}"
read end_date

# Run the query on BigQuery using the user-provided date range
bq query --use_legacy_sql=false \
"SELECT date, SUM(cumulative_confirmed) AS country_cases,
       SUM(cumulative_deceased) AS country_deaths
FROM \`bigquery-public-data.covid19_open_data.covid19_open_data\`
WHERE date BETWEEN '${start_date}' AND '${end_date}'
  AND country_name='United States of America'
GROUP BY date
ORDER BY date"

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
