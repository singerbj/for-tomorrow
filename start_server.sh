#!/usr/bin/env bash

./stop_test.sh

logs_folder=`pwd`/logs
mkdir -p $logs_folder

echo "Starting server"
cd server
godot > $logs_folder/server.log 2>&1 &
echo $! > ../.godot_pids