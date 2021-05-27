#!/bin/bash

warn () {
  text=$1
  echo -e "\e[1;33m $text \e[0m"
}

fail () {
  text=$1
  echo -e "\e[1;31m $text \e[0m"
  exit 1
}

success () {
  text=$1
  echo -e "\e[1;32m $text \e[0m"
}

info () {
  text=$1
  echo -e "\e[1;34m $text \e[0m"
}

debug () {
  text=$1
  echo -e "\e[1;40m $text \e[0m"
}

set_auth() {
  local s3cnf="$HOME/.s3cfg"

  if [ -e "$s3cnf" ]; then
    warn '.s3cfg file already exists in home directory and will be overwritten'
  fi

  echo '[default]' > "$s3cnf"
  echo "access_key=$ACCESS_KEY" >> "$s3cnf"
  echo "secret_key=$SECRET_KEY" >> "$s3cnf"

  echo "Generated .s3cfg for key $ACCESS_KEY"
}

main() {
  set_auth

  info 'Starting S3 Synchronisation'

  info 'Check s3cmd version'
  info $(s3cmd --version)

  if [ -z "$BUCKET" ]; then
    fail 'AWS_S3_BUCKET is not set. Quitting.'
  fi

  if [ -z "$ACCESS_KEY" ]; then
    fail 'ACCESS_KEY is not set. Quitting.'
  fi

  if [ -z "$SECRET_KEY" ]; then
    fail 'AWS_SECRET_ACCESS_KEY is not set. Quitting.'
  fi

  if [ -z "$EXTRA_OPTS" ]; then
      EXTRA_OPTS="--verbose"
  fi

  if [ -z "$ADD_HEADERS" ]; then
      ADD_HEADERS=""
  fi

  export IFS='|'
  for header in $ADD_HEADERS; do
    HEADERS="--add-header=\"$header\" $HEADERS"
  done

  COMMAND_SUFIX="$FILE s3://$AWS_S3_BUCKET"

  command="s3cmd put --no-preserve $EXTRA_OPTS $HEADERS $COMMAND_SUFIX"

  debug $command

  bash -c $command
  RESULT=$?

  if [[ $? -eq 0 ]]; then
      success 'Finished S3 Synchronisation';
  else
      fail 'Failed s3cmd command';
  fi

  warn 'Removing .s3cfg credentials'
  rm "$HOME/.s3cfg"
}

main
