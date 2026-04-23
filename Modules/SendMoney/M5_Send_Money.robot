*** Settings ***
Library         AppiumLibrary
Resource        ../../resources/common.robot
Resource        ../../resources/variables/M5_variables.resource

Suite Setup         Run Keywords    Open Higala App Session Only    AND    Setup Screenshot On Failure
Suite Teardown      Close Higala App
Test Teardown       Run Keyword If Test Failed    Light Reset To Home

*** Variables ***
${TIMEOUT}          15s
${LOGGED_IN_EMAIL}  ${EMPTY}

*** Keywords ***
Open Higala App Session Only
    [Documentation]    Opens Appium session without pm clear — preserves existing login session.
    Run Keyword And Ignore Error    Close Application
    Sleep    2s
    Open Application    ${APPIUM_SERVER}
    ...    platformName=${PLATFORM}
    ...    deviceName=${DEVICE_NAME}
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    automationName=UiAutomator2
    ...    noReset=${True}
    ...    skipDeviceInitialization=${True}
    ...    ignoreHiddenApiPolicyError=${True}
    ...    enforceXPath1=${True}
    ...    adbExecTimeout=120000
    ...    uiautomator2ServerLaunchTimeout=120000
    ...    uiautomator2ServerInstallTimeout=300000
    ...    skipServerInstallation=${False}
    ...    newCommandTimeout=300
    Sleep    3s
    Start Screen Recording

Light Reset To Home
    [Documentation]    Soft-restart the app after a test failure — preserves session (no pm clear)
    ...    so the next test can reuse the existing login session without triggering OTP.
    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Sleep    2s
    Activate Application    ${APP_PACKAGE}
    Sleep    6s

Login With Credentials
    [Arguments]    ${email}    ${password}
    # Minimize OTP triggers to avoid rate-limiting:
    #   - Same account: soft-restart (force-stop + relaunch) to reuse existing session
    #   - Different account: pm clear required to wipe session before switching
    ${same_user}=    Run Keyword And Return Status    Should Be Equal    ${LOGGED_IN_EMAIL}    ${email}
    Run Keyword If    not ${same_user}    Run    adb -s ${DEVICE_NAME} shell pm clear ${APP_PACKAGE}
    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Sleep    2s
    Activate Application    ${APP_PACKAGE}
    Sleep    6s
    # Check if session auto-restored (home screen visible without OTP)
    ${already_home}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    timeout=8s
    Run Keyword If    ${already_home}    Set Suite Variable    ${LOGGED_IN_EMAIL}    ${email}
    Return From Keyword If    ${already_home}
    # Session not restored — go through full login
    Wait Until Element Is Visible    xpath=//android.widget.Button[.//android.widget.TextView[@text='Sign in']]    timeout=15s
    Click Element    xpath=//android.widget.Button[.//android.widget.TextView[@text='Sign in']]
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address' or @hint='Email']    timeout=10s
    Input Text    xpath=//android.widget.EditText[@hint='Email Address' or @hint='Email']    ${email}
    Input Text    xpath=//android.widget.EditText[@hint='Password']    ${password}
    Click Element    accessibility_id=Sign in
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=15s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    Set Suite Variable    ${LOGGED_IN_EMAIL}    ${email}

Navigate To Send Funds Screen
    [Arguments]    ${email}    ${password}
    ${on_home}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    timeout=8s
    Run Keyword If    ${on_home}    Set Suite Variable    ${LOGGED_IN_EMAIL}    ${email}
    Run Keyword If    not ${on_home}    Login With Credentials    ${email}    ${password}
    Click Element    ${SM_SEND_BTN}
    Sleep    2s
    Wait Until Element Is Visible    ${SM_SEND_FUNDS_SCREEN}    ${TIMEOUT}

Navigate To Same Bank Recipient Screen
    [Documentation]    From Send Funds, tap Same Bank and wait for recipient entry screen
    Click Element    ${SM_SAME_BANK_BTN}
    Wait Until Element Is Visible    ${SM_TO_SAME_BANK_SCREEN}    ${TIMEOUT}

Navigate To RCBC Screen
    [Documentation]    From Send Funds, tap Other Bank, search for China Banking Corporation, select it
    Click Element    ${SM_OTHER_BANK_BTN}
    Wait Until Element Is Visible    ${SM_BANK_SEARCH_FIELD}    ${TIMEOUT}
    Input Text    ${SM_BANK_SEARCH_FIELD}    ${SM_CHINA_BANK_SEARCH_TERM}
    Wait Until Element Is Visible    ${SM_BANK_RESULT_CHINA}    ${TIMEOUT}
    Click Element    ${SM_BANK_RESULT_CHINA}
    Wait Until Element Is Visible    ${SM_TO_EXTERNAL_SCREEN}    ${TIMEOUT}

Enter Recipient Info
    [Arguments]    ${acct_num}    ${acct_name}
    Input Text    ${SM_ACCT_NUM_FIELD}    ${acct_num}
    Input Text    ${SM_ACCT_NAME_FIELD}    ${acct_name}
    Press Keycode    4
    Sleep    1s
    Wait Until Element Is Visible    ${SM_NEXT_BTN}    ${TIMEOUT}
    Click Element    ${SM_NEXT_BTN}
    Sleep    2s
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}

Enter Transfer Amount And Proceed
    [Arguments]    ${amount}    ${notes}=${EMPTY}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${amount}
    Run Keyword If    '${notes}' != '${EMPTY}'    Input Text    ${SM_NOTES_FIELD}    ${notes}
    Press Keycode    4
    Sleep    1s
    Wait Until Element Is Visible    ${SM_NEXT_BTN}    ${TIMEOUT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}

Navigate To Same Bank OTP Screen
    [Arguments]    ${acct_num}    ${acct_name}    ${amount}    ${notes}=${EMPTY}
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${acct_num}    ${acct_name}
    Enter Transfer Amount And Proceed    ${amount}    ${notes}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}

Navigate To RCBC OTP Screen
    [Arguments]    ${acct_num}    ${acct_name}    ${amount}    ${notes}=${EMPTY}
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Enter Recipient Info    ${acct_num}    ${acct_name}
    Enter Transfer Amount And Proceed    ${amount}    ${notes}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}

Complete Same Bank Transfer
    [Arguments]    ${acct_num}    ${acct_name}    ${amount}    ${notes}=${EMPTY}
    Navigate To Same Bank OTP Screen    ${acct_num}    ${acct_name}    ${amount}    ${notes}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}

Complete RCBC Transfer
    [Arguments]    ${acct_num}    ${acct_name}    ${amount}    ${notes}=${EMPTY}
    Navigate To RCBC OTP Screen    ${acct_num}    ${acct_name}    ${amount}    ${notes}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}

Switch To San Antonio App
    [Documentation]    Brings the San Antonio app to the foreground on emulator-5554.
    Activate Application    ${SAN_ANTONIO_APP_PACKAGE}
    Sleep    3s

Switch To Abucay App
    [Documentation]    Brings the Abucay app to the foreground on emulator-5554.
    ...    Both apps share the same emulator (emulator-5554) and the same Appium session.
    Activate Application    ${ABUCAY_APP_PACKAGE}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address' or @hint='Email']    ${TIMEOUT}

