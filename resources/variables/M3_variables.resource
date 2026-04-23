*** Variables ***
# -------------------------------------------------------
# TEST ACCOUNTS — Account Management (M3)
#
# AM_VALID_EMAIL: Active registered account — used for profile view, edit, logout, account deletion.
# AM_CP_EMAIL:    Dedicated change-password account for TC_M3.3_001/002 (password will be changed).
#                 NOTE: After TC_M3.3_001 runs, this account's password becomes AM_CP_NEW_PASSWORD.
#                 Restore manually (or via M1.1 flow) before re-running TC_M3.3_001.
# AM_BLOCK_EMAIL_1–3: Dedicated block test accounts — used ONLY for TC_M3.3_015/016/017.
#                 WARNING: Running Destructive tests locks these emails for 60 minutes.
# -------------------------------------------------------
${AM_VALID_EMAIL}           jjavier+84@nmblr.ai
${AM_VALID_PASSWORD}        Password!1
${AM_CP_EMAIL}              jjavier+84@nmblr.ai
${AM_CP_PASSWORD}           Password!1
${AM_CP_NEW_PASSWORD}       NewPass@2025
${AM_BLOCK_EMAIL_1}         jjavier+am_block1@nmblr.ai
${AM_BLOCK_EMAIL_2}         jjavier+am_block2@nmblr.ai
${AM_BLOCK_EMAIL_3}         jjavier+am_block3@nmblr.ai
# Invalid / weak values
${AM_WRONG_PASSWORD}        WrongPass@999
${AM_WEAK_PASSWORD}         weakpass
${AM_MAGIC_OTP}             123456
${AM_INVALID_OTP}           000000
${AM_MAX_OTP}               999999
${AM_EXPIRED_RESET_PWD}     login_reset_password_expired

# -------------------------------------------------------
# LOCATORS — Bottom Navigation Bar
# Confirmed from screenshots: Home | History | Profile
# -------------------------------------------------------
${AM_HOME_TAB}              xpath=//android.widget.TextView[@text='Home']
${AM_HISTORY_TAB}           xpath=//android.widget.TextView[@text='History']
${AM_PROFILE_TAB}           xpath=//android.widget.TextView[@text='Profile']

# -------------------------------------------------------
# LOCATORS — Home Screen
# Confirmed: "Send Money" button, account number text, "Hide my balance" button
# -------------------------------------------------------
${AM_HOME_SCREEN}           xpath=//android.widget.TextView[contains(@text,'Acct no:')]
${AM_SEND_MONEY_BTN}        xpath=//*[@text='Send Money']
${AM_HIDE_BALANCE_BTN}      xpath=//*[@text='Hide my balance' or @text='Show my balance']

# -------------------------------------------------------
# LOCATORS — Profile Screen
# Confirmed from screenshot: shows name, email, gender, DOB, mobile number,
# "More Details >" button, "Edit Profile >" row, "Change Password >" row
# No title bar — detect via "More Details" button which is unique to this screen
# -------------------------------------------------------
${AM_MORE_DETAILS_BTN}      xpath=//*[@text='More Details']
${AM_EDIT_PROFILE_BTN}      xpath=//android.widget.TextView[@text='Edit Profile']
${AM_CHANGE_PWD_BTN}        xpath=//android.widget.TextView[@text='Change Password']

