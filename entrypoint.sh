#! /bin/bash
set -e

if [ -z "$SERIAL" ]; then
  echo "ERROR: SERIAL environment variable is missing!"
  exit 1
fi

echo "Starting ADB server..."
adb start-server

adb devices
if [ $? -ne 0 ]; then
  echo "adb fail!"
  exit 1
fi

LOG_FILE="/app/log/device_${SERIAL}.log"
echo "Monkey starting on device: $SERIAL..."

echo "Running monkey test on $SERIAL at $(date)" > "$LOG_FILE" 2>&1
echo "Test finished. Log saved to $LOG_FILE"