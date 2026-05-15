*** Variables ***
# ==============================================================
# SBX Variables — DFSP Toggle Testing Checklist
# Abucay and Hermosa Rural Bank
# Coverage: Mobile_001 – Mobile_024
# ==============================================================

# -------------------------------------------------------
# APP CONFIG
# Set SBX_APP_PACKAGE to the target RB being tested:
#   Abucay RB  → confirm package via: adb shell pm list packages | grep abucay
#   Hermosa RB → confirm package via: adb shell pm list packages | grep hermosa
# -------------------------------------------------------
${SBX_APP_PACKAGE}              com.higala.bancoabucay
${SBX_APP_ACTIVITY}             .MainActivity

# -------------------------------------------------------
# TEST ACCOUNTS
# Use accounts registered under the target RB (Abucay or Hermosa).
# SBX_EMAIL must be registered and in a clean state before each run.
# -------------------------------------------------------
${SBX_EMAIL}                    jjavier+84@nmblr.ai         # TODO: replace with Abucay/Hermosa RB test account
${SBX_PASSWORD}                 Password!1                  # TODO: replace with test account password

# Change Password (Mobile_021): changes to SBX_CP_NEW_PASSWORD then restores — no cleanup needed.
${SBX_CP_NEW_PASSWORD}          NewPass@2025

# Forgot Password (Mobile_004, Mobile_023): resets to SBX_FP_NEW_PASSWORD then restores — no cleanup needed.
${SBX_FP_NEW_PASSWORD}          FPNewPass@2025

# -------------------------------------------------------
# SAME-BANK RECIPIENT (Mobile_008, Mobile_010)
# Must be a valid account within the same RB being tested.
# -------------------------------------------------------
${SBX_SAME_BANK_RECIPIENT_ACCT}     7710385878105431        # TODO: replace with valid same-bank account number
${SBX_SAME_BANK_RECIPIENT_NAME}     Camille Reyes Mendoza   # TODO: replace with account holder name

# -------------------------------------------------------
# EXTERNAL BANK RECIPIENT (Mobile_012, Mobile_014)
# Used for transfers to an external bank (non-RB).
# -------------------------------------------------------
${SBX_EXT_BANK_SEARCH_TERM}         china
${SBX_EXT_BANK_RESULT}              xpath=//android.widget.TextView[@text='China Banking Corporation']
${SBX_EXT_RECIPIENT_ACCT}           101400001643
${SBX_EXT_RECIPIENT_NAME}           John Doe
${SBX_EXT_RECENT_CARD}              xpath=//android.widget.TextView[@text='${SBX_EXT_RECIPIENT_NAME}']

# -------------------------------------------------------
# RB-TO-RB RECIPIENT (Mobile_016)
# For Abucay → Hermosa transfer: sender is on Abucay app,
# recipient is a Hermosa RB account.
# For Hermosa → Abucay: swap accordingly and update SBX_APP_PACKAGE.
# -------------------------------------------------------
${SBX_RB_BANK_SEARCH_TERM}          rc
${SBX_RB_BANK_RESULT}               xpath=//android.widget.TextView[@text='Rizal Commercial Banking Corporation']
${SBX_RB_RECIPIENT_ACCT}            7710737754140432
${SBX_RB_RECIPIENT_NAME}            Paulo Navarro

# -------------------------------------------------------
# TRANSFER VALUES
# -------------------------------------------------------
${SBX_VALID_AMOUNT}             1
${SBX_NOTES}                    DFSP sanity test transfer

# -------------------------------------------------------
# LOCATORS — Home Page
# -------------------------------------------------------
${SBX_HOME_SCREEN}              xpath=//android.widget.TextView[contains(@text,'alance') or @text='Home']

# -------------------------------------------------------
# LOCATORS — Bottom Navigation
# -------------------------------------------------------
${SBX_HISTORY_TAB}              xpath=//android.widget.TextView[@text='History']
${SBX_PROFILE_TAB}              xpath=//android.widget.TextView[@text='Profile']

# -------------------------------------------------------
# LOCATORS — Transaction History / Details
# -------------------------------------------------------
${SBX_TX_HISTORY_SCREEN}        xpath=//android.widget.TextView[@text='Transaction History']
${SBX_TX_ITEM}                  xpath=(//android.widget.TextView[contains(@text,'₱')])[1]
${SBX_TX_DETAILS_SCREEN}        xpath=//android.widget.TextView[@text='Transaction Details' or @text='Transfer Result']

# -------------------------------------------------------
# LOCATORS — Profile Screen
# -------------------------------------------------------
${SBX_MORE_DETAILS_BTN}         xpath=//*[@text='More Details']
${SBX_EDIT_PROFILE_BTN}         xpath=//android.widget.TextView[@text='Edit Profile']
${SBX_CHANGE_PWD_BTN}           xpath=//android.widget.TextView[@text='Change Password']

# -------------------------------------------------------
# LOCATORS — Edit Account Screen
# -------------------------------------------------------
${SBX_EDIT_ACCOUNT_SCREEN}      xpath=//android.widget.TextView[@text='Edit Account']
${SBX_ID_EXPIRY_INPUT}          xpath=//*[contains(@text,'Expiry') or contains(@text,'expiry') or contains(@text,'Expiration')]/following::android.widget.EditText[1]
${SBX_OCCUPATION_INPUT}         xpath=//*[contains(@text,'Occupation') or contains(@text,'occupation')]/following::android.widget.EditText[1]
${SBX_SAVE_BTN}                 xpath=//*[@text='Save' or @text='Update' or @text='Submit' or @text='Confirm']
${SBX_EDIT_SUCCESS_MSG}         xpath=//android.widget.TextView[contains(@text,'successfully') or contains(@text,'Successfully') or contains(@text,'updated') or contains(@text,'saved')]

# -------------------------------------------------------
# LOCATORS — Update Password (Change Password) Screen
# -------------------------------------------------------
${SBX_CP_SCREEN}                xpath=//*[contains(@text,'Update Password')]
${SBX_CURRENT_PWD_FIELD}        xpath=(//android.widget.EditText)[1]
${SBX_NEW_PWD_FIELD}            xpath=(//android.widget.EditText)[2]
${SBX_CONFIRM_PWD_FIELD}        xpath=(//android.widget.EditText)[3]
${SBX_CP_SUBMIT_BTN}            xpath=//*[@text='Submit']
${SBX_CP_SUCCESS_MSG}           xpath=//android.widget.TextView[contains(@text,'Your new password is set') or contains(@text,'updated successfully')]
${SBX_BACK_TO_HOME_BTN}         xpath=//*[@text='Back to home']

# -------------------------------------------------------
# LOCATORS — Forgot Password Flow
# -------------------------------------------------------
${SBX_FP_LINK}                  xpath=//android.widget.TextView[@text='Forgot your password?']
${SBX_FP_EMAIL_FIELD}           xpath=//android.widget.EditText
${SBX_FP_SUBMIT_BTN}            xpath=//*[@text='Submit']
${SBX_FP_OTP_SCREEN}            xpath=//android.widget.TextView[@text='OTP Verification']
${SBX_FP_NEW_PWD_FIELD}         xpath=(//android.widget.EditText)[1]
${SBX_FP_CONFIRM_PWD_FIELD}     xpath=(//android.widget.EditText)[2]
${SBX_FP_SUCCESS_MSG}           xpath=//android.widget.TextView[contains(@text,'Your new password is set') or contains(@text,'updated')]
${SBX_BACK_TO_LOGIN_BTN}        xpath=//android.widget.TextView[@text='Back to Login' or @text='Back to login']
