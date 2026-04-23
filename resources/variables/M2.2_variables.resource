*** Variables ***
# -------------------------------------------------------
# TEST ACCOUNTS — Forgot Password flow
# Primary + backup accounts for OTP rate-limit rotation.
# After 3 unverified OTP sessions within 15 min, an email is blocked for 60 min.
# Rotate accounts across tests to avoid hitting the limit mid-run.
# -------------------------------------------------------
${FP_VALID_EMAIL}           jjavier+101@nmblr.ai
${FP_VALID_EMAIL_2}         jjavier+84@nmblr.ai
${FP_VALID_EMAIL_3}         jjavier+82@nmblr.ai
${FP_VALID_EMAIL_4}         jjavier+89@nmblr.ai
${FP_VALID_EMAIL_5}         jjavier+93@nmblr.ai
# Fresh account (jjavier+1) — 0 prior failed OTP attempts
# Required for TC_M2.2_008, 009, 029, 030 which need a clean session count
${FP_VALID_EMAIL_6}         jjavier+1@nmblr.ai
${FP_VALID_PASSWORD}        Password!1
# Dedicated block test account — used only for TC_M2.2_026, 027, 028, 032
# WARNING: Running Destructive tests will lock this email for 60 minutes
${FP_BLOCK_EMAIL}           javier1@mailsac.com
# New password used in TC_M2.2_001 full reset flow
# NOTE: Change this value each run OR restore the account password manually after TC_M2.2_001/002
${FP_NEW_PASSWORD}          NewPass@2025

# -------------------------------------------------------
# OTP MAGIC VALUES
# -------------------------------------------------------
${FP_VALID_OTP}             123456
${FP_INVALID_OTP}           000000
${FP_MAX_OTP}               999999
${FP_EXPIRED_RESET_PWD}     login_reset_password_expired

# -------------------------------------------------------
# LOCATORS — Forgot Password flow
# NOTE: All verified against live app via Appium Inspector.
#       Update here if the app's UI structure changes.
# -------------------------------------------------------

# Login screen → "Forgot your password?" link
${FP_LINK}                  xpath=//android.widget.TextView[@text='Forgot your password?']

# FP Email screen
# Only 1 EditText on this screen (no hint attr) — use bare xpath
${FP_EMAIL_FIELD}           xpath=//android.widget.EditText
# Submit is android.widget.Button (not TextView) — wildcard to match either
${FP_SUBMIT_BTN}            xpath=//*[@text='Submit']

# OTP Verification screen
${FP_OTP_SCREEN}            xpath=//android.widget.TextView[@text='OTP Verification']
${FP_RESEND_CODE}           xpath=//android.widget.TextView[@text='Resend code']
# X / Close button on OTP screen
# Alternatives if '×' fails: xpath=//android.widget.TextView[@text='✕']  |  accessibility_id=Close
${FP_OTP_CLOSE_BTN}         xpath=//android.widget.TextView[@text='×']

# FP New Password screen
# Positional xpath used — only 2 EditText fields on this screen
# Verify exact field order with Appium Inspector if fails
${FP_NEW_PWD_FIELD}         xpath=(//android.widget.EditText)[1]
${FP_CONFIRM_PWD_FIELD}     xpath=(//android.widget.EditText)[2]
${FP_NEW_PWD_SUBMIT}        xpath=//*[@text='Submit']

# -------------------------------------------------------
# ERROR / VALIDATION MESSAGES — confirmed via Appium Inspector
# -------------------------------------------------------

# Empty email: no inline error shown — form stays on page (TC_M2.2_019 tagged Skipped)
${FP_FIELD_REQUIRED}        xpath=//android.widget.TextView[contains(@text,'required') or contains(@text,'Required') or contains(@text,'This field')]
# Invalid format: "Incorrect email format."
${FP_INVALID_FORMAT}        xpath=//android.widget.TextView[contains(@text,'Incorrect email format') or contains(@text,'format')]
# Unregistered email: "Email address is invalid, please try again."
${FP_INVALID_EMAIL_MSG}     xpath=//android.widget.TextView[contains(@text,'Email address is invalid') or contains(@text,'invalid, please try again')]
# Wrong OTP: "OTP is either Invalid or has expired. Please try again or request a new OTP."
${FP_OTP_ERROR}             xpath=//android.widget.TextView[contains(@text,'Invalid or has expired') or contains(@text,'OTP is either')]
# 5th wrong OTP: title="Verification failed", body contains "maximum number of attempts"
${FP_MAX_ATTEMPTS}          xpath=//android.widget.TextView[contains(@text,'maximum number of attempts') or contains(@text,'Verification failed') or contains(@text,'Verification Failed')]
# Email blocked: "You have exceeded the maximum number of OTP attempts. You can try again in N mins."
${FP_BLOCKED_ERROR}         xpath=//android.widget.TextView[contains(@text,'exceeded') or contains(@text,'try again in') or contains(@text,'blocked')]
# Weak password: "Please follow the password complexity."
${FP_PWD_COMPLEXITY}        xpath=//android.widget.TextView[contains(@text,'password complexity') or contains(@text,'Please follow')]
# Mismatch: "Passwords does not match. Please try again." (note: "does not" not "do not")
${FP_PWD_MISMATCH}          xpath=//android.widget.TextView[contains(@text,'does not match') or contains(@text,'do not match') or contains(@text,'Passwords does not')]
# Empty password fields
${FP_PWD_REQUIRED}          xpath=//android.widget.TextView[contains(@text,'required') or contains(@text,'Required')]
# Reset success: "Your new password is set!"
${FP_SUCCESS_MSG}           xpath=//android.widget.TextView[contains(@text,'Your new password is set') or contains(@text,'success') or contains(@text,'updated')]

# -------------------------------------------------------
# SHARED — Session timeout / navigation
# -------------------------------------------------------
${SESSION_TIMEOUT_MODAL}    xpath=//android.widget.TextView[@text='Session Timeout']
${INACTIVE_MSG}             xpath=//android.widget.TextView[@text='You have been inactive for 5 minutes']
# Capital L on session timeout modal; lowercase l on success screen — both handled
${BACK_TO_LOGIN_BTN}        xpath=//android.widget.TextView[@text='Back to Login' or @text='Back to login']
${EMAIL_FIELD}              xpath=//android.widget.EditText[@hint='Email Address']
${OK_BTN}                   xpath=//android.widget.Button[@text='Ok'] or xpath=//android.widget.TextView[@text='Ok'] or xpath=//android.widget.TextView[@text='OK']
