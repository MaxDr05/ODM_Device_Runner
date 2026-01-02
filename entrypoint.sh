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
  echo "ERROR: adb fail!"
  exit 1
fi

LOG_FILE="/app/log/device_${SERIAL}.log"
LOG_PATH="/app/log"
mkdir -p "$LOG_PATH"

echo "clear logcat: $SERIAL..."
adb -s $SERIAL logcat -c
echo "Monkey starting on device: $SERIAL..."
adb -s $SERIAL shell monkey -p com.android.calculator2 -v 500 > "$LOG_FILE" 2>&1

adb -s $SERIAL logcat -d >> "$LOG_FILE"

echo "Test finished. Log saved to $LOG_FILE"