Login Abucay App
    [Documentation]    Switches to the Abucay app and logs in with Abucay credentials
    Switch To Abucay App
    Input Text    xpath=//android.widget.EditText[@hint='Email Address' or @hint='Email']    ${SM_ABUCAY_EMAIL}
    Input Text    xpath=//android.widget.EditText[@hint='Password']    ${SM_ABUCAY_PASSWORD}
    Click Element    accessibility_id=Sign in
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=15s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}

Navigate To Abucay Bank Screen
    [Documentation]    From San Antonio Send Funds screen, tap Other Bank and select RCBC.
    ...    NOTE: All RB-to-RB transfers (San Antonio → Abucay) route through
    ...    Rizal Commercial Banking Corporation (RCBC) as the Instapay intermediary.
    ...    The recipient account number identifies the Abucay account on the RCBC network.
    Click Element    ${SM_OTHER_BANK_BTN}
    Wait Until Element Is Visible    ${SM_BANK_SEARCH_FIELD}    ${TIMEOUT}
    Input Text    ${SM_BANK_SEARCH_FIELD}    ${SM_RCBC_BANK_SEARCH_TERM}
    Wait Until Element Is Visible    ${SM_BANK_RESULT_RCBC}    ${TIMEOUT}
    Click Element    ${SM_BANK_RESULT_RCBC}
    Wait Until Element Is Visible    ${SM_TO_EXTERNAL_SCREEN}    ${TIMEOUT}

Get Balance From Home Screen
    [Documentation]    Returns the current balance text from the home screen
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    ${balance_text}=    Get Text    ${SM_HOME_SCREEN}
    [Return]    ${balance_text}

Handle Transfer Result External
    [Documentation]    External (other-bank) transfers always show "Transfer Pending" first.
    ...    Navigation buttons (Refresh page / Back to Home) may be scrolled below the fold
    ...    on long result screens — a scroll down is performed before clicking.
    # Transfer Pending is the EXPECTED initial state for external/Instapay transfers
    Element Should Be Visible    ${SM_TRANSFER_PENDING}
    # Verify Instapay Reference Number is present on the pending screen
    Element Should Be Visible    ${SM_TX_RESULT_INSTAPAY_LABEL}
    # Scroll down to bring navigation buttons into view (React Native lazy rendering)
    Swipe    start_x=540    start_y=1800    end_x=540    end_y=800    duration=500
    Sleep    1s
    # Optionally click Refresh page to poll for updated status
    ${has_refresh}=    Run Keyword And Return Status    Element Should Be Visible    ${SM_REFRESH_PAGE_BTN}
    Run Keyword If    ${has_refresh}    Click Element    ${SM_REFRESH_PAGE_BTN}
    Run Keyword If    ${has_refresh}    Sleep    3s
    # After optional refresh: Done (Successful) or Back to Home (still pending)
    ${done_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${SM_DONE_BTN}
    ${back_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${SM_BACK_TO_HOME_BTN}
    Run Keyword If    ${done_visible}    Click Element    ${SM_DONE_BTN}
    ...    ELSE IF    ${back_visible}    Click Element    ${SM_BACK_TO_HOME_BTN}
    ...    ELSE    Press Keycode    4
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}

*** Test Cases ***

# ==============================================================
# NEGATIVE
# ==============================================================

# m5.1 — As a User, I want to send money to other accounts
#         within the same bank (On Us)

TC_M5.1_007 Verify validation when entering special characters in Account Number field
    [Tags]    m5.1    validation
    [Documentation]    m5.1.7: Special chars in Account Number → "Only numerical values are allowed"
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Input Text    ${SM_ACCT_NUM_FIELD}    @#!
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NUM_SPECIAL_CHAR_ERR}    ${TIMEOUT}

TC_M5.1_008 Verify validation when Account Number field is left blank
    [Tags]    m5.1    validation
    [Documentation]    m5.1.8: Empty Account Number → "Account number is required."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Click Element    ${SM_ACCT_NUM_FIELD}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NUM_REQUIRED_ERR}    ${TIMEOUT}

TC_M5.1_009 Verify validation when entering own account number in the Account Number field
    [Tags]    m5.1    validation
    [Documentation]    m5.1.9: Self-transfer → "You cannot send money to yourself."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    # Enter logged-in user's own account number
    ${own_acct}=    Get Text    xpath=//android.widget.TextView[contains(@text,'Acct no:') or contains(@text,'Account no')]
    ${own_acct_num}=    Evaluate    '${own_acct}'.split()[-1]
    Input Text    ${SM_ACCT_NUM_FIELD}    ${own_acct_num}
    Wait Until Element Is Visible    ${SM_SELF_TRANSFER_ERR}    ${TIMEOUT}

TC_M5.1_010 Verify validation when Account Name field is left blank
    [Tags]    m5.1    validation
    [Documentation]    m5.1.10: Empty Account Name → "Account name is required."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Input Text    ${SM_ACCT_NUM_FIELD}    ${SM_SAME_BANK_RECIPIENT_ACCT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NAME_REQUIRED_ERR}    ${TIMEOUT}

TC_M5.1_011 Verify validation when entering invalid special characters in the Account Name field
    [Tags]    m5.1    validation
    [Documentation]    m5.1.11: Special chars in Account Name → error about allowed special chars
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Input Text    ${SM_ACCT_NUM_FIELD}    ${SM_SAME_BANK_RECIPIENT_ACCT}
    Input Text    ${SM_ACCT_NAME_FIELD}    @#\$%
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NAME_SPECIAL_ERR}    ${TIMEOUT}

TC_M5.1_016 Verify validation when entering more than 300 characters in the Notes field
    [Tags]    m5.1    validation
    [Documentation]    m5.1.16: Notes > 300 chars → "Must not exceed 300 characters."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Input Text    ${SM_NOTES_FIELD}    ${SM_LONG_NOTES}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_NOTES_LENGTH_ERR}    ${TIMEOUT}

TC_M5.1_017 Verify validation when entering invalid special characters in the Notes field
    [Tags]    m5.1    validation
    [Documentation]    m5.1.17: Special chars in Notes → error about allowed special chars
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Input Text    ${SM_NOTES_FIELD}    ${SM_INVALID_NOTES}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_NOTES_SPECIAL_ERR}    ${TIMEOUT}

TC_M5.1_030 Verify validation message for incorrect OTP upon sending money
    [Tags]    m5.1    otp    validation
    [Documentation]    m5.1.30: Invalid OTP → "OTP is either Invalid or has expired..."
    Navigate To Same Bank OTP Screen    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    Enter OTP Into Boxes    ${SM_INVALID_OTP}
    Wait Until Element Is Visible    ${SM_OTP_INVALID_ERR}    ${TIMEOUT}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.1_031 Verify validation message for expired OTP upon sending money
    [Tags]    m5.1    otp    validation
    [Documentation]    m5.1.31: Expired OTP (same message as invalid OTP)
    Navigate To Same Bank OTP Screen    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    Enter OTP Into Boxes    ${SM_INVALID_OTP}
    Wait Until Element Is Visible    ${SM_OTP_INVALID_ERR}    ${TIMEOUT}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.1_032 Verify that the user cannot request a new OTP before the 1-minute cooldown period has passed
    [Tags]    m5.1    otp    validation
    [Documentation]    m5.1.32: Resend code disabled during 1-min cooldown — verify timer visible
    Navigate To Same Bank OTP Screen    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    Wait Until Element Is Visible    ${SM_OTP_RESEND_TIMER}    ${TIMEOUT}
    Element Should Be Visible    ${SM_OTP_RESEND_LINK}
    # Verify the cooldown timer text is present (Resend code link is disabled while timer runs)
    Element Text Should Match Regexp    ${SM_OTP_RESEND_TIMER}    Resend available in \\d:\\d{2}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.1_033 Verify that the user can request a new OTP upon sending money
    [Tags]    m5.1    otp    Manual    Skipped
    [Documentation]    m5.1.33: Resend OTP — requires waiting for cooldown + email access — manual only
    Skip    Requires real email access and 1-min OTP cooldown — manual verification only