# -------------------------------------------------------
# LOCATORS — My Profile Screen (screen title: "My Profile")
# Confirmed sections: Personal Details, Address, Additional Details
# -------------------------------------------------------
${AM_MY_PROFILE_SCREEN}     xpath=//android.widget.TextView[@text='My Profile']
${AM_PERSONAL_DETAILS_HDR}  xpath=//android.widget.TextView[@text='Personal Details']
${AM_ADDRESS_HDR}           xpath=//android.widget.TextView[@text='Address']
${AM_ADDITIONAL_DETAILS_HDR}    xpath=//android.widget.TextView[@text='Additional Details']
# Individual fields — label:value pairs visible on My Profile screen
${AM_ID_TYPE_LABEL}         xpath=//android.widget.TextView[@text='ID Type:']
${AM_ID_NUMBER_LABEL}       xpath=//android.widget.TextView[@text='ID Number:']
${AM_ID_EXPIRY_LABEL}       xpath=//android.widget.TextView[@text='ID Expiry Date:']
${AM_PRESENT_ADDR_LABEL}    xpath=//android.widget.TextView[@text='Present Address:']
${AM_PERMANENT_ADDR_LABEL}  xpath=//android.widget.TextView[@text='Permanent Address:']
${AM_NATIONALITY_LABEL}     xpath=//android.widget.TextView[@text='Nationality:']
${AM_GENDER_LABEL}          xpath=//android.widget.TextView[@text='Gender:']
${AM_DOB_LABEL}             xpath=//android.widget.TextView[@text='Date of Birth:']
${AM_OCCUPATION_LABEL}      xpath=//android.widget.TextView[@text='Occupation:']
${AM_COMPANY_IND_LABEL}     xpath=//android.widget.TextView[@text='Company Industry:']
${AM_MONTHLY_INCOME_LABEL}  xpath=//android.widget.TextView[@text='Monthly Income:']
${AM_TIN_LABEL}             xpath=//android.widget.TextView[@text='TIN:']
${AM_US_FATCA_LABEL}        xpath=//android.widget.TextView[@text='US FATCA:']

# -------------------------------------------------------
# LOCATORS — Edit Account Screen (screen title: "Edit Account")
# Confirmed from screenshot: fields are US Citizenship (checkbox), Occupation (text, required),
# Company Industry (dropdown), Company Name (optional text), Monthly Income (dropdown), TIN (text, required)
# Save button: grayed/disabled when required fields are empty — no need to tap to trigger validation
# -------------------------------------------------------
${AM_EDIT_ACCOUNT_SCREEN}   xpath=//android.widget.TextView[@text='Edit Account']
${AM_OCCUPATION_INPUT}      xpath=//android.widget.TextView[@text='Occupation']/following::android.widget.EditText[1]
${AM_TIN_INPUT}             xpath=//android.widget.TextView[@text='TIN']/following::android.widget.EditText[1]
${AM_SAVE_BTN}              xpath=//*[@text='Save']
${AM_EDIT_SUCCESS_MSG}      xpath=//android.widget.TextView[contains(@text,'successfully') or contains(@text,'Successfully') or contains(@text,'updated') or contains(@text,'saved')]

