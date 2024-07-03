#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username: "
read NAME
USERNAME=$($PSQL "SELECT username FROM users WHERE username='$NAME'")

# if username not found in db, then add it to db
if [[ -z $USERNAME ]]
then
  INSERT_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$NAME')")
  echo -e "\nWelcome, $NAME! It looks like this is your first time here."
else
  DETAILS=$($PSQL "SELECT * FROM users WHERE username='$NAME'")
  echo $DETAILS | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

COUNT=0
SECRET_NUMBER=$(($RANDOM%1000))
echo "SECRET=$SECRET_NUMBER"

GUESS(){
  COUNT=$(($COUNT+1))
  echo -e "\n$1"
  read NUM

  # if input is a number
  if [[ $NUM =~ ^[0-9]+$ ]]
  then
    if (( $NUM == $SECRET_NUMBER ))
    then
      DETAILS=$($PSQL "SELECT * FROM users WHERE username='$NAME'")
      echo $DETAILS | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
      do
        UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played=$(($GAMES_PLAYED+1)) WHERE username='$NAME'")

        # if current guesses is less than db guesses
        if [[ $COUNT -lt $BEST_GAME || $BEST_GAME -eq 0 ]]
        then
          UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_games=$COUNT WHERE username='$NAME'")
        fi
        
      done
      echo "You guessed it in $COUNT tries. The secret number was $SECRET_NUMBER. Nice job!"
      exit 0
      
    else
      if (( $NUM > $SECRET_NUMBER ))
      then
        GUESS "It's higher than that, guess again:"
      else
        GUESS "It's lower than that, guess again:"
      fi
    fi

  # if input is not a number
  else
    GUESS "That is not an integer, guess again:"
  fi
}

GUESS "Guess the secret number between 1 and 1000:"
