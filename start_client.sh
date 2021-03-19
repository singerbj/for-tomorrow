#!/usr/bin/env bash

./stop_test.sh

logs_folder=`pwd`/logs
mkdir -p $logs_folder

cd client

echo "Starting client $i"
godot > $logs_folder/client-$i.log 2>&1 &
echo $! >> ../.godot_pids
