#!/bin/bash
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${BASE_DIR}/results/Login_NegativePath"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"
$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -i Negative \
  -e Destructive \
  -e Session \
  -e Skipped \
  "${BASE_DIR}/Modules/Login/M2.1_Login_Email_OTP.robot"
