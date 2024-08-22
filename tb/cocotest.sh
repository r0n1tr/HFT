#!/bin/bash

# Check if a filename is provided as an argument
if [ -z "$1" ]; then
  echo "Usage: $0 <filename>"
  exit 1
fi

# Store the filename from the command line argument
FILENAME=$1

# Run make clean
echo "Cleaning ..."
make clean

# Run make with the provided filename
echo "Running tests and simulation ..."
make NAME=$FILENAME