# -------------------------------------------------------
# LOCATORS — Update Password Screen (m3.3)
# Screen title: "Update Password" (confirmed from screenshot)
# Fields: Current Password, New Password, Confirm Password
# Submit button: greyed out when empty, blue/active when all fields filled
# -------------------------------------------------------
${AM_CP_SCREEN}             xpath=//*[contains(@text,'Update Password')]
${AM_CURRENT_PWD_FIELD}     xpath=(//android.widget.EditText)[1]
${AM_NEW_PWD_FIELD}         xpath=(//android.widget.EditText)[2]
${AM_CONFIRM_PWD_FIELD}     xpath=(//android.widget.EditText)[3]
${AM_CP_SUBMIT_BTN}         xpath=//*[@text='Submit']

# -------------------------------------------------------
# LOCATORS — OTP Verification Screen (Change Password flow)
# Confirmed from screenshot:
# - Screen title: "OTP Verification"
# - 6 input boxes
# - "Resend code" green hyperlink (always visible)
# - "Resend available in 0:54" timer text (visible during cooldown)
# - Close button: "×" top-right corner (may use content-desc='Close')
# -------------------------------------------------------
${AM_OTP_SCREEN}            xpath=//android.widget.TextView[@text='OTP Verification']
${AM_RESEND_CODE}           xpath=//android.widget.TextView[@text='Resend code']
${AM_RESEND_TIMER}          xpath=//android.widget.TextView[contains(@text,'Resend available in')]
${AM_OTP_CLOSE_BTN}         xpath=//*[@content-desc='Close' or @content-desc='close' or @text='×' or @text='X']

# -------------------------------------------------------
# LOCATORS — Logout
# Confirmed from screenshot: blue full-width "Logout" button at bottom of Profile screen.
# No confirmation modal — tapping Logout redirects directly to the Sign In screen.
# -------------------------------------------------------
${AM_LOGOUT_BTN}            xpath=//*[@text='Logout']

# -------------------------------------------------------
# LOCATORS — Account Deletion (m3.5)
# -------------------------------------------------------
${AM_GENERAL_SETTINGS_BTN}  xpath=//*[@text='General Settings' or contains(@text,'General Settings')]
${AM_REQUEST_CLOSURE_BTN}   xpath=//*[@text='Request Account Closure' or contains(@text,'Account Closure') or contains(@text,'Account Deletion')]
${AM_FAQS_SCREEN}           xpath=//android.widget.TextView[contains(@text,'FAQ') or contains(@text,'Request Account') or contains(@text,'account deletion')]

# -------------------------------------------------------
# ERROR / VALIDATION MESSAGES
# -------------------------------------------------------
# Blank required field — confirmed text from screenshot: "This field is required."
${AM_FIELD_REQUIRED}        xpath=//android.widget.TextView[contains(@text,'This field is required')]
# Wrong current password: "Current Password does not match, please try again."
${AM_CURRENT_PWD_MISMATCH}  xpath=//android.widget.TextView[contains(@text,'Current Password does not match') or contains(@text,'does not match')]
# Password complexity hint
${AM_PWD_COMPLEXITY}        xpath=//android.widget.TextView[contains(@text,'password complexity') or contains(@text,'Please follow')]
# Mismatched new/confirm password
${AM_PWD_MISMATCH}          xpath=//android.widget.TextView[contains(@text,'Passwords do not match') or contains(@text,'do not match')]
# Wrong/expired OTP
${AM_OTP_ERROR}             xpath=//android.widget.TextView[contains(@text,'Invalid or has expired') or contains(@text,'OTP is either')]
# 5th wrong OTP max attempts
${AM_MAX_ATTEMPTS}          xpath=//android.widget.TextView[contains(@text,'maximum number of attempts') or contains(@text,'Verification Failed') or contains(@text,'Verification failed')]
# Email blocked / Change Password unavailable
${AM_BLOCKED_ERROR}         xpath=//android.widget.TextView[contains(@text,'exceeded') or contains(@text,'try again in') or contains(@text,'currently unavailable')]
# OTP expired modal
${AM_OTP_EXPIRED_MODAL}     xpath=//android.widget.TextView[contains(@text,'OTP Expired') or contains(@text,'one-time password has expired')]
# Success screen after password update: "Your new password is set!" + "Your password has been updated successfully!"
${AM_SUCCESS_MSG}           xpath=//android.widget.TextView[@text='Your new password is set!' or contains(@text,'password is set') or contains(@text,'updated successfully')]
# "Back to home" button on the password update success screen
${AM_BACK_TO_HOME_BTN}      xpath=//*[@text='Back to home']

# -------------------------------------------------------
# SHARED — Modal buttons / Session timeout
# -------------------------------------------------------
${AM_OK_BTN}                xpath=//*[@text='OK' or @text='Ok']
${AM_REQUEST_NEW_CODE_BTN}  xpath=//*[@text='Request New Code' or @text='Request new code']
${AM_SESSION_TIMEOUT}       xpath=//android.widget.TextView[contains(@text,'session') or contains(@text,'Session') or contains(@text,'timed out') or contains(@text,'timeout')]
