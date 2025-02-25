#!/usr/bin/env bash
# Sequence of responses for the script, some will require multiple newlines (enter key)
set -xeo pipefail
./Nadeko.sh 2 3 5

yt-dlp -o - "https://www.youtube.com/watch?v=jNQXAC9IVRw" | ffmpeg -i pipe: -f null -

./Nadeko.sh 1 > app_output.log 2>&1 &

APP_PID=$!
EXPECTED_OUTPUT="Shard 0 ready"
TIMEOUT=30
COUNTER=0

while [ $COUNTER -lt $TIMEOUT ]; do
    if grep -q "$EXPECTED_OUTPUT" app_output.log; then
        echo "Expected output found. Stopping the app."

        kill $APP_PID
        exit 0
    fi

    sleep 1
    COUNTER=$((COUNTER + 1))
done

echo "Failed to start the bot: "
cat app_output.log
exit 1
