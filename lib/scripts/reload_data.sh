#!/bin/bash
BASE_URL=http://localhost:3000/
DELETE_PATH=delete_all_data
LOAD_PATH=start_load

echo
echo "- Deleting All Data -"
curl $BASE_URL$DELETE_PATH
echo

sleep 5

echo
echo "- Loading All Data -"
curl $BASE_URL$LOAD_PATH
echo