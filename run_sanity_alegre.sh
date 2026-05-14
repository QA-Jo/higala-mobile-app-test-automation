#!/bin/bash
# ==============================================================
# DFSP Toggle Testing Checklist — Alegre Sandbox
# Checklist: DFSP Toggle Testing Checklist - RBs with Same ITG Version - Mobile
# Coverage:  Mobile_001 – Mobile_024 (24 test cases)
# OTP:       Magic OTP (123456)
# ==============================================================
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASE_RESULT_DIR="${BASE_DIR}/results/Sanity_Alegre"
OUTPUT_DIR="${BASE_RESULT_DIR}/${TIMESTAMP}"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"

$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -e Manual \
  -e Skipped \
  -e ResetPassword \
  -e ExternalRCBC \
  --variable SBX_APP_PACKAGE:com.higala.alegresandbox \
  --variable SBX_EMAIL:jjavier+4@nmblr.ai \
  --variable "SBX_PASSWORD:Password!1" \
  --variable SBX_SAME_BANK_RECIPIENT_ACCT:7710398891916835 \
  --variable "SBX_SAME_BANK_RECIPIENT_NAME:Kacey Chui" \
  --variable SBX_RB_BANK_SEARCH_TERM:rc \
  --variable "SBX_RB_BANK_RESULT:xpath=//android.widget.TextView[@text='Rizal Commercial Banking Corporation']" \
  --variable SBX_RB_RECIPIENT_ACCT:7710737754140432 \
  --variable "SBX_RB_RECIPIENT_NAME:Paulo Navarro" \
  "${BASE_DIR}/Modules/Sanity/Sanity_SBX.robot"

# Keep base dir in sync so index.html links always point to latest run
cp "${OUTPUT_DIR}/output.xml"  "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/log.html"    "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/report.html" "${BASE_RESULT_DIR}/"
