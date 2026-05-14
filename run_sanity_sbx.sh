#!/bin/bash
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASE_RESULT_DIR="${BASE_DIR}/results/Sanity_SBX"
OUTPUT_DIR="${BASE_RESULT_DIR}/${TIMESTAMP}"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"
$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -e Manual \
  -e Skipped \
  "${BASE_DIR}/Modules/Sanity/Sanity_SBX.robot"

# Keep base dir in sync so index.html links always point to latest run
cp "${OUTPUT_DIR}/output.xml"  "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/log.html"    "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/report.html" "${BASE_RESULT_DIR}/"