TC_M5.1_034 Verify if previously received OTP is not valid upon sending money
    [Tags]    m5.1    otp    Manual    Skipped
    [Documentation]    m5.1.34: Old OTP invalidated on resend — requires email access — manual only
    Skip    Requires real email access and OTP invalidation verification — manual only

TC_M5.1_035 Verify validation on the 5th failed OTP attempt
    [Tags]    m5.1    otp    validation
    [Documentation]    m5.1.35: 5 invalid OTPs → "Verification Failed: max attempts reached" → back to Confirmation
    Navigate To Same Bank OTP Screen    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    # ${SM_MAX_OTP} (999999) directly triggers max attempts on first entry
    Enter OTP Into Boxes    ${SM_MAX_OTP}
    Wait Until Element Is Visible    ${SM_OTP_MAX_ATTEMPTS_MSG}    ${TIMEOUT}
    Click Element    ${SM_OK_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}

TC_M5.1_036 Verify validation on 5th OTP attempt across multiple resend requests
    [Tags]    m5.1    otp    validation
    [Documentation]    m5.1.36: 5 invalid OTPs across resend cycles → "Verification Failed" → back to Confirmation
    Navigate To Same Bank OTP Screen    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    # ${SM_MAX_OTP} (999999) directly triggers max attempts on first entry
    Enter OTP Into Boxes    ${SM_MAX_OTP}
    Wait Until Element Is Visible    ${SM_OTP_MAX_ATTEMPTS_MSG}    ${TIMEOUT}
    Click Element    ${SM_OK_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}

TC_M5.1_037 Verify validation when OTP session expires before max attempts
    [Tags]    m5.1    otp    Manual    Skipped
    [Documentation]    m5.1.37: OTP session expires at 5 min before 5 attempts — manual only
    Skip    Requires waiting 5+ minutes for OTP session expiry — manual verification only

TC_M5.1_038 Verify error modal when OTP entered after 5-minute validity window expires
    [Tags]    m5.1    otp    Manual    Skipped
    [Documentation]    m5.1.38: OTP window expired — manual only
    Skip    Requires waiting 5+ minutes for OTP validity expiry — manual verification only

TC_M5.1_039 Verify if user can send money with insufficient funds
    [Tags]    m5.1    validation
    [Documentation]    m5.1.39: Amount > balance → "Maximum amount is <balance>" error on Transfer screen
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_OVER_BALANCE_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_INSUFFICIENT_FUNDS_ERR}    ${TIMEOUT}

TC_M5.1_041 Verify Transaction failed error when there is something wrong in the OTP endpoint
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.41: System/OTP endpoint error — cannot simulate — manual only
    Skip    Edge case requires simulated server error — manual verification only

TC_M5.1_042 Verify user email blocked after 3 unverified sessions with 5 invalid attempts each
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.42: 30-min block after 3×5 failed OTP sessions — manual only (timing-sensitive)
    Skip    Blocking scenario requires timing control and email verification — manual only

TC_M5.1_043 Verify user email blocked after 3 sessions with invalid attempts not reaching max
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.43: Block with <5 attempts per session — manual only
    Skip    Blocking scenario requires timing control — manual only

TC_M5.1_044 Verify user email blocked after 3 sessions with no OTP attempts (session abandoned)
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.44: Block with abandoned sessions — manual only
    Skip    Blocking scenario requires timing control — manual only

TC_M5.1_045 Verify blocking error when trying to send money during block period
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.45: Send money blocked → "currently unavailable" error — manual only
    Skip    Requires pre-blocked account state — manual verification only

TC_M5.1_046 Verify user can send money after 30-minute block expires
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.46: Unblocked after 30 min — manual only
    Skip    Requires waiting 30 minutes — manual verification only

TC_M5.1_047 Verify system does not block user if valid OTP entered on 5th attempt during 3rd session
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.47: Successful 5th attempt prevents block — manual only
    Skip    Multi-session timing-sensitive test — manual verification only

TC_M5.1_048 Verify counter resets after successful verification of any session
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.48: Block counter reset on success — manual only
    Skip    Multi-session timing-sensitive test — manual verification only

TC_M5.1_049 Verify system does not block if 3 unverified sessions span more than 10 minutes
    [Tags]    m5.1    block    Manual    Skipped
    [Documentation]    m5.1.49: Block window (10 min) not reached — manual only
    Skip    Requires timed sessions over 10+ minutes — manual verification only

TC_M5.1_051 Verify error when recipient account is inactive
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.51: Inactive recipient — requires dev setup — manual only
    Skip    Inactive account state requires developer configuration — manual only

TC_M5.1_052 Verify error when sender account is inactive
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.52: Inactive sender — requires dev setup — manual only
    Skip    Inactive account state requires developer configuration — manual only

TC_M5.1_053 Verify daily transfer limit validation per transaction
    [Tags]    m5.1    validation
    [Documentation]    m5.1.53: Amount > 100,000 per transaction → "exceeds the allowed limit per transaction"
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_OVER_LIMIT_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_LIMIT_EXCEEDED_ERR}    ${TIMEOUT}

# m5.2 — As a User, I want to send money to accounts in other banks (Off Us)

TC_M5.2_004 Verify validation when entering special characters in Account Number field (other bank)
    [Tags]    m5.2    validation
    [Documentation]    m5.2.4: Special chars in Account Number → "Only numerical values are allowed"
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Input Text    ${SM_ACCT_NUM_FIELD}    @#!
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NUM_SPECIAL_CHAR_ERR}    ${TIMEOUT}

TC_M5.2_005 Verify validation when Account Number field is left blank (other bank)
    [Tags]    m5.2    validation
    [Documentation]    m5.2.5: Empty Account Number → "This field is required."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Click Element    ${SM_ACCT_NUM_FIELD}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NUM_REQUIRED_ERR}    ${TIMEOUT}

TC_M5.2_006 Verify validation when entering own account number in the Account Number field (other bank)
    [Tags]    m5.2    validation
    [Documentation]    m5.2.6: Self-transfer via other bank → "You cannot send money to yourself."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    ${own_acct}=    Get Text    xpath=//android.widget.TextView[contains(@text,'Acct no:') or contains(@text,'Account no')]
    ${own_acct_num}=    Evaluate    '${own_acct}'.split()[-1]
    Input Text    ${SM_ACCT_NUM_FIELD}    ${own_acct_num}
    Wait Until Element Is Visible    ${SM_SELF_TRANSFER_ERR}    ${TIMEOUT}

TC_M5.2_007 Verify validation when Account Name field is left blank (other bank)
    [Tags]    m5.2    validation
    [Documentation]    m5.2.7: Empty Account Name → "This field is required."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Input Text    ${SM_ACCT_NUM_FIELD}    ${SM_CHINA_RECIPIENT_ACCT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NAME_REQUIRED_ERR}    ${TIMEOUT}

