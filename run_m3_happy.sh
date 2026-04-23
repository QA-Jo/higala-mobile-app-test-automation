#!/bin/bash
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${BASE_DIR}/results/m3_happy_debug"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"
$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -i Positive \
  -e Destructive \
  "${BASE_DIR}/Modules/AccountManagement/M3_Account_Management.robot"
