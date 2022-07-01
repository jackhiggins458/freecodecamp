#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Wipe tables
echo $($PSQL "TRUNCATE TABLE games, teams")

cat games.csv | while IFS="," read YEAR ROUND WIN OPP W_GOALS O_GOALS
do
if [[ $YEAR != year ]]
then
  # Insert teams into database
  # ON CONFLICT (field) DO NOTHING is used to avoid duplicate key errors,
  # see https://www.postgresql.org/docs/current/sql-insert.html  
  # and https://stackoverflow.com/a/40313843.
  INSERT_WIN_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WIN') ON CONFLICT (name) DO NOTHING")
  INSERT_OPP_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPP') ON CONFLICT (name) DO NOTHING")
  
  # Print teams as they are inserted
  : '
  if [[ $INSERT_WIN_RESULT == "INSERT 0 1" ]]
  then
    echo Inserted into teams, $WIN
  elif [[ $INSERT_OPP_RESULT == "INSERT 0 1" ]]
  then
    echo Inserted into teams, $OPP
  fi
  '

  # Get winner and opponent IDs
  WIN_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WIN'")
  OPP_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPP'")

  # Insert game results
  INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WIN_ID, $OPP_ID, $W_GOALS, $O_GOALS)")
fi
done