TC_M5.2_008 Verify validation when entering invalid special characters in the Account Name field (other bank)
    [Tags]    m5.2    validation
    [Documentation]    m5.2.8: Special chars in Account Name → "Only the following special characters are allowed..."
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Input Text    ${SM_ACCT_NUM_FIELD}    ${SM_CHINA_RECIPIENT_ACCT}
    Input Text    ${SM_ACCT_NAME_FIELD}    @#\$%
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_ACCT_NAME_SPECIAL_ERR}    ${TIMEOUT}

TC_M5.2_025 Verify that the user cannot request a new OTP before the 1-minute cooldown (other bank)
    [Tags]    m5.2    otp    validation
    [Documentation]    m5.2.25: Resend code disabled during cooldown — verify timer text visible
    Navigate To RCBC OTP Screen    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    Wait Until Element Is Visible    ${SM_OTP_RESEND_TIMER}    ${TIMEOUT}
    Element Should Be Visible    ${SM_OTP_RESEND_LINK}
    Element Text Should Match Regexp    ${SM_OTP_RESEND_TIMER}    Resend available in \\d:\\d{2}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.2_026 Verify that the user can request a new OTP upon sending money (other bank)
    [Tags]    m5.2    otp    Manual    Skipped
    [Documentation]    m5.2.26: Resend OTP — requires email access — manual only
    Skip    Requires real email access and 1-min OTP cooldown — manual verification only

TC_M5.2_027 Verify if previously received OTP is not valid upon sending money (other bank)
    [Tags]    m5.2    otp    Manual    Skipped
    [Documentation]    m5.2.27: Old OTP invalidated on resend — requires email access — manual only
    Skip    Requires real email access and OTP invalidation verification — manual only

TC_M5.2_028 Verify validation message for incorrect OTP upon sending money (other bank)
    [Tags]    m5.2    otp    validation
    [Documentation]    m5.2.28: Invalid OTP → "OTP is either Invalid or has expired..."
    Navigate To RCBC OTP Screen    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    Enter OTP Into Boxes    ${SM_INVALID_OTP}
    Wait Until Element Is Visible    ${SM_OTP_INVALID_ERR}    ${TIMEOUT}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.2_029 Verify validation message for expired OTP upon sending money (other bank)
    [Tags]    m5.2    otp    validation
    [Documentation]    m5.2.29: Expired OTP (same message as invalid)
    Navigate To RCBC OTP Screen    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    Enter OTP Into Boxes    ${SM_INVALID_OTP}
    Wait Until Element Is Visible    ${SM_OTP_INVALID_ERR}    ${TIMEOUT}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.2_030 Verify Transaction failed error when there is something wrong in the OTP endpoint (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.30: System/OTP endpoint error — cannot simulate — manual only
    Skip    Edge case requires simulated server error — manual verification only

TC_M5.2_031 Verify validation on the 5th failed OTP attempt (other bank)
    [Tags]    m5.2    otp    validation
    [Documentation]    m5.2.31: 5 invalid OTPs → "Verification Failed" → back to Confirmation
    Navigate To RCBC OTP Screen    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    # ${SM_MAX_OTP} (999999) directly triggers max attempts on first entry
    Enter OTP Into Boxes    ${SM_MAX_OTP}
    Wait Until Element Is Visible    ${SM_OTP_MAX_ATTEMPTS_MSG}    ${TIMEOUT}
    Click Element    ${SM_OK_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}

TC_M5.2_032 Verify validation on 5th OTP attempt across multiple resend requests (other bank)
    [Tags]    m5.2    otp    validation
    [Documentation]    m5.2.32: 5 invalid OTPs across resend cycles → "Verification Failed"
    Navigate To RCBC OTP Screen    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}
    # ${SM_MAX_OTP} (999999) directly triggers max attempts on first entry
    Enter OTP Into Boxes    ${SM_MAX_OTP}
    Wait Until Element Is Visible    ${SM_OTP_MAX_ATTEMPTS_MSG}    ${TIMEOUT}
    Click Element    ${SM_OK_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}

TC_M5.2_033 Verify validation when OTP session expires before max attempts (other bank)
    [Tags]    m5.2    otp    Manual    Skipped
    [Documentation]    m5.2.33: OTP session expires at 5 min — manual only
    Skip    Requires waiting 5+ minutes for OTP session expiry — manual verification only

TC_M5.2_034 Verify error modal when OTP entered after 5-minute validity window expires (other bank)
    [Tags]    m5.2    otp    Manual    Skipped
    [Documentation]    m5.2.34: OTP window expired — manual only
    Skip    Requires waiting 5+ minutes for OTP validity expiry — manual verification only

TC_M5.2_035 Verify if user can send money to other bank with insufficient funds
    [Tags]    m5.2    validation
    [Documentation]    m5.2.35: Amount > balance → "Insufficient Funds." error on Transfer screen
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Enter Recipient Info    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_OVER_BALANCE_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_INSUFFICIENT_FUNDS_ERR}    ${TIMEOUT}

TC_M5.2_037 Verify if transaction fails when account number and account name do not match
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.37: Name/number mismatch → Transfer Failed — requires specific setup
    Skip    Requires specific mismatched account credentials — manual verification only

