#!/usr/bin/env bash

unlink "$(pwd)/client/shared" || echo "No client link..."
unlink "$(pwd)/server/shared" || echo "No server link..."

ln -sf "$(pwd)/shared" "$(pwd)/client/"
ln -sf "$(pwd)/shared" "$(pwd)/server/"