#!/bin/bash
# ============================================================
# Higala Mobile App — Full Test Suite Runner
# Module execution order:
#   1. Account Creation  (M1.2)
#   2. Account Activation (M1.1)
#   3. Login             (M2.1, M2.2)
#   4. Account Management (M3)
#   5. Account Details    (M4)
#   6. Send Money         (M5)
# ============================================================

set -e

ROBOT=/Library/Frameworks/Python.framework/Versions/3.14/bin/robot
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_DIR="${BASE_DIR}/results/full_run_$(date +%Y%m%d_%H%M%S)"

export ANDROID_HOME=~/Library/Android/sdk
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"

echo "============================================================"
echo " Higala Mobile App — Full Test Suite"
echo " Output: ${OUTPUT_DIR}"
echo "============================================================"

mkdir -p "${OUTPUT_DIR}"

$ROBOT \
  --outputdir "${OUTPUT_DIR}" \
  --output output.xml \
  --log log.html \
  --report report.html \
  --suite "M1.2 Account Creation" \
  --suite "M1.1 Account Activation" \
  --suite "M2.1 Login Email OTP" \
  --suite "M2.2 Forgot Password" \
  --suite "M3 Account Management" \
  --suite "M4 Account Details" \
  --suite "M5 Send Money" \
  "${BASE_DIR}/Modules/AccountCreation/M1.2_Account_Creation.robot" \
  "${BASE_DIR}/Modules/AccountActivation/M1.1_Account_Activation.robot" \
  "${BASE_DIR}/Modules/Login/M2.1_Login_Email_OTP.robot" \
  "${BASE_DIR}/Modules/Login/M2.2_Forgot_Password.robot" \
  "${BASE_DIR}/Modules/AccountManagement/M3_Account_Management.robot" \
  "${BASE_DIR}/Modules/AccountDetails/M4_Account_Details.robot" \
  "${BASE_DIR}/Modules/SendMoney/M5_Send_Money.robot"

echo ""
echo "============================================================"
echo " Done! Results at: ${OUTPUT_DIR}"
echo "============================================================"