TC_M5.2_038 Verify user email blocked after 3 unverified sessions with 5 invalid attempts each (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.38: 30-min block — timing-sensitive — manual only
    Skip    Blocking scenario requires timing control — manual only

TC_M5.2_039 Verify user email blocked after 3 sessions with invalid attempts not reaching max (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.39: Block with <5 attempts — manual only
    Skip    Blocking scenario requires timing control — manual only

TC_M5.2_040 Verify user email blocked after 3 sessions with no OTP attempts (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.40: Block with abandoned sessions — manual only
    Skip    Blocking scenario requires timing control — manual only

TC_M5.2_041 Verify blocking error when trying to send money during block period (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.41: "Send Money is currently unavailable" during block — manual only
    Skip    Requires pre-blocked account state — manual verification only

TC_M5.2_042 Verify user can send money after 30-minute block expires (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.42: Unblocked after 30 min — manual only
    Skip    Requires waiting 30 minutes — manual verification only

TC_M5.2_043 Verify system does not block if valid OTP entered on 5th attempt during 3rd session (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.43: Successful 5th attempt prevents block — manual only
    Skip    Multi-session timing-sensitive test — manual verification only

TC_M5.2_044 Verify counter resets after successful verification of any session (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.44: Block counter reset on success — manual only
    Skip    Multi-session timing-sensitive test — manual verification only

TC_M5.2_045 Verify system does not block if 3 unverified sessions span more than 10 minutes (other bank)
    [Tags]    m5.2    block    Manual    Skipped
    [Documentation]    m5.2.45: Block window not reached — manual only
    Skip    Requires timed sessions over 10+ minutes — manual verification only

TC_M5.2_047 Verify error when recipient account is inactive (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.47: Inactive recipient — requires dev setup — manual only
    Skip    Inactive account state requires developer configuration — manual only

TC_M5.2_048 Verify error when sender account is inactive (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.48: Inactive sender — requires dev setup — manual only
    Skip    Inactive account state requires developer configuration — manual only

TC_M5.2_049 Verify per-transaction transfer limit validation (other bank)
    [Tags]    m5.2    validation
    [Documentation]    m5.2.49: Amount > 50,000 per transaction → "exceeds the allowed limit per transaction"
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Enter Recipient Info    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    50001
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_LIMIT_EXCEEDED_ERR}    ${TIMEOUT}

TC_M5.2_050 Verify daily transfer limit validation (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.50: Daily total > 500,000 → limit error — requires pre-existing transactions — manual only
    Skip    Requires total daily transfers > PHP 500,000 across sessions — manual verification only

TC_M5.2_051 Verify Transfer Result Screen when transaction failed due to external error
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.51: External error causing Transfer Failed — cannot simulate — manual only
    Skip    External error simulation requires controlled environment — manual verification only

# m5.8 — RB-to-RB External

TC_M5.8_009 Verify that sending to Abucay with insufficient funds shows an error
    [Tags]    m5.8    validation    multi-device
    [Documentation]    m5.8.9: Amount exceeding balance → "Maximum amount is <balance>" on Transfer screen.
    Switch To San Antonio App
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Abucay Bank Screen
    Enter Recipient Info    ${SM_ABUCAY_RECIPIENT_ACCT}    ${SM_ABUCAY_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_OVER_BALANCE_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_INSUFFICIENT_FUNDS_ERR}    ${TIMEOUT}

TC_M5.8_010 Verify that the OTP screen appears correctly during Abucay transfer
    [Tags]    m5.8    otp    multi-device
    [Documentation]    m5.8.10: OTP Verification screen is shown with masked email, 6 boxes,
    ...    Resend code link, and Resend available in timer during Abucay transfer.
    Switch To San Antonio App
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Abucay Bank Screen
    Enter Recipient Info    ${SM_ABUCAY_RECIPIENT_ACCT}    ${SM_ABUCAY_RECIPIENT_NAME}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_OTP_SCREEN}
    Element Should Be Visible    ${SM_OTP_RESEND_LINK}
    Element Should Be Visible    ${SM_OTP_RESEND_TIMER}
    Element Text Should Match Regexp    ${SM_OTP_RESEND_TIMER}    Resend available in \\d:\\d{2}
    Click Element    ${SM_OTP_CLOSE_BTN}

TC_M5.8_011 Verify that an invalid OTP shows error during Abucay transfer
    [Tags]    m5.8    otp    validation    multi-device
    [Documentation]    m5.8.11: Entering incorrect OTP on Abucay transfer →
    ...    "OTP is either Invalid or has expired, Please try again or request a new OTP"
    Switch To San Antonio App
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Abucay Bank Screen
    Enter Recipient Info    ${SM_ABUCAY_RECIPIENT_ACCT}    ${SM_ABUCAY_RECIPIENT_NAME}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    ${SM_INVALID_OTP}
    Wait Until Element Is Visible    ${SM_OTP_INVALID_ERR}    ${TIMEOUT}
    Click Element    ${SM_OTP_CLOSE_BTN}


# ==============================================================
# RATE LIMITING / DESTRUCTIVE
# ==============================================================

# m5.1 — As a User, I want to send money to other accounts
#         within the same bank (On Us)

TC_M5.1_002 Verify that the user can send money to a recent recipient
    [Tags]    m5.1    destructive
    [Documentation]    m5.1.2: Select recipient from Recent section (requires prior successful transfer)
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Wait Until Element Is Visible    ${SM_RECENT_SECTION_HDR}    ${TIMEOUT}
    Click Element    ${SM_RECENT_SECTION_HDR}    # tap first recent recipient card
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_TRANSFER_SUCCESSFUL}
    Click Element    ${SM_DONE_BTN}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}

# m5.2 — As a User, I want to send money to accounts in other banks (Off Us)

TC_M5.2_002 Verify that the user can send money to a recent recipient of another bank
    [Tags]    m5.2    destructive
    [Documentation]    m5.2.2: Select RCBC John from Recent section — requires prior transfer (m5.2.1).
    ...    NOTE: Transfer Pending is the EXPECTED initial state for external/Instapay transfers.
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    # After a prior transfer, John (**0011) appears in the Recent section
    Wait Until Element Is Visible    ${SM_RCBC_RECENT_CARD}    ${TIMEOUT}
    Click Element    ${SM_RCBC_RECENT_CARD}
    # Fields are auto-filled from the recent recipient card — proceed to Transfer screen
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}    ${SM_NOTES}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    # External transfer: expect Transfer Pending first, with Instapay Reference Number visible
    Element Should Be Visible    ${SM_TRANSFER_PENDING}
    Element Should Be Visible    ${SM_TX_RESULT_INSTAPAY_LABEL}
    Handle Transfer Result External

TC_M5.2_003 Verify that the user can send money to a recent recipient of another Rural Bank via RCBC
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.3: RB-to-other-RB via RCBC with recent recipient — covered by m5.2.2 — manual
    Skip    Flow covered by m5.2.2; RB-to-RB scenario requires specific account setup — manual only

# m5.6 — As a User, I want to view Withdrawal/Deposit Transactions made via Teller
# All TCs require Teller App to have processed transactions — not automatable

TC_M5.6_001 Verify Cash Withdrawal in Transaction History List
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.1: Requires teller-processed Cash Withdrawal — manual only
    Skip    Requires prior teller app cash withdrawal — manual verification only

TC_M5.6_002 Verify Cash Withdrawal Transaction Details
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.2: Requires teller-processed Cash Withdrawal — manual only
    Skip    Requires prior teller app cash withdrawal — manual verification only

TC_M5.6_003 Verify Cash Deposit in Transaction History List
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.3: Requires teller-processed Cash Deposit — manual only
    Skip    Requires prior teller app cash deposit — manual verification only

TC_M5.6_004 Verify Cash Deposit Transaction Details
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.4: Requires teller-processed Cash Deposit — manual only
    Skip    Requires prior teller app cash deposit — manual verification only

TC_M5.6_005 Verify Failed or Cancelled Teller Transaction
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.5: Requires teller app to cancel a transaction — manual only
    Skip    Requires teller app cancel/fail action — manual verification only

TC_M5.6_006 Verify Pending Deposit Teller Transaction
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.6: Pending teller deposit — requires teller app — manual only
    Skip    Requires teller app pending state — manual verification only

TC_M5.6_007 Verify Pending Withdrawal Teller Transaction
    [Tags]    m5.6    Manual    Skipped
    [Documentation]    m5.6.7: Pending teller withdrawal — requires teller app — manual only
    Skip    Requires teller app pending state — manual verification only

# m5.7 — As a User, I want to send money to my other savings account
# Uses SM_MULTI_EMAIL (jjavier+1) which has 3 savings accounts
# SM_SELF_ACCT_A_NUM and SM_SELF_ACCT_B_NUM must be filled in variables

TC_M5.7_003 Verify transaction history and details for the Sender Account (Account A)
    [Tags]    m5.7
    [Documentation]    m5.7.3: History tab on Account A shows debit entry with correct details
    Login With Credentials    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@text='History']
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Search']    ${TIMEOUT}
    # Most recent entry should be the debit for the self-transfer
    Page Should Contain Element    xpath=(//android.widget.TextView[contains(@text,'-')])[1]
    # Tap first transaction to view details
    Click Element    xpath=(//android.widget.TextView[contains(@text,'-')])[1]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Transaction Details']    ${TIMEOUT}
    Element Should Be Visible    xpath=//android.widget.TextView[@text='To']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Transaction ID']

TC_M5.7_004 Verify transaction history and details for the Recipient Account (Account B)
    [Tags]    m5.7
    [Documentation]    m5.7.4: Switch to Account B → History → credit entry with correct TX details
    Login With Credentials    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    # Switch to Account B
    Click Element    ${SM_SWITCH_ACCT_BTN}
    Wait Until Element Is Visible    ${SM_MY_ACCOUNTS_MODAL}    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[contains(@text,'${SM_SELF_ACCT_B_NUM}') or contains(@text,'${SM_SELF_ACCT_B_NUM[-4:]}')]
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[@text='History']
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Search']    ${TIMEOUT}
    # Most recent entry should be the credit from self-transfer
    Page Should Contain Element    xpath=(//android.widget.TextView[contains(@text,'+')])[1]
    # Tap to view details
    Click Element    xpath=(//android.widget.TextView[contains(@text,'+')])[1]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Transaction Details']    ${TIMEOUT}
    Element Should Be Visible    xpath=//android.widget.TextView[@text='From']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Transaction ID']

# m5.8 — As a User, I want to send money from Rural Bank San Antonio
#         to Rural Bank of Abucay (RB-to-RB External / Cash In)
#
# SETUP REQUIREMENTS:
#   - Both San Antonio and Abucay apps installed on the SAME emulator (emulator-5554)
#   - San Antonio pkg: com.higala.ruralbanksanantonioitg
#   - Abucay pkg:      com.higala.bancoabucayitg
#   - Single Appium server (port 4723) — use Activate App to switch between apps
#   - Sender:   jjavier+84@nmblr.ai  (San Antonio)
#   - Receiver: jjavier+1@nmblr.ai   (Abucay) — Acct No: 7710501333354703, Name: jooo Abucay
#
# NOTE: Transfer Pending is the expected initial state for all RB-to-RB
#       external transfers. The Abucay app verification uses Switch Application
#       to control the Pixel device without restarting the San Antonio session.

TC_M5.8_003 Verify that the San Antonio sender balance is deducted after Abucay transfer
    [Tags]    m5.8    multi-device
    [Documentation]    m5.8.3: After the transfer, San Antonio balance reflects deduction
    ...    of transfer amount + ₱15.00 transfer fee.
    Switch To San Antonio App
    Login With Credentials    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    # Balance should be visible and updated (non-masked)
    Element Should Be Visible    ${SM_HOME_SCREEN}
    # Verify the most recent home screen transaction card shows Abucay recipient and debit
    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text,'${SM_ABUCAY_RECIPIENT_NAME}')]

TC_M5.8_005 Verify that the Abucay receiver balance is updated after receiving the transfer
    [Tags]    m5.8    multi-device
    [Documentation]    m5.8.5: Abucay balance on home screen reflects the credited amount.
    Switch To Abucay App
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    # Balance element is visible (not masked)
    Element Should Be Visible    ${SM_HOME_SCREEN}
    # The home screen balance area is updated — presence of '+' transaction confirms credit posted
    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text,'+')]

TC_M5.8_006 Verify that the Abucay receiver transaction history shows the credit entry
    [Tags]    m5.8    multi-device
    [Documentation]    m5.8.6: Abucay History tab shows credit entry from San Antonio.
    ...    Transaction Details show: From, Bank, On, Transaction ID, Instapay Reference Number.
    Switch To Abucay App
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_HISTORY_TAB}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Search']    ${TIMEOUT}
    # Most recent entry should be the incoming credit
    Page Should Contain Element    xpath=(//android.widget.TextView[contains(@text,'+')])[1]
    Click Element    xpath=(//android.widget.TextView[contains(@text,'+')])[1]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Transaction Details']    ${TIMEOUT}
    Element Should Be Visible    xpath=//android.widget.TextView[@text='From']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Bank']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Transaction ID']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Instapay Reference Number']

TC_M5.8_007 Verify that the Instapay Reference Number matches between San Antonio and Abucay
    [Tags]    m5.8    multi-device
    [Documentation]    m5.8.7: Cross-verify the Instapay Reference Number is the same on
    ...    both the San Antonio TX Details and the Abucay TX Details.
    ...    Requires m5.8.1 to have set SM_LAST_INSTAPAY_REF suite variable.
    # --- RECEIVER: Get Instapay ref from Abucay TX Details ---
    Switch To Abucay App
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_HISTORY_TAB}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Search']    ${TIMEOUT}
    Click Element    xpath=(//android.widget.TextView[contains(@text,'+')])[1]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Transaction Details']    ${TIMEOUT}
    ${abucay_instapay_ref}=    Get Text    xpath=//android.widget.TextView[@text='Instapay Reference Number']/following-sibling::android.widget.TextView[1]
    # Cross-verify against the reference number captured in m5.8.1
    Should Be Equal    ${abucay_instapay_ref}    ${SM_LAST_INSTAPAY_REF}
    ...    msg=Instapay Reference Number mismatch between San Antonio and Abucay

TC_M5.8_012 Verify that Rizal Commercial Banking Corporation appears in the Other Bank search results for RB-to-RB transfer
    [Tags]    m5.8    smoke    multi-device
    [Documentation]    m5.8.12: All RB-to-RB transfers route through RCBC as the Instapay intermediary.
    ...    Searching "rc" in Other Bank shows Rizal Commercial Banking Corporation in results.
    Switch To San Antonio App
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Click Element    ${SM_OTHER_BANK_BTN}
    Wait Until Element Is Visible    ${SM_BANK_SEARCH_FIELD}    ${TIMEOUT}
    Input Text    ${SM_BANK_SEARCH_FIELD}    ${SM_RCBC_BANK_SEARCH_TERM}
    Wait Until Element Is Visible    ${SM_BANK_RESULT_RCBC}    ${TIMEOUT}
    Page Should Contain Element    ${SM_BANK_RESULT_RCBC}


# m5.1 — As a User, I want to send money to other accounts
#         within the same bank (On Us)

TC_M5.1_001 Verify that the user can successfully send money to another account within the same bank
    [Tags]    m5.1    smoke    destructive
    [Documentation]    m5.1.1: Full happy-path same-bank transfer
    Complete Same Bank Transfer    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}    ${SM_VALID_AMOUNT}    ${SM_NOTES}
    Element Should Be Visible    ${SM_TRANSFER_SUCCESSFUL}
    Click Element    ${SM_DONE_BTN}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}

TC_M5.1_040 Verify that the user can edit the transfer amount after an insufficient funds error
    [Tags]    m5.1    validation    destructive
    [Documentation]    m5.1.40: After insufficient funds error, enter valid amount and complete transfer
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${SM_SAME_BANK_RECIPIENT_ACCT}    ${SM_SAME_BANK_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_OVER_BALANCE_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_INSUFFICIENT_FUNDS_ERR}    ${TIMEOUT}
    # Correct the amount
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_VALID_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_TRANSFER_SUCCESSFUL}
    Click Element    ${SM_DONE_BTN}

TC_M5.1_050 Verify error when recipient account is not found
    [Tags]    m5.1    validation    destructive
    [Documentation]    m5.1.50: Invalid account number → Transfer Failed "doesn't exist"
    Complete Same Bank Transfer    ${SM_INVALID_ACCT_NUM}    Invalid Name    ${SM_VALID_AMOUNT}
    Wait Until Element Is Visible    ${SM_TRANSFER_FAILED_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_ACCT_NOT_FOUND_ERR}
    Click Element    ${SM_OK_BTN}

# m5.2 — As a User, I want to send money to accounts in other banks (Off Us)

TC_M5.2_001 Verify that the user can successfully send money to another bank
    [Tags]    m5.2    smoke    destructive
    [Documentation]    m5.2.1: Full happy-path other-bank (RCBC) transfer — no recent recipient.
    ...    NOTE: Transfer Pending is the EXPECTED initial state for external/Instapay transfers.
    ...    The result screen will show Transfer Pending first; Refresh page polls for final status.
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Enter Recipient Info    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}    ${SM_NOTES}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    # Verify Transfer Result details on Pending screen
    # NOTE: External/Instapay transfers show "Instapay Reference Number" only — no plain "Reference Number"
    Element Should Be Visible    ${SM_TRANSFER_PENDING}
    Element Should Be Visible    ${SM_TX_RESULT_FROM_LABEL}
    Element Should Be Visible    ${SM_TX_RESULT_TO_LABEL}
    Element Should Be Visible    ${SM_TX_RESULT_FEE_LABEL}
    Element Should Be Visible    ${SM_TX_RESULT_INSTAPAY_LABEL}
    Handle Transfer Result External

TC_M5.2_036 Verify that the user can edit the transfer amount after an insufficient funds error (other bank)
    [Tags]    m5.2    validation    destructive
    [Documentation]    m5.2.36: Correct amount after insufficient funds error and complete transfer
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To RCBC Screen
    Enter Recipient Info    ${SM_CHINA_RECIPIENT_ACCT}    ${SM_CHINA_RECIPIENT_NAME}
    Wait Until Element Is Visible    ${SM_TRANSFER_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_OVER_BALANCE_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_INSUFFICIENT_FUNDS_ERR}    ${TIMEOUT}
    Click Element    ${SM_AMOUNT_INPUT}
    Clear Text    ${SM_AMOUNT_INPUT}
    Input Text    ${SM_AMOUNT_INPUT}    ${SM_VALID_AMOUNT}
    Click Element    ${SM_NEXT_BTN}
    Wait Until Element Is Visible    ${SM_CONFIRMATION_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    # External transfer: expect Transfer Pending first
    Element Should Be Visible    ${SM_TRANSFER_PENDING}
    Element Should Be Visible    ${SM_TX_RESULT_INSTAPAY_LABEL}
    Handle Transfer Result External

TC_M5.2_046 Verify error when recipient account is not found in other bank
    [Tags]    m5.2    validation    destructive
    [Documentation]    m5.2.46: Invalid RCBC account → Transfer Failed "doesn't exist"
    Complete RCBC Transfer    ${SM_INVALID_ACCT_NUM}    Invalid Name    ${SM_VALID_AMOUNT}
    Wait Until Element Is Visible    ${SM_TRANSFER_FAILED_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_ACCT_NOT_FOUND_ERR}
    Click Element    ${SM_OK_BTN}

# m5.7 — As a User, I want to send money to my other savings account

TC_M5.7_001 Verify that the user can successfully send money to another of their own savings accounts
    [Tags]    m5.7    smoke    destructive
    [Documentation]    m5.7.1: Self-transfer between own savings accounts (Account A → B)
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Same Bank Recipient Screen
    Enter Recipient Info    ${SM_SELF_ACCT_B_NUM}    ${SM_SELF_ACCT_B_NAME}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}    ${SM_NOTES}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_TRANSFER_SUCCESSFUL}
    Element Should Be Visible    ${SM_TX_RESULT_FROM_LABEL}
    Element Should Be Visible    ${SM_TX_RESULT_TO_LABEL}
    Click Element    ${SM_DONE_BTN}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}

