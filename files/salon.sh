#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
echo -e "\nWelcome to My Salon, how can I help you?\n"
while :
do
  SERVICES_LIST
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
  else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
        echo -e "\nI could not find that service. What would you like today?"
    else
       break
    fi
  fi
done
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_RETURN=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_RETURN ]]
    then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        if [[ -z $CUSTOMER_NAME ]]
        then
            echo -e "\nCustomer name is empty"
        else
            INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
            CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        fi
    else
        IFS='|' read CUSTOMER_ID CUSTOMER_NAME <<< $CUSTOMER_RETURN
    fi
    if [[ -z $CUSTOMER_ID ]]
    then
        echo -e "\nCant get customer ID?"
    else
        echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
        read SERVICE_TIME
        if [[ -n $SERVICE_TIME ]]
        then
          #echo -e "\nTime valid: '$SERVICE_TIME'"
          INSERT_APP_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ -z $INSERT_APP_RESULT ]]
          then
              echo -e "\nError registering appointment"
          else
              SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//')
              echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME."
          fi
        else
          echo -e "\nInvalid Time: '$SERVICE_TIME'"
        fi
    fi        
}

SERVICES_LIST() {
  # get available services
  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  # no services available
  if [[ -n $AVAILABLE_SERVICES ]]
  then
    # display available services
    echo "$AVAILABLE_SERVICES" | while IFS='|' read SERVICE_ID NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  fi
}

MAIN_MENU
