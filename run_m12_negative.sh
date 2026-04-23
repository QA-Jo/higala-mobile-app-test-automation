#!/bin/bash
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${BASE_DIR}/results/m12_negative_run"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"
$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -i Negative \
  "${BASE_DIR}/Modules/AccountCreation/M1.2_Account_Creation.robot"
