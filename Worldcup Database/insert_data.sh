#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
#Insert data to teams table
while IFS=, read year round winner opponent winner_goals opponent_goals
do
  #Check if winner is in database
  WINNER_IN_DB=$($PSQL "SELECT EXISTS(SELECT true FROM teams WHERE name='$winner');")

  #Check if opponent is in database
  OPPONENT_IN_DB=$($PSQL "SELECT EXISTS(SELECT true FROM teams WHERE name='$opponent');")

  #If winner not in database, Insert team to database
  if [ $WINNER_IN_DB = f ];
  then
    echo $($PSQL "INSERT INTO teams(name) VALUES('$winner');")

  #If opponent not in database, Insert team to database
  elif [ $OPPONENT_IN_DB = f ];
  then
    echo $($PSQL "INSERT INTO teams(name) VALUES('$opponent');")
  fi

done < <(tail -n +2 games.csv)

#Insert data to games table
while IFS=, read year round winner opponent winner_goals opponent_goals
do
  #Get winner_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner';")

  #Get opponent_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent';")

  #Insert data all info to games table
  echo $($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals);")

done < <(tail -n +2 games.csv)