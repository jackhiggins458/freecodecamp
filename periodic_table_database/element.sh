#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"

# Determine what type of argument has been passed in
if [[ -z $1 ]]
then
  echo -e "Please provide an element as an argument."
  exit 0
elif [[ $1 =~ ^[0-9]{1,3}$ ]]
then
  # Argument is an atomic number
  CONDITION="atomic_number"

elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
  # Argument is an atomic symbol
  CONDITION="symbol"
else
  # Argument may be an atomic name
  CONDITION="name"
fi

# Get atomic number of element (if it is present)
ATOM_NUM=$($PSQL "SELECT atomic_number FROM elements WHERE $CONDITION = '$1'")

# End program if element details not found
if [[ -z $ATOM_NUM ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Get element data
ELEM_IDS=$($PSQL "SELECT atomic_number, symbol, name FROM elements 
WHERE atomic_number = '$ATOM_NUM'")
ELEM_PROPS=$($PSQL "SELECT * FROM properties 
WHERE atomic_number = '$ATOM_NUM'")

# Read into variables
IFS=" | " read -r ATOM_NUM ATOM_SYM NAME <<< $ELEM_IDS
IFS=" | " read -r ATOM_NUM ATOM_MASS MP BP TYPE_ID <<< $ELEM_PROPS

# Get element type
ELEM_TYPE=$($PSQL "SELECT type FROM properties 
INNER JOIN types USING(type_id) 
WHERE atomic_number = $ATOM_NUM")
ELEM_TYPE=$(echo $ELEM_TYPE | sed 's/^ *| *$//g')

# Display output
echo "The element with atomic number $ATOM_NUM is $NAME ($ATOM_SYM). It's a $ELEM_TYPE, with a mass of $ATOM_MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