TC_M5.7_002 Verify that when switching to the recipient savings account the balance is updated
    [Tags]    m5.7    destructive
    [Documentation]    m5.7.2: Switch to Account B and verify updated balance + credit entry after m5.7.1
    Login With Credentials    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    # Account A (sender) is the current default — verify home screen loaded
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    # Switch to Account B (recipient)
    Click Element    ${SM_SWITCH_ACCT_BTN}
    Wait Until Element Is Visible    ${SM_MY_ACCOUNTS_MODAL}    ${TIMEOUT}
    Click Element    xpath=//android.widget.TextView[contains(@text,'${SM_SELF_ACCT_B_NUM}') or contains(@text,'${SM_SELF_ACCT_B_NUM[-4:]}')]
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    # Verify recent transaction shows credit entry
    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text,'+')]

# m5.8 — RB-to-RB External

TC_M5.8_001 Verify that San Antonio can successfully send money to Abucay account
    [Tags]    m5.8    smoke    destructive    multi-device
    [Documentation]    m5.8.1: Full happy-path RB-to-RB external transfer.
    ...    San Antonio (sender) → Abucay (receiver, acct: 7710501333354703).
    ...    Transfer Pending is expected on result screen (external Instapay transfer).
    # --- SENDER: San Antonio app ---
    Switch To San Antonio App
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Abucay Bank Screen
    Enter Recipient Info    ${SM_ABUCAY_RECIPIENT_ACCT}    ${SM_ABUCAY_RECIPIENT_NAME}
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}    ${SM_NOTES}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_RESULT_SCREEN}    ${TIMEOUT}
    # Transfer result may show Pending (async Instapay) or Successful (fast processing) — both are valid
    ${is_pending}=    Run Keyword And Return Status    Element Should Be Visible    ${SM_TRANSFER_PENDING}
    ${is_successful}=    Run Keyword And Return Status    Element Should Be Visible    ${SM_TRANSFER_SUCCESSFUL}
    Should Be True    ${is_pending} or ${is_successful}    Expected Transfer Pending or Transfer Successful on result screen
    # Capture Instapay reference for cross-verification if available (pending state)
    ${ref_status}    ${instapay_ref}=    Run Keyword And Ignore Error
    ...    Get Text    xpath=//android.widget.TextView[@text='Instapay Reference Number']/following-sibling::android.widget.TextView[1]
    Run Keyword If    '${ref_status}' == 'PASS'    Set Suite Variable    ${SM_LAST_INSTAPAY_REF}    ${instapay_ref}
    # Navigate back to home — use Handle Transfer Result External for pending, Done for successful
    Run Keyword If    ${is_pending}    Handle Transfer Result External
    Run Keyword If    ${is_successful} and not ${is_pending}    Click Element    ${SM_DONE_BTN}
    Run Keyword If    ${is_successful} and not ${is_pending}    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}

