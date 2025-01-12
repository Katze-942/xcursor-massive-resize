#!/bin/bash

source ./config.sh

read -r -p "The folder \"$PATH_TO_XCURSOR\" and \"$PATH_TO_ADAPT_XCURSOR\" will be deleted. Do you want to continue? (y/n) " answer
echo

if [[ $answer == y || $answer == Y ]]; then
    echo "Deleting the PATH_TO_XCURSOR ($PATH_TO_XCURSOR) folder..."
    rm -rf "$PATH_TO_XCURSOR"

    echo "Deleting the PATH_TO_ADAPT_XCURSOR ($PATH_TO_ADAPT_XCURSOR) folder..."
    rm -rf "$PATH_TO_ADAPT_XCURSOR"
else
    echo "The operation was canceled."
    exit
fi

echo "Done!";
