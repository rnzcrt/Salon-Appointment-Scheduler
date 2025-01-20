#! /bin/bash

# Connect to PostgreSQL and set up the database and tables
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo -e "Welcome to the salon! Here are the services we offer:\n"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Display services
display_services

# Prompt for service selection
while true; do
  echo -e "\nPlease enter the service_id for the service you want:"
  read SERVICE_ID_SELECTED

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid service ID. Please choose from the list again.\n"
    display_services
  else
    break
  fi
done

# Prompt for phone number
echo -e "\nPlease enter your phone number:"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nYou are not in our database. Please enter your name:"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');"
fi

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

# Prompt for time
echo -e "\nPlease enter the time for your appointment:"
read SERVICE_TIME

# Insert appointment
$PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Output confirmation message
SERVICE_NAME=$(echo $SERVICE_NAME | xargs)
CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
