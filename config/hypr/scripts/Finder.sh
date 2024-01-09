#!/usr/bin/env bash


if [ ! -z "$@" ]; then
  QUERY=$@

  # Check if the query starts with "/"
  if [[ "$@" == /* ]]; then
    if [[ "$@" == *\?\? ]]; then
      # If the query ends with "??", open the directory
      coproc ( exo-open "${QUERY%\/* \?\?}"  > /dev/null 2>&1 )
      exec 1>&-
      exit;
    else
      # Open the file or directory
      coproc ( exo-open "$@"  > /dev/null 2>&1 )
      exec 1>&-
      exit;
    fi
  elif [[ "$@" == \!\!* ]]; then
    # Display help messages
    echo "!!-- Type your search query to find files"
    echo "!!-- To search again type !<search_query>"
    echo "!!-- To search parent directories type ?<search_query>"
    echo "!!-- You can print this help by typing !!"
  elif [[ "$@" == \?* ]]; then
    # Display search results for parent directories, including hidden files
    echo "!!-- Type another search query"
    while read -r line; do
      echo "$line" \?\?
    done <<< $(find ~ -type d -o -type f -iname *"${QUERY#\?}"* -print)
  else
    # Display search results for files, including hidden files
    echo "!!-- Type another search query"
    find ~ -type d -o -type f -iname *"${QUERY#!}"* -print
  fi
else
  # Display initial help messages
  echo "!!-- Type your search query to find files"
  echo "!!-- To search again type !<search_query>"
  echo "!!-- To search parent directories type ?<search_query>"
  echo "!!-- You can print this help by typing !!"
fi
