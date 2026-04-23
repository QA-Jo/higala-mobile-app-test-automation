*** Variables ***
# -------------------------------------------------------
# TEST ACCOUNTS — Account Activation (Temporary Password) flow
#
# These accounts must have active temporary credentials issued by the bank.
# After 3 unverified OTP sessions within 15 min, the email is blocked for 60 min.
# Rotate across AA_TEMP_EMAIL_1–6 to avoid hitting the block limit mid-run.
# -------------------------------------------------------
${AA_TEMP_EMAIL_1}          jjavier+110@nmblr.ai
${AA_TEMP_EMAIL_2}          jjavier+111@nmblr.ai
${AA_TEMP_EMAIL_3}          jjavier+112@nmblr.ai
${AA_TEMP_EMAIL_4}          jjavier+113@nmblr.ai
${AA_TEMP_EMAIL_5}          jjavier+114@nmblr.ai
${AA_TEMP_EMAIL_6}          jjavier+115@nmblr.ai
# Shared temporary password for all test accounts (issued by bank)
${AA_TEMP_PASSWORD}         TempPass@1
# New password set during TC_M1.1_002 (happy path).
# NOTE: Update this value each run OR restore the account manually after TC_M1.1_002.
${AA_NEW_PASSWORD}          NewPass@2025
# Dedicated block test accounts — used ONLY for TC_M1.1_012/013/014/015/016
# WARNING: Running Destructive tests will lock these emails for 60 minutes.
${AA_BLOCK_EMAIL}           jjavier+aa_block1@nmblr.ai
${AA_BLOCK_EMAIL_2}         jjavier+aa_block2@nmblr.ai
${AA_BLOCK_EMAIL_3}         jjavier+aa_block3@nmblr.ai
# Invalid test values
${AA_INVALID_EMAIL}         notanemail.com
${AA_WRONG_TEMP_PASSWORD}   WrongPass@999
${AA_WEAK_PASSWORD}         weakpass
${AA_MAGIC_OTP}             123456
${AA_INVALID_OTP}           000000
${AA_MAX_OTP}               999999

# -------------------------------------------------------
# LOCATORS — Login screen
# -------------------------------------------------------
${AA_EMAIL_FIELD}           xpath=//android.widget.EditText[@hint='Email Address']
${AA_PWD_FIELD}             xpath=//android.widget.EditText[@hint='Password']
${AA_SIGN_IN_BTN}           accessibility_id=Sign in

# -------------------------------------------------------
# LOCATORS — Update Password screen
# Screen appears after successful login with a temporary password.
# Temporary password field is pre-filled and disabled by the system.
# -------------------------------------------------------
${AA_UPDATE_PWD_SCREEN}     xpath=//android.widget.TextView[contains(@text,'temporary password') or contains(@text,'Update Password') or contains(@text,'Change Password') or contains(@text,'Reset Password')]
${AA_NEW_PWD_FIELD}         xpath=(//android.widget.EditText)[2]
${AA_CONFIRM_PWD_FIELD}     xpath=(//android.widget.EditText)[3]
${AA_RESET_BTN}             xpath=//*[@text='Reset password' or @text='Reset Password']

# -------------------------------------------------------
# LOCATORS — OTP Verification screen
# -------------------------------------------------------
${AA_OTP_SCREEN}            xpath=//android.widget.TextView[@text='OTP Verification']
${AA_RESEND_CODE}           xpath=//android.widget.TextView[@text='Resend code']
${AA_OTP_CLOSE_BTN}         xpath=//android.widget.TextView[@text='×']

# -------------------------------------------------------
# ERROR / VALIDATION MESSAGES
# -------------------------------------------------------
# Empty field: "This field is required."
${AA_FIELD_REQUIRED}        xpath=//android.widget.TextView[contains(@text,'required') or contains(@text,'Required') or contains(@text,'This field')]
# Invalid email or wrong password: "Incorrect Email Address or Password, please try again."
${AA_INVALID_CREDENTIALS}   xpath=//android.widget.TextView[contains(@text,'Incorrect Email Address or Password') or contains(@text,'incorrect') or contains(@text,'Incorrect')]
# Temporary password mismatch: "Temporary password does not match, please try again."
${AA_TEMP_PWD_MISMATCH}     xpath=//android.widget.TextView[contains(@text,'Temporary password does not match') or contains(@text,'does not match')]
# Wrong OTP
${AA_OTP_ERROR}             xpath=//android.widget.TextView[contains(@text,'Invalid or has expired') or contains(@text,'OTP is either')]
# 5th wrong OTP: "Verification Failed: You have reached the maximum number of attempts..."
${AA_MAX_ATTEMPTS}          xpath=//android.widget.TextView[contains(@text,'maximum number of attempts') or contains(@text,'Verification Failed') or contains(@text,'Verification failed')]
# Email blocked: "You have exceeded the maximum number of OTP attempts. You can try again in N mins."
${AA_BLOCKED_ERROR}         xpath=//android.widget.TextView[contains(@text,'exceeded') or contains(@text,'try again in') or contains(@text,'blocked')]
# OTP expired modal: "OTP Expired: Your one-time password has expired."
${AA_OTP_EXPIRED_MODAL}     xpath=//android.widget.TextView[contains(@text,'OTP Expired') or contains(@text,'one-time password has expired')]
# Password complexity: "Please follow the password complexity..."
${AA_PWD_COMPLEXITY}        xpath=//android.widget.TextView[contains(@text,'password complexity') or contains(@text,'Please follow')]
# Account locked after 5 wrong login attempts: "maximum number of login attempts"
${AA_ACCOUNT_LOCKED}        xpath=//android.widget.TextView[contains(@text,'maximum number of login attempts') or contains(@text,'locked') or contains(@text,'5 minutes')]
# Success: password updated successfully
${AA_SUCCESS_MSG}           xpath=//android.widget.TextView[contains(@text,'password is set') or contains(@text,'successfully') or contains(@text,'updated') or contains(@text,'success')]

# -------------------------------------------------------
# SHARED — Modal action buttons / Session timeout
# -------------------------------------------------------
${AA_OK_BTN}                xpath=//*[@text='OK' or @text='Ok']
${AA_REQUEST_NEW_CODE_BTN}  xpath=//*[@text='Request New Code' or @text='Request new code']
${AA_SESSION_TIMEOUT}       xpath=//android.widget.TextView[contains(@text,'session') or contains(@text,'Session') or contains(@text,'timed out') or contains(@text,'timeout')]
${AA_BACK_TO_LOGIN}         xpath=//android.widget.TextView[@text='Back to Login' or @text='Back to login']
