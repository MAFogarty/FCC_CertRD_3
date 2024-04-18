#! /bin/bash

PSQL="psql --username=freecodecamp -t --dbname=salon -c"

echo -e "\n~~~~~~~~~~~~ SALON ~~~~~~~~~~~~\n"

# get available services
SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
# display available services
echo "Welcome!" 

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo "Services we offer are:"
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]+$ ]]
    then 
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done
  echo "Which would you like to book?"
  RESERVE
}

RESERVE() {
  # Read input
  read SERVICE_ID_SELECTED

  # if input is not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "That is not a valid service number."
  else
    # Get from database
    SERVICE_TO_BOOK=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # If service does not exist: loop back to main with error
    if [[ -z $SERVICE_TO_BOOK ]]
    then
      # send to main menu
      MAIN_MENU "That is not a valid service number."
    else # If service does exist: move to collect customer details:
      #echo "VALID INPUT: $SERVICE_TO_BOOK"
      #EXIT "EXIT: VALID INPUT"

      # get customer info 
      echo -e "\nBooking phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      # if customer doesn't exist 
      if [[ -z $CUSTOMER_NAME ]]
      then
        # get new customer name 
        echo -e "\nBooking name?"
        read CUSTOMER_NAME
        # insert new customer
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      # read booking info (time)
      echo -e "\nBooking Time?"
      read SERVICE_TIME

      # get customer_id from database
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

      # insert service booking into database
      INSERT_SERVICE_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      EXIT "I have put you down for a $SERVICE_TO_BOOK at $SERVICE_TIME, $CUSTOMER_NAME."

    fi
  fi
} 

EXIT() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
}

MAIN_MENU
