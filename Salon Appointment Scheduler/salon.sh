#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

#Salon Appointment Scheduler
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "Welcome to My Salon, how can I help you?\n"
  fi

  SELECTION_MENU

}

SELECTION_MENU() {
  #get all services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")

  #display all services
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  #get selected service
  read SERVICE_ID_SELECTED

  case $SERVICE_ID_SELECTED in
    1 | 2 | 3 | 4 | 5) MAKE_APPOINTMENT $SERVICE_ID_SELECTED ;;
    *) MAIN_MENU "I could not find that service. What would you like today?" ;;
  esac

}

MAKE_APPOINTMENT() {

  SERVICE_ID=$1
  #get service
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID;")

  #get customer info
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  #check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")

  #if customer does not exist
  if [[ -z $CUSTOMER_NAME ]]
  then
    #get new customer name
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
  fi

  #get appointment time
  echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
  read SERVICE_TIME

  #get customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  #insert appointment
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME');")

  #display appointment
  echo -e "\nI have put you down for a$SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."

  #Exit
  EXIT
}


EXIT() {
  echo -e "\nThank you for stopping in.\n"
}


MAIN_MENU