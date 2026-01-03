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

# 容错点 C: 精确的设备状态检查
# 仅仅 adb devices 是不够的，必须 grep 到 serial 且状态为 device
echo "Checking device status for $SERIAL..."
adb devices | grep "$SERIAL" | grep "\bdevice\b" > /dev/null
if [ $? -ne 0 ]; then
  echo "FATAL: Device $SERIAL is missing, offline, or unauthorized!"
  # 直接退出，不要浪费时间跑 Monkey
  exit 1
fi

# 容错点 D: 目标应用预检 (Pre-flight Check)
# 防止因为包名错误或未安装导致的无效测试
TARGET_PKG="com.android.calculator2"
echo "Checking if package $TARGET_PKG is installed..."
adb -s $SERIAL shell pm list packages | grep "$TARGET_PKG" > /dev/null
if [ $? -ne 0 ]; then
  echo "FATAL: Package $TARGET_PKG is NOT installed on $SERIAL!"
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