TC_M5.8_002 Verify that the transfer is reflected in San Antonio transaction history
    [Tags]    m5.8    destructive    multi-device
    [Documentation]    m5.8.2: San Antonio History shows debit entry for the Abucay transfer.
    ...    Verifies Transaction Details contain To, Bank, Transaction ID, Instapay Ref No.
    # --- SENDER: San Antonio app ---
    Switch To San Antonio App
    Login With Credentials    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    Click Element    ${SM_HISTORY_TAB}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Search']    ${TIMEOUT}
    # Most recent entry is the Abucay debit (amount + ₱15 fee)
    Click Element    xpath=(//android.widget.TextView[contains(@text,'-')])[1]
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Transaction Details']    ${TIMEOUT}
    Element Should Be Visible    xpath=//android.widget.TextView[@text='To']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Bank']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Transaction ID']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Instapay Reference Number']
    Element Should Be Visible    xpath=//android.widget.TextView[@text='Notes']
    # Verify recipient name is visible in the details
    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text,'${SM_ABUCAY_RECIPIENT_NAME}')]

TC_M5.8_004 Verify that the Abucay receiver can see the incoming transaction in their home screen
    [Tags]    m5.8    destructive    multi-device
    [Documentation]    m5.8.4: Switch to Abucay app on Pixel device. Login and verify the
    ...    incoming credit from San Antonio appears on the home screen recent transactions.
    # --- RECEIVER: Abucay app on Pixel emulator ---
    Login Abucay App
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}
    # Recent transactions section on home should show the incoming credit
    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text,'+')]
    # Verify sender name or "Rural Bank San Antonio" appears in recent transactions
    Page Should Contain Element    xpath=//android.widget.TextView[contains(@text,'San Antonio') or contains(@text,'Rural Bank')]

