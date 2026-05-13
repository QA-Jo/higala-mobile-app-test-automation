*** Variables ***
# ==============================================================
# Alegre Variables — DFSP Toggle Testing Checklist
# Alegre Sandbox (SBX)
# Coverage: Mobile_001 – Mobile_024
# ==============================================================

# -------------------------------------------------------
# APP CONFIG
# Confirm package via: adb shell pm list packages | grep alegre
# -------------------------------------------------------
${SBX_APP_PACKAGE}              com.higala.alegresandbox
${SBX_APP_ACTIVITY}             .MainActivity

# -------------------------------------------------------
# TEST ACCOUNTS
# Primary sender: Rhiza Talavera (Customer 1)
# -------------------------------------------------------
${SBX_EMAIL}                    rtalavera@nmblr.ai
${SBX_PASSWORD}                 @Password123

# Change Password (Mobile_021): changes to SBX_CP_NEW_PASSWORD then restores — no cleanup needed.
${SBX_CP_NEW_PASSWORD}          NewPass@2025

# Forgot Password (Mobile_004, Mobile_023): resets to SBX_FP_NEW_PASSWORD then restores — no cleanup needed.
${SBX_FP_NEW_PASSWORD}          FPNewPass@2025

# -------------------------------------------------------
# SAME-BANK RECIPIENT (Mobile_008, Mobile_010)
# Recipient: Illyzabeth Tsui (Customer 2) — same Alegre RB
# -------------------------------------------------------
${SBX_SAME_BANK_RECIPIENT_ACCT}     7711498267780269
${SBX_SAME_BANK_RECIPIENT_NAME}     Illyzabeth Tsui

# -------------------------------------------------------
# EXTERNAL BANK RECIPIENT (Mobile_012, Mobile_014)
# Used for transfers to an external bank (non-RB).
# -------------------------------------------------------
${SBX_EXT_BANK_SEARCH_TERM}         rc
${SBX_EXT_BANK_RESULT}              xpath=//android.widget.TextView[@text='Rizal Commercial Banking Corporation']
${SBX_EXT_RECIPIENT_ACCT}           101400001643            # TODO: replace with valid external bank account
${SBX_EXT_RECIPIENT_NAME}           John Doe                # TODO: replace with account holder name
${SBX_EXT_RECENT_CARD}              xpath=//android.widget.TextView[@text='${SBX_EXT_RECIPIENT_NAME}']

# -------------------------------------------------------
# RB-TO-RB RECIPIENT (Mobile_016)
# Sender is on Alegre app; recipient is an account on another RB.
# -------------------------------------------------------
${SBX_RB_BANK_SEARCH_TERM}          rc
${SBX_RB_BANK_RESULT}               xpath=//android.widget.TextView[@text='Rizal Commercial Banking Corporation']
${SBX_RB_RECIPIENT_ACCT}            7710737754140432        # TODO: replace with valid RB-to-RB recipient account
${SBX_RB_RECIPIENT_NAME}            Paulo Navarro           # TODO: replace with recipient name

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
${SBX_SAVE_BTN}                 xpath=//*[@text='Save']
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
