#!/usr/bin/env bash

./stop_all.sh

logs_folder=`pwd`/logs
mkdir -p $logs_folder

number_of_clients=$1
if [ "$number_of_clients" == "" ]; then
    number_of_clients=1
fi

echo "Starting server"
cd server
godot > $logs_folder/server.log 2>&1 &
echo $! > ../.godot_pids

cd ../client
for i in $(seq 1 $number_of_clients);
do
    echo "Starting client $i"
    godot > $logs_folder/client-$i.log 2>&1 &
    echo $! >> ../.godot_pids
done