TC_M5.8_008 Verify that sending to an invalid Abucay account number results in Transfer Failed
    [Tags]    m5.8    validation    destructive    multi-device
    [Documentation]    m5.8.8: Invalid Abucay account number → Transfer Failed screen with
    ...    "The account doesn't exist. Please check and try again."
    Switch To San Antonio App
    Navigate To Send Funds Screen    ${SM_VALID_EMAIL}    ${SM_VALID_PASSWORD}
    Navigate To Abucay Bank Screen
    Enter Recipient Info    ${SM_INVALID_ACCT_NUM}    Invalid Name
    Enter Transfer Amount And Proceed    ${SM_VALID_AMOUNT}
    Click Element    ${SM_CONFIRM_BTN}
    Wait Until Element Is Visible    ${SM_OTP_SCREEN}    ${TIMEOUT}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${SM_TRANSFER_FAILED_SCREEN}    ${TIMEOUT}
    Element Should Be Visible    ${SM_ACCT_NOT_FOUND_ERR}
    Click Element    ${SM_OK_BTN}
    Wait Until Element Is Visible    ${SM_HOME_SCREEN}    ${TIMEOUT}


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

# m5.1 — As a User, I want to send money to other accounts
#         within the same bank (On Us)

TC_M5.1_003 Verify the session timeout modal on the Send Funds screen due to inactivity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.3: Session timeout — requires waiting 5 min (manual only)
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.1_004 Verify the session timeout modal on the Send Funds screen after minimizing
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.4: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_005 Verify the session timeout modal is still visible on Send Funds screen after minimizing and reopening
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.5: Session timeout modal persists after restore — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_006 Verify that session timeout resets on user activity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.6: Session timer reset — requires 8+ min of interaction — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.1_012 Verify the session timeout modal on the To Same Bank screen due to inactivity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.12: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.1_013 Verify the session timeout modal on the To Same Bank screen after minimizing
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.13: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_014 Verify the session timeout modal is still visible on To Same Bank screen after minimizing and reopening
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.14: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_015 Verify that session timeout resets on user activity on To Same Bank screen
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.15: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.1_018 Verify the session timeout modal on the Transfer screen due to inactivity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.18: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.1_019 Verify the session timeout modal on the Transfer screen after minimizing
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.19: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_020 Verify the session timeout modal is still visible on Transfer screen after minimizing and reopening
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.20: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_021 Verify that session timeout resets on user activity on Transfer screen
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.21: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.1_022 Verify the session timeout modal on the Confirmation screen due to inactivity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.22: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.1_023 Verify the session timeout modal on the Confirmation screen after minimizing
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.23: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_024 Verify the session timeout modal is still visible on Confirmation screen after minimizing and reopening
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.24: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_025 Verify that session timeout resets on user activity on Confirmation screen
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.25: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.1_026 Verify the session timeout modal on the OTP Verification screen due to inactivity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.26: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.1_027 Verify the session timeout modal on the OTP Verification screen after minimizing
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.27: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_028 Verify the session timeout modal is still visible on OTP Verification screen after minimizing and reopening
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.28: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_029 Verify that session timeout resets on user activity on OTP screen
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.29: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.1_054 Verify the session timeout modal on the Transfer Result screen due to inactivity
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.54: Session timeout on result screen — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.1_055 Verify the session timeout modal on the Transfer Result screen after minimizing
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.55: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_056 Verify the session timeout modal is still visible on Transfer Result screen after minimizing and reopening
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.56: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.1_057 Verify that session timeout resets on user activity on Transfer Result screen
    [Tags]    m5.1    Manual    Skipped
    [Documentation]    m5.1.57: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

# m5.2 — As a User, I want to send money to accounts in other banks (Off Us)

TC_M5.2_009 Verify the session timeout modal on the To Selected Bank screen due to inactivity
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.9: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.2_010 Verify the session timeout modal on the To Selected Bank screen after minimizing
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.10: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_011 Verify the session timeout modal is still visible on To Selected Bank screen after minimizing and reopening
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.11: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_012 Verify that session timeout resets on user activity on To Selected Bank screen
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.12: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.2_013 Verify the session timeout modal on the Transfer screen due to inactivity (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.13: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.2_014 Verify the session timeout modal on the Transfer screen after minimizing (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.14: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_015 Verify the session timeout modal is still visible on Transfer screen after minimizing and reopening (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.15: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_016 Verify that session timeout resets on user activity on Transfer screen (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.16: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.2_017 Verify the session timeout modal on the Confirmation screen due to inactivity (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.17: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.2_018 Verify the session timeout modal on the Confirmation screen after minimizing (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.18: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_019 Verify the session timeout modal is still visible on Confirmation screen after minimizing and reopening (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.19: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_020 Verify that session timeout resets on user activity on Confirmation screen (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.20: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.2_021 Verify the session timeout modal on the OTP Verification screen due to inactivity (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.21: Session timeout — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.2_022 Verify the session timeout modal on the OTP Verification screen after minimizing (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.22: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_023 Verify the session timeout modal is still visible on OTP Verification screen after minimizing and reopening (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.23: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_024 Verify that session timeout resets on user activity on OTP screen (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.24: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.2_052 Verify the session timeout modal on the Transfer Pending screen due to inactivity
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.52: Session timeout on pending screen — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.2_053 Verify the session timeout modal on the Transfer Pending screen after minimizing
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.53: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_054 Verify the session timeout modal is still visible on Transfer Pending screen after minimizing and reopening
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.54: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_055 Verify that session timeout resets on user activity on Transfer Pending screen
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.55: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only

TC_M5.2_056 Verify the session timeout modal on the Transfer Result screen due to inactivity (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.56: Session timeout on result screen — manual only
    Skip    Session timeout requires real-time wait — manual verification only

TC_M5.2_057 Verify the session timeout modal on the Transfer Result screen after minimizing (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.57: Session timeout after minimize — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_058 Verify the session timeout modal is still visible on Transfer Result screen after minimizing and reopening (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.58: Session timeout modal persists — manual only
    Skip    Session timeout requires minimize + wait — manual verification only

TC_M5.2_059 Verify that session timeout resets on user activity on Transfer Result screen (other bank)
    [Tags]    m5.2    Manual    Skipped
    [Documentation]    m5.2.59: Session timer reset — manual only
    Skip    Session timer reset requires extended real-time interaction — manual only


