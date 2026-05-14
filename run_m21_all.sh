#!/bin/bash
# ==============================================================
# M2.1 Login — Full Run (Happy Path + Negative, Magic OTP)
# Excludes: Session Timeout, Manual, Skipped, NotAutomatable
# Magic OTP values: 123456 (valid), 000000 (invalid), 999999 (max attempts)
# ==============================================================
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASE_RESULT_DIR="${BASE_DIR}/results/Login_All"
OUTPUT_DIR="${BASE_RESULT_DIR}/${TIMESTAMP}"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"

$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -e Manual \
  -e Skipped \
  -e Session \
  -e NotAutomatable \
  "${BASE_DIR}/Modules/Login/M2.1_Login_Email_OTP.robot"

cp "${OUTPUT_DIR}/output.xml"  "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/log.html"    "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/report.html" "${BASE_RESULT_DIR}/"
