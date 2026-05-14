#!/bin/bash
# ==============================================================
# DFSP Toggle Testing Checklist — San Narciso Sandbox
# Checklist: DFSP Toggle Testing Checklist - RBs with Same ITG Version - Mobile
# Coverage:  Mobile_001 – Mobile_024 (24 test cases)
# OTP:       Magic OTP (123456)
# Sender:    Jocelyn Amban — jjavier+1@nmblr.ai
# Recipient: Jane de Leon  — 7710979526367051 (same-bank)
# RB-to-RB:  Paulo Navarro — 7710737754140432 (via RCBC to Abucay)
# ==============================================================
ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BASE_RESULT_DIR="${BASE_DIR}/results/Sanity_SanNarciso"
OUTPUT_DIR="${BASE_RESULT_DIR}/${TIMESTAMP}"
export ANDROID_HOME=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
mkdir -p "${OUTPUT_DIR}"

$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  -e Manual \
  -e Skipped \
  -e ResetPassword \
  --variable SBX_APP_PACKAGE:com.higala.ruralbankofsannarcisosandbox \
  --variable SBX_EMAIL:jjavier+3@nmblr.ai \
  --variable "SBX_PASSWORD:Password!1" \
  --variable SBX_SAME_BANK_RECIPIENT_ACCT:7710935377438751 \
  --variable "SBX_SAME_BANK_RECIPIENT_NAME:Jocelyn Amban" \
  --variable SBX_RB_BANK_SEARCH_TERM:rc \
  --variable "SBX_RB_BANK_RESULT:xpath=//android.widget.TextView[@text='Rizal Commercial Banking Corporation']" \
  --variable SBX_RB_RECIPIENT_ACCT:7710737754140432 \
  --variable "SBX_RB_RECIPIENT_NAME:Paulo Navarro" \
  "${BASE_DIR}/Modules/Sanity/Sanity_SBX.robot"

# Keep base dir in sync so index.html links always point to latest run
cp "${OUTPUT_DIR}/output.xml"  "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/log.html"    "${BASE_RESULT_DIR}/"
cp "${OUTPUT_DIR}/report.html" "${BASE_RESULT_DIR}/"
