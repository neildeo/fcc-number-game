#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID_SELECTED=$($PSQL "select user_id from users where username = '$USERNAME';")

if [[ -z $USER_ID_SELECTED ]]; then
  INSERT_NEW_USER=$($PSQL "insert into users(username) values('$USERNAME');")
  USER_ID_SELECTED=$($PSQL "select user_id from users where username = '$USERNAME';")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
else
  USER_GAMES_PLAYED=$($PSQL "select count(1) from games where user_id = $USER_ID_SELECTED;")
  USER_BEST_GAME=$($PSQL "select min(num_guesses) from games where user_id = $USER_ID_SELECTED;")
  echo -e "\nWelcome back, $USERNAME! You have played $USER_GAMES_PLAYED games, and your best game took $USER_BEST_GAME guesses.\n"
fi

SECRET_NUMBER=$(( 1 + $RANDOM % 1000 ))
# echo $SECRET_NUMBER # useful while debugging

echo -e "Guess the secret number between 1 and 1000:"
read GUESS
NUM_GUESSES=1
while [[ $GUESS -ne $SECRET_NUMBER ]]; do
  if [[ $GUESS =~ ^[0-9]+$ ]]; then
    if [[ $GUESS -gt $SECRET_NUMBER ]]; then
      echo "It's lower than that, guess again:"
    else
      echo "It's higher than that, guess again:"
    fi
  else
    echo "That is not an integer, guess again:"
  fi
  read GUESS
  NUM_GUESSES=$((NUM_GUESSES + 1))
done

INSERT_GAME=$($PSQL "insert into games(user_id, num_guesses) values('$USER_ID_SELECTED', $NUM_GUESSES);")

echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"