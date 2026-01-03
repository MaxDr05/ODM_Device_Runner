#! /bin/bash
set -e

if [ -z "$SERIAL" ]; then
  echo "ERROR: SERIAL environment variable is missing!"
  exit 1
fi

echo "Starting ADB server..."
adb start-server

if [[ $SERIAL = MOCK* ]]; then
  LOG_FILE="/app/log/device_${SERIAL}.log"
  LOG_PATH="/app/log"
  mkdir -p "$LOG_PATH"
  echo "Monkey starting on device: $SERIAL..." > "$LOG_FILE"
  echo "Event: Touch (100, 200)" >> "$LOG_FILE"
  echo "Event: Key Press HOME" >> "$LOG_FILE"
  echo "Mock Test Finished successfully." >> "$LOG_FILE"

  echo "Mock task finished. Log saved to $LOG_FILE"
  exit 0
fi

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

# 记录 Monkey 输出
adb -s $SERIAL shell monkey -p com.android.calculator2 -v 500 > "$LOG_FILE" 2>&1

# 追加系统日志
adb -s $SERIAL logcat -d >> "$LOG_FILE"

echo "Test finished. Log saved to $LOG_FILE"