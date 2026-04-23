*** Variables ***
# -------------------------------------------------------
# TEST ACCOUNTS — Send Money (M5)
#
# SM_VALID_EMAIL:  jjavier+84@nmblr.ai — San Antonio savings; used for m5.1, m5.2, m5.8 (sender)
# SM_MULTI_EMAIL:  jjavier+1@nmblr.ai  — Abucay savings; used for m5.7 self-transfer, m5.8 (receiver)
# -------------------------------------------------------
${SM_VALID_EMAIL}               jjavier+84@nmblr.ai
${SM_VALID_PASSWORD}            Password!1
${SM_MULTI_EMAIL}               jjavier+1@nmblr.ai
${SM_MULTI_PASSWORD}            Password!1

# -------------------------------------------------------
# RECIPIENT ACCOUNTS
# Same-bank recipient — update with a valid active account in the same bank
# -------------------------------------------------------
${SM_SAME_BANK_RECIPIENT_ACCT}  7710385878105431
${SM_SAME_BANK_RECIPIENT_NAME}  Camille Reyes Mendoza
${SM_INVALID_ACCT_NUM}          9999999999999       # Account that does not exist

# Other-bank recipient (Chinabank) — for m5.2 direct other-bank transfer
${SM_CHINA_BANK_NAME}           China Banking Corporation
${SM_CHINA_BANK_SEARCH_TERM}    china
${SM_CHINA_RECIPIENT_ACCT}      101400001643
${SM_CHINA_RECIPIENT_NAME}      John Doe
${SM_BANK_RESULT_CHINA}         xpath=//android.widget.TextView[@text='China Banking Corporation']

# RCBC — kept for m5.8 RB-to-RB Abucay intermediary (do NOT change)
${SM_RCBC_BANK_NAME}            Rizal Commercial Banking Corporation
${SM_RCBC_BANK_SEARCH_TERM}     rc
${SM_RCBC_RECIPIENT_ACCT}       0007101000011
${SM_RCBC_RECIPIENT_NAME}       John Doe

# Self-transfer — jjavier+84@nmblr.ai second savings account
${SM_SELF_ACCT_A_NUM}           0000000000002       # TODO: replace with primary acct number if needed
${SM_SELF_ACCT_B_NUM}           7710350637354572
${SM_SELF_ACCT_B_NAME}          Joy amban

# -------------------------------------------------------
# ABUCAY BANK — RB-to-RB External Transfer (m5.8)
# Sender:   San Antonio app  — jjavier+84@nmblr.ai
# Receiver: Abucay app       — jjavier+9@nmblr.ai  (same emulator: emulator-5554)
#
# IMPORTANT: All RB-to-RB transfers route through Rizal Commercial Banking
# Corporation (RCBC) as the Instapay intermediary. In the Other Bank search,
# select "Rizal Commercial Banking Corporation" — NOT the Abucay bank directly.
# The Abucay account number (7710501333354703) identifies the recipient on the
# RCBC network. SM_RCBC_BANK_SEARCH_TERM ("rc") is reused for bank selection.
#
# Both apps are installed on the SAME emulator (emulator-5554).
# Use Activate App / Terminate App to switch between them within one Appium session.
# -------------------------------------------------------
${SM_ABUCAY_RECIPIENT_ACCT}     7710501333354703
${SM_ABUCAY_RECIPIENT_NAME}     jooo Abucay
${SM_ABUCAY_EMAIL}              jjavier+9@nmblr.ai
${SM_ABUCAY_PASSWORD}           Password!1

# App packages — confirmed via: adb -s emulator-5554 shell pm list packages
${SAN_ANTONIO_APP_PACKAGE}      com.higala.ruralbanksanantonioitg
${SAN_ANTONIO_APP_ACTIVITY}     .MainActivity
${ABUCAY_APP_PACKAGE}           com.higala.bancoabucayitg
${ABUCAY_APP_ACTIVITY}          .MainActivity
# Device — confirmed via: adb devices
${ABUCAY_DEVICE_NAME}           emulator-5554

# -------------------------------------------------------
# TRANSFER VALUES
# -------------------------------------------------------
${SM_VALID_AMOUNT}              1
${SM_OVER_BALANCE_AMOUNT}       9999999
${SM_OVER_LIMIT_AMOUNT}         100001
${SM_OVER_DAILY_LIMIT_AMOUNT}   500001
${SM_NOTES}                     Automation test transfer
${SM_LONG_NOTES}                AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
${SM_INVALID_NOTES}             @#\$%^ invalid chars
${SM_OTP}                       123456
${SM_INVALID_OTP}               000000
${SM_MAX_OTP}               999999

# -------------------------------------------------------
# LOCATORS — Home Screen (Send Button)
# Note: button text may appear as "Send Money" or "Send" depending on account layout
# -------------------------------------------------------
${SM_SEND_BTN}                  xpath=//*[@text='Send Money' or @text='Send']
${SM_HOME_SCREEN}               xpath=//android.widget.TextView[contains(@text,'available balance') or contains(@text,'Available balance')]

