#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to Sally's Satirical Salon! ~~~~~\n"

# Get list of available services
RESULT_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
# Get the maximum service ID (used to validate user requests and offered service)
MAX_SERVICE_ID=$($PSQL "SELECT MAX(service_id) FROM services")

echo -e "What service would you like to book today? Please enter the service id.\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  # Print the service menu
  echo "$RESULT_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  
  GET_SERVICES
}

GET_SERVICES() {
  read SERVICE_ID_SELECTED

  SERVICE_ID_RESULT=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")


  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "That is not a valid service number.\nPlease enter a number from the list of services provided.\n"
  elif (( SERVICE_ID_SELECTED > MAX_SERVICE_ID ))
  then
    MAIN_MENU "There is no service provided with that number.\nPlease enter a number from the list of services provided.\n" 
  fi
  

  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services 
  WHERE service_id = '$SERVICE_ID_SELECTED'")
  SERVICE_NAME_SELECTED_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/^ *| *$//g')

  echo -e "\nSure, we can book in a $SERVICE_NAME_SELECTED_FORMATTED for you.
  \nPlease enter your phone number."
  read CUSTOMER_PHONE
  while [[ -z $CUSTOMER_PHONE ]]
  do 
    echo "You didn't enter anything. Please enter your phone number."
    read CUSTOMER_PHONE
  done
  
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]] 
  then
    echo -e "\nOh, it looks like we don't have your details in our system. \nWhat's your name?"
    read CUSTOMER_NAME
    
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    echo -e "\nThanks $CUSTOMER_NAME_FORMATTED, we've popped your name and number $CUSTOMER_PHONE into our system."
  fi

  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//g')
  
  MAKE_APP
}

MAKE_APP() {
  echo -e "\nAnd what time would you like to book in for, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  SERVICE_BOOKING_RESULT=$($PSQL "INSERT INTO 
  appointments(customer_id, service_id, time) 
  VALUES($CUSTOMER_ID, '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

  echo -e "I have put you down for a $SERVICE_NAME_SELECTED_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  
  # Exit the program (otherwise it jumps back to after the last main menu call when bad input is given)
  exit 0 
}

MAIN_MENU