# -------------------------------------------------------
# LOCATORS — Send Funds Screen
# -------------------------------------------------------
${SM_SEND_FUNDS_SCREEN}         xpath=//android.widget.TextView[@text='Send Funds']
${SM_SAME_BANK_BTN}             xpath=//*[@text='Same Bank']
${SM_OTHER_BANK_BTN}            xpath=//*[@text='Other Bank']
${SM_EWALLET_BTN}               xpath=//*[@text='E-wallet']
${SM_RECENT_SECTION}            xpath=//android.widget.TextView[contains(@text,'Recent')]
${SM_RECENT_RECIPIENT_ITEM}     xpath=(//android.widget.TextView[contains(@text,'**')])[1]

# -------------------------------------------------------
# LOCATORS — Bank Search Modal (Other Bank)
# Appears after tapping Other Bank; search field + results list
# -------------------------------------------------------
${SM_BANK_SEARCH_FIELD}         xpath=//android.widget.EditText
${SM_BANK_RESULT_RCBC}          xpath=//android.widget.TextView[@text='Rizal Commercial Banking Corporation']

# -------------------------------------------------------
# LOCATORS — To Same Bank / To [Bank Name] Recipient Screen
# Confirmed from screenshots:
# - Title: "To Same Bank" (internal) | "To Rizal Commercial Banking Corporation" (external)
# - Fields: Account number (hint: "Enter account number"), Account name (hint: "Enter account name")
# - "Recent" bold header when prior recipients exist
# - Recent recipient card: Name / Bank / **last4 with ">" chevron
# - "No Accounts Found" placeholder when no recent recipients (no-recipient flow)
# - "Next" button (greyed when no account entered)
# -------------------------------------------------------
${SM_TO_SAME_BANK_SCREEN}       xpath=//android.widget.TextView[@text='To Same Bank']
${SM_TO_EXTERNAL_SCREEN}        xpath=//android.widget.TextView[contains(@text,'To Rizal') or contains(@text,'To China') or contains(@text,'To ')]
${SM_ACCT_NUM_FIELD}            xpath=//android.widget.EditText[@hint='Enter account number']
${SM_ACCT_NAME_FIELD}           xpath=//android.widget.EditText[@hint='Enter account name']
${SM_NEXT_BTN}                  xpath=//*[@text='Next']
${SM_NO_ACCOUNTS_FOUND}         xpath=//android.widget.TextView[@text='No Accounts Found' or @text='No accounts found']
# Recent section on recipient screen (shown when prior transfers exist)
${SM_RECENT_SECTION_HDR}        xpath=//android.widget.TextView[@text='Recent']
# Recent recipient card — tap to auto-fill account number + name
${SM_RCBC_RECENT_CARD}          xpath=//android.widget.TextView[@text='${SM_RCBC_RECIPIENT_NAME}']

# Validation errors on recipient screen (same bank)
${SM_ACCT_NUM_SPECIAL_CHAR_ERR}    xpath=//android.widget.TextView[contains(@text,'Only numerical values are allowed')]
${SM_ACCT_NUM_REQUIRED_ERR}     xpath=//android.widget.TextView[contains(@text,'Account number is required') or contains(@text,'This field is required')]
${SM_SELF_TRANSFER_ERR}         xpath=//android.widget.TextView[contains(@text,'cannot send money to yourself')]
${SM_ACCT_NAME_REQUIRED_ERR}    xpath=//android.widget.TextView[contains(@text,'Account name is required') or contains(@text,'This field is required')]
${SM_ACCT_NAME_SPECIAL_ERR}     xpath=//android.widget.TextView[contains(@text,'Special characters are not allowed') or contains(@text,'special characters are allowed')]

# -------------------------------------------------------
# LOCATORS — Transfer Screen
# -------------------------------------------------------
${SM_TRANSFER_SCREEN}           xpath=//android.widget.TextView[@text='Transfer']
${SM_AVAIL_BALANCE_LABEL}       xpath=//android.widget.TextView[contains(@text,'Available balance')]
${SM_AMOUNT_INPUT}              xpath=(//android.widget.EditText)[1]
${SM_NOTES_FIELD}               xpath=//android.widget.EditText[contains(@hint,'Notes') or contains(@hint,'notes') or contains(@hint,'optional')]
${SM_PROCESSING_TIME_LABEL}     xpath=//android.widget.TextView[@text='Processing time']
${SM_TRANSFER_FEE_LABEL}        xpath=//android.widget.TextView[@text='Transfer Fee']
${SM_INSUFFICIENT_FUNDS_ERR}    xpath=//android.widget.TextView[contains(@text,'Maximum amount is') or contains(@text,'Insufficient Funds') or contains(@text,'Insufficient funds')]
${SM_NOTES_LENGTH_ERR}          xpath=//android.widget.TextView[contains(@text,'Must not exceed') or contains(@text,'not exceed 300')]
${SM_NOTES_SPECIAL_ERR}         xpath=//android.widget.TextView[contains(@text,'Special characters are not allowed')]
${SM_LIMIT_EXCEEDED_ERR}        xpath=//android.widget.TextView[contains(@text,'exceeds the allowed limit') or contains(@text,'exceeded')]

# -------------------------------------------------------
# LOCATORS — Confirmation Screen
# -------------------------------------------------------
${SM_CONFIRMATION_SCREEN}       xpath=//android.widget.TextView[@text='Confirmation']
${SM_TRANSFER_AMOUNT_LABEL}     xpath=//android.widget.TextView[@text='Transfer Amount']
${SM_CONFIRM_BTN}               xpath=//*[@text='Confirm']

# -------------------------------------------------------
# LOCATORS — OTP Verification Screen
# -------------------------------------------------------
${SM_OTP_SCREEN}                xpath=//android.widget.TextView[@text='OTP Verification']
${SM_OTP_CLOSE_BTN}             xpath=//*[@text='X' or @text='×']
${SM_OTP_RESEND_LINK}           xpath=//android.widget.TextView[@text='Resend code']
${SM_OTP_RESEND_TIMER}          xpath=//android.widget.TextView[contains(@text,'Resend available in')]
${SM_OTP_INVALID_ERR}           xpath=//android.widget.TextView[contains(@text,'Invalid or has expired') or contains(@text,'invalid or has expired')]
${SM_OTP_MAX_ATTEMPTS_MSG}      xpath=//android.widget.TextView[contains(@text,'maximum number of attempts') or contains(@text,'Verification Failed')]

# -------------------------------------------------------
# LOCATORS — Transfer Result Screen
# -------------------------------------------------------
${SM_TRANSFER_RESULT_SCREEN}    xpath=//android.widget.TextView[@text='Transfer Result']
${SM_TRANSFER_SUCCESSFUL}       xpath=//android.widget.TextView[@text='Transfer Successful!']
${SM_TRANSFER_PENDING}          xpath=//android.widget.TextView[@text='Transfer Pending']
${SM_DONE_BTN}                  xpath=//*[@text='Done']
${SM_REFRESH_PAGE_BTN}          xpath=//*[@text='Refresh page']
${SM_BACK_TO_HOME_BTN}          xpath=//*[contains(@text,'Back to Home') or contains(@text,'back to home') or @text='Back to home']
${SM_TX_RESULT_FROM_LABEL}      xpath=//android.widget.TextView[@text='From']
${SM_TX_RESULT_TO_LABEL}        xpath=//android.widget.TextView[@text='To']
${SM_TX_RESULT_FEE_LABEL}       xpath=//android.widget.TextView[@text='Transfer Fee']
${SM_TX_RESULT_REF_NO_LABEL}    xpath=//android.widget.TextView[contains(@text,'Reference') and not(contains(@text,'Instapay'))]
${SM_TX_RESULT_INSTAPAY_LABEL}  xpath=//android.widget.TextView[@text='Instapay Reference Number']
${SM_TX_RESULT_NOTES_LABEL}     xpath=//android.widget.TextView[@text='Notes']

# -------------------------------------------------------
# LOCATORS — Transfer Failed Screen
# -------------------------------------------------------
${SM_TRANSFER_FAILED_SCREEN}    xpath=//android.widget.TextView[contains(@text,'Transfer Failed') or contains(@text,'Transaction Failed')]
${SM_ACCT_NOT_FOUND_ERR}        xpath=//android.widget.TextView[contains(@text,"doesn't exist") or contains(@text,'does not exist')]
${SM_ACCT_INVALID_STATUS_ERR}   xpath=//android.widget.TextView[contains(@text,'invalid status')]
${SM_SEND_BLOCKED_ERR}          xpath=//android.widget.TextView[contains(@text,'currently unavailable') or contains(@text,'try again in')]

# -------------------------------------------------------
# SHARED
# -------------------------------------------------------
${SM_OK_BTN}                    xpath=//*[@text='OK' or @text='Ok']
${SM_BACK_ARROW}                xpath=//android.widget.ImageButton[@content-desc='Navigate up' or @content-desc='Back']
${SM_HOME_TAB}                  xpath=//android.widget.TextView[@text='Home']
${SM_HISTORY_TAB}               xpath=//android.widget.TextView[@text='History']
${SM_PROFILE_TAB}               xpath=//android.widget.TextView[@text='Profile']
${SM_SESSION_TIMEOUT}           xpath=//android.widget.TextView[contains(@text,'session') or contains(@text,'Session')]
${SM_SWITCH_ACCT_BTN}           xpath=//*[@text='Switch Acct']
${SM_MY_ACCOUNTS_MODAL}         xpath=//android.widget.TextView[@text='My Accounts' or contains(@text,'My Accounts')]
# NOTE: My QR / QR Code locators are intentionally excluded — QR feature not yet implemented
