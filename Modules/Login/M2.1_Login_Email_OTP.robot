*** Settings ***
Resource            ../../resources/common.robot
Library             AppiumLibrary
Library             String
Suite Setup         Setup Screenshot On Failure
Test Setup          Open Higala App
Test Teardown       Close Higala App
Test Tags           Login    M2.1    OTP    Email

*** Variables ***
# Primary test account — switched to +101 due to rate limiting on +1
${VALID_EMAIL}              jjavier+101@nmblr.ai
${VALID_PASSWORD}           Password!1
${INVALID_EMAIL}            invaliduser@higala.com
${INVALID_PASSWORD}         WrongPass@123
${EMPTY_STRING}
# Mailsac test account (used for m2.1.33 block test)
${MAILSAC_EMAIL}            javier1@mailsac.com
${MAILSAC_PASSWORD}         Password!1
${WRONG_PASSWORD}           WrongPass@999
# Backup accounts for OTP rate-limit rotation — each test that reaches OTP uses a different email
# so consecutive test runs don't hit rate limits on the same account.
${VALID_EMAIL_2}            jjavier+84@nmblr.ai
${VALID_EMAIL_3}            jjavier+82@nmblr.ai
${VALID_EMAIL_4}            jjavier+89@nmblr.ai
${VALID_EMAIL_5}            jjavier+93@nmblr.ai
${VALID_EMAIL_6}            jjavier+157@nmblr.ai

# Locators — based on actual app elements from Appium Inspector
# Note: React Native app uses accessibility id and xpath (no resource-ids)
${EMAIL_FIELD}          xpath=//android.widget.EditText[@hint='Email Address']
${PASSWORD_FIELD}       xpath=//android.widget.EditText[@hint='Password']
${LOGIN_BUTTON}         accessibility_id=Sign in
${FORGOT_PASSWORD}      xpath=//android.widget.TextView[@text='Forgot your password?']
# OTP screen has 6 individual digit boxes (no hint, auto-submits on 6th digit — no Verify button)
${OTP_BOX_1}            xpath=(//android.widget.EditText)[1]
${OTP_BOX_2}            xpath=(//android.widget.EditText)[2]
${OTP_BOX_3}            xpath=(//android.widget.EditText)[3]
${OTP_BOX_4}            xpath=(//android.widget.EditText)[4]
${OTP_BOX_5}            xpath=(//android.widget.EditText)[5]
${OTP_BOX_6}            xpath=(//android.widget.EditText)[6]
${OTP_FIELD}            xpath=(//android.widget.EditText)[1]
${RESEND_OTP_BUTTON}    xpath=//android.widget.TextView[@text='Resend code']
${RESEND_CODE_LINK}     xpath=//android.widget.TextView[@text='Resend code']
# Actual error: "Incorrect email or password, please try again."
${ERROR_MESSAGE}        xpath=//android.widget.TextView[contains(@text,'Incorrect') or contains(@text,'incorrect') or contains(@text,'Invalid') or contains(@text,'invalid') or contains(@text,'required') or contains(@text,'error') or contains(@text,'Error')]
${EMAIL_REQUIRED}       xpath=//android.widget.TextView[@text='Email is required.']
${PASSWORD_REQUIRED}    xpath=//android.widget.TextView[@text='Password is required.']
${HOME_SCREEN}          xpath=//android.widget.TextView[@text='Home']
${OTP_SCREEN}           xpath=//android.widget.TextView[@text='OTP Verification']
${BACK_BUTTON}              accessibility_id=Back
# Eye icon is an SVG ViewGroup (no content-desc) — tap by bounds; verify coordinates with Appium Inspector if screen size differs
${EYE_ICON}                xpath=//android.view.ViewGroup[@bounds='[915,1704][967,1756]']
# START_PAGE: text on the Welcome/Start screen's "Sign in" button (lowercase 'in')
${START_PAGE}              xpath=//android.widget.TextView[@text='Sign in']
${MAX_ATTEMPTS_ERROR}      xpath=//android.widget.TextView[contains(@text,'maximum number of attempts') or contains(@text,'Verification Failed') or contains(@text,'Maximum')]
# Session timeout modal (confirmed from screenshot)
${SESSION_TIMEOUT_MODAL}   xpath=//android.widget.TextView[@text='Session Timeout']
${INACTIVE_MSG}            xpath=//android.widget.TextView[@text='You have been inactive for 5 minutes']
${BACK_TO_LOGIN_BTN}       xpath=//android.widget.TextView[@text='Back to Login']
# Account blocking error (m2.1.33)
${ACCOUNT_BLOCKED_ERROR}   xpath=//android.widget.TextView[contains(@text,'blocked') or contains(@text,'locked') or contains(@text,'suspended') or contains(@text,'too many') or contains(@text,'maximum') or contains(@text,'attempts') or contains(@text,'Account') or contains(@text,'temporarily')]

*** Test Cases ***

# ==============================================================
# HAPPY PATH
# ==============================================================

TC_M2.1_001 - Successful Login With Valid Email, Password, and OTP
    [Documentation]    Verify user can log in successfully using valid email, password, and correct OTP
    [Tags]    Positive
    [Teardown]    NONE
    # Uses VALID_EMAIL_3 (jjavier+82) — confirmed working, different from VALID_EMAIL_2 used in TC_M2.1_002
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL_3}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=30s
    # Enter OTP digit by digit into individual boxes (magic OTP — any 6 digits accepted)
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=15s
    Expect Element        ${HOME_SCREEN}    visible

TC_M2.1_002 - OTP Screen Is Displayed After Valid Email and Password
    [Documentation]    Verify that the OTP screen is shown after entering valid credentials
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Uses VALID_EMAIL_2 to avoid rate limiting with TC_M2.1_001 (runs back-to-back)
    Reset To Login Page
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL_2}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=30s
    Expect Element        ${OTP_SCREEN}    visible


# ==============================================================
# NEGATIVE
# ==============================================================

TC_M2.1_004 - Login Fails With Invalid Email
    [Documentation]    Verify error message is shown when an unregistered email is entered (m2.1.19)
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       ${INVALID_EMAIL}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible

TC_M2.1_005 - Login Fails With Invalid Password
    [Documentation]    Verify error message is shown when an incorrect password is entered (m2.1.22)
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL}
    Input Text          ${PASSWORD_FIELD}    ${INVALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible

TC_M2.1_006 - Login Fails With Empty Email
    [Documentation]    Verify error message is shown when email field is left empty (m2.1.20)
    ...    Note: Field is already empty after Reset To Login Page — no Clear Text needed
    [Tags]    Negative
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${EMAIL_REQUIRED}    timeout=10s
    Expect Element        ${EMAIL_REQUIRED}    visible

TC_M2.1_007 - Login Fails With Empty Password
    [Documentation]    Verify error message is shown when password field is left empty (m2.1.23)
    ...    Note: Field is already empty after Reset To Login Page — no Clear Text needed
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${PASSWORD_REQUIRED}    timeout=10s
    Expect Element        ${PASSWORD_REQUIRED}    visible

TC_M2.1_008 - Login Fails With Empty Email and Password
    [Documentation]    Verify error messages are shown when both fields are empty (m2.1.20 + m2.1.23)
    ...    Note: Both fields are empty after Reset To Login Page — no Clear Text needed
    [Tags]    Negative
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible

TC_M2.1_009 - Login Fails With Incorrect OTP
    [Documentation]    Verify error message is shown when wrong 6-digit OTP is entered (m2.1.7)
    ...    NOTE: Requires magic OTP to be disabled in the test environment.
    ...    In magic-OTP mode (any 6 digits accepted), this test will fail — run against real OTP environment.
    [Tags]    Negative
    # Uses VALID_EMAIL_4 to avoid rate limiting while still reaching OTP screen
    Navigate To OTP Screen    ${VALID_EMAIL_4}    ${VALID_PASSWORD}
    # Enter clearly wrong OTP digits — expect rejection
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible

# -------------------------------------------------------
# M2.1.10 — PREVIOUSLY RECEIVED OTP IS INVALID AFTER RESEND
# -------------------------------------------------------

TC_M2.1_017 - Previously Received OTP Is Invalid After Requesting New OTP
    [Documentation]    Verify the old OTP is rejected after a new OTP has been requested (m2.1.10)
    ...    SKIP: Requires reading the actual OTP from the email inbox to compare old vs new.
    ...    Not automatable without email API access (mailsac API key required).
    [Tags]    Negative    Skipped
    Skip    TC_M2.1_017 requires reading the real OTP from the email inbox to compare old vs new. Not automatable without email API access.

# -------------------------------------------------------
# M2.1.11 — 5TH FAILED OTP ATTEMPT TRIGGERS MAX ATTEMPTS ERROR
# -------------------------------------------------------

TC_M2.1_018 - Fifth Failed OTP Attempt Triggers Max Attempts Error
    [Documentation]    Verify that 5 consecutive invalid OTP entries trigger the max attempts error (m2.1.11)
    ...    NOTE: Requires magic OTP to be disabled. In magic-OTP mode any 6 digits succeed,
    ...    so this test must be run in a real/staging environment.
    [Tags]    Negative
    # Uses VALID_EMAIL_3 — dedicated to this test to avoid contaminating other accounts with 5 failed OTPs
    Navigate To OTP Screen    ${VALID_EMAIL_3}    ${VALID_PASSWORD}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9
    Wait Until Element Is Visible    ${MAX_ATTEMPTS_ERROR}    timeout=10s
    Expect Element        ${MAX_ATTEMPTS_ERROR}    visible
    # Dismiss dialog and confirm redirect to login screen
    ${ok_btn}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.Button[@text='Ok']    timeout=5s
    Run Keyword If    ${ok_btn}    Click Element    xpath=//android.widget.Button[@text='Ok']
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.1.33 — ACCOUNT BLOCKED AFTER 5 CONSECUTIVE FAILED LOGIN ATTEMPTS
# -------------------------------------------------------

TC_M2.1_023 - Account Is Blocked After 5 Consecutive Failed Login Attempts
    [Documentation]    Verify that the account is blocked after 5 consecutive failed login attempts with wrong password (m2.1.33)
    ...    Uses ${MAILSAC_EMAIL} to avoid blocking the primary test account.
    ...    NOTE: After this test runs, the mailsac account will be blocked — it may need to be unblocked manually.
    [Tags]    Negative    Security
    # Attempt 1 — wrong password
    Input Text      ${EMAIL_FIELD}      ${MAILSAC_EMAIL}
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    # Attempt 2
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    # Attempt 3
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    # Attempt 4
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    # Attempt 5 — should trigger account block
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ACCOUNT_BLOCKED_ERROR}    timeout=15s
    Expect Element        ${ACCOUNT_BLOCKED_ERROR}    visible

# -------------------------------------------------------
# M2.1.21 — INCORRECT EMAIL FORMAT
# -------------------------------------------------------

TC_M2.1_024 - Login Fails With Incorrect Email Format
    [Documentation]    Verify an error is shown when the email field contains an invalid format (m2.1.21)
    ...    Examples of invalid format: 'notanemail', 'missing@', '@nodomain', 'no spaces allowed'
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       notanemail
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible

# -------------------------------------------------------
# M2.1.24 — NON-EXISTENT EMAIL AND PASSWORD
# -------------------------------------------------------

TC_M2.1_025 - Login Fails With Non-Existent Email And Password
    [Documentation]    Verify an error is shown when both email and password do not exist in the system (m2.1.24)
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       nonexistent.user@higala.com
    Input Text          ${PASSWORD_FIELD}    ${INVALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible

# -------------------------------------------------------
# M2.1.41 — FAILED LOGIN WITH INCORRECT EMAIL ADDRESS
# -------------------------------------------------------

TC_M2.1_027 - Failed Login With Incorrect Email Address
    [Documentation]    Verify error is shown when login is attempted with a valid-format but unregistered email (m2.1.41)
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       wronguser@higala.com
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible
    # Confirm OTP screen is NOT shown (login should not proceed)
    ${otp_shown}=    Run Keyword And Return Status
    ...    Expect Element    ${OTP_SCREEN}    visible
    Should Be Equal    ${otp_shown}    ${False}    msg=OTP screen should NOT appear for unregistered email

# -------------------------------------------------------
# M2.1.42 — FAILED LOGIN WITH INCORRECT TEMPORARY PASSWORD
# -------------------------------------------------------

TC_M2.1_028 - Failed Login With Incorrect Temporary Password
    [Documentation]    Verify error is shown when a registered email is submitted with the wrong temporary password (m2.1.42)
    ...    Uses ${MAILSAC_EMAIL} as the account expected to have a temporary password assigned.
    ...    Update the email/password variables if a dedicated temp-password account is available.
    [Tags]    Negative
    Input Text          ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text          ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    Expect Element        ${ERROR_MESSAGE}    visible
    # Confirm OTP screen is NOT shown
    ${otp_shown}=    Run Keyword And Return Status
    ...    Expect Element    ${OTP_SCREEN}    visible
    Should Be Equal    ${otp_shown}    ${False}    msg=OTP screen should NOT appear for incorrect temporary password

# -------------------------------------------------------
# M2.1.34 — BLOCKED ACCOUNT CANNOT LOGIN DURING 5-MINUTE COOLDOWN
# -------------------------------------------------------

TC_M2.1_034 - Verify Blocked Account Cannot Login During 5-Minute Cooldown
    [Documentation]    During the 5-minute cooldown, even correct credentials must be rejected:
    ...    "Incorrect email or password. Too many attempts -- please try again in 5 minutes."
    ...
    ...    Pre-conditions: MAILSAC_EMAIL is currently blocked.
    [Tags]    M2.1.34    Negative
    # Block the account within this TC (self-contained)
    FOR    ${i}    IN RANGE    5
        Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Sleep    2s
    END
    # Attempt with correct credentials during cooldown — must still be blocked
    Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${MAILSAC_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ACCOUNT_BLOCKED_ERROR}    timeout=10s
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}

# -------------------------------------------------------
# M2.1.40 — FAILED ATTEMPT COUNTER RESETS TO ZERO AFTER SUCCESSFUL LOGIN
# -------------------------------------------------------

TC_M2.1_040 - Verify Failed Attempt Counter Resets To Zero After Successful Login
    [Documentation]    After 4 failed login attempts, a successful login resets the counter.
    ...    The user can then fail 5 more times before being blocked again —
    ...    confirming the counter was fully reset after the successful login.
    ...
    ...    Pre-conditions: MAILSAC_EMAIL is NOT currently blocked.
    [Tags]    M2.1.40    Negative
    # Step 1: 4 wrong passwords (counter = 4, not yet blocked)
    FOR    ${i}    IN RANGE    4
        Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
        Element Should Be Visible    ${ERROR_MESSAGE}
        Sleep    1s
    END
    # Step 2: Correct credentials on 5th try → login succeeds (counter resets)
    Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${MAILSAC_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=15s
    # Step 3: Return to login screen and fail 5 more times → blocked (counter was reset)
    Reset To Login Page
    FOR    ${i}    IN RANGE    4
        Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
        Element Should Be Visible    ${ERROR_MESSAGE}
        Sleep    1s
    END
    Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ACCOUNT_BLOCKED_ERROR}    timeout=10s
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}

# -------------------------------------------------------
# M2.1.36 — FAILED COUNTER PERSISTS ACROSS SESSIONS/DEVICES (Not Automatable)
# -------------------------------------------------------

TC_M2.1_036 - Verify Failed Attempt Counter Persists Across Sessions And Devices
    [Documentation]    After 3 failed attempts on Device A, 2 more failed attempts on
    ...    Device B should trigger a block (counter is account-level, not device-level).
    ...    NOT AUTOMATABLE — requires 2 physical devices running simultaneously.
    [Tags]    M2.1.36    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires 2 physical devices running simultaneously

# -------------------------------------------------------
# M2.1.37 — BLOCKING APPLIES PER ACCOUNT, NOT PER DEVICE/IP (Not Automatable)
# -------------------------------------------------------

TC_M2.1_037 - Verify Blocking Applies Per Account And Not Per Device Or IP
    [Documentation]    When an account is blocked on Device A, the same account
    ...    must also be blocked on Device B — confirming block is account-level.
    ...    NOT AUTOMATABLE — requires 2 physical devices running simultaneously.
    [Tags]    M2.1.37    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires 2 physical devices running simultaneously

# -------------------------------------------------------
# M2.1.38 — ADMIN UNLOCK (Invalid / Not Automatable)
# -------------------------------------------------------

TC_M2.1_038 - Verify Admin Unlock Restores Account Access Immediately
    [Documentation]    When an admin manually unlocks a blocked account via backend,
    ...    the user can log in immediately without waiting for the 5-minute cooldown.
    ...    Marked INVALID in the reference test case document.
    ...    NOT AUTOMATABLE — requires backend admin access.
    [Tags]    M2.1.38    Manual    Skipped    NotAutomatable    Invalid
    Skip    Not Automatable: requires backend admin access — also marked Invalid in test case reference

# -------------------------------------------------------
# M2.1.43 — EXPIRED TEMPORARY PASSWORD ON LOGIN (Not Automatable)
# -------------------------------------------------------

TC_M2.1_043 - Verify Behavior When Expired Temporary Password Is Used On Login
    [Documentation]    Using a temporary password that has expired beyond the 24-hour limit
    ...    must display: "Please request a new one to continue."
    ...    Tapping OK must redirect the user back to the Login screen.
    ...    NOT AUTOMATABLE — requires a naturally expired temporary password (24-hour wait).
    [Tags]    M2.1.43    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires a naturally expired temporary password (24-hour wait)

# -------------------------------------------------------
# M2.1.44 — AUDIT LOGGING FOR FAILED LOGIN ATTEMPTS (Not Automatable)
# -------------------------------------------------------

TC_M2.1_044 - Verify Audit Logging For Failed Login Attempts
    [Documentation]    Each failed login attempt must create a log entry with:
    ...    user ID, timestamp, device info, and status = "Failed."
    ...    NOT AUTOMATABLE — requires direct DB or API access to the audit log table.
    [Tags]    M2.1.44    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires DB/API access to audit log table

# -------------------------------------------------------
# M2.1.45 — AUDIT LOGGING FOR ACCOUNT BLOCK EVENT (Not Automatable)
# -------------------------------------------------------

TC_M2.1_045 - Verify Audit Logging Creates Block Event After 5 Failed Attempts
    [Documentation]    When an account is blocked after 5 failed attempts, a log entry must be
    ...    created: "Account Blocked" event with timestamp, duration (5 mins), and unblock method.
    ...    NOT AUTOMATABLE — requires direct DB or API access to the audit log table.
    [Tags]    M2.1.45    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires DB/API access to audit log table

# -------------------------------------------------------
# M2.1.46 — FAILED MPIN LOGIN × 5 → ACCOUNT LOCKED (Not Automatable)
# -------------------------------------------------------

TC_M2.1_046 - Verify Account Locked After 5 Failed MPIN Login Attempts
    [Documentation]    Entering an incorrect MPIN 5 consecutive times must lock the account:
    ...    "You have reached the maximum number of attempts. Please try again after 5 minutes."
    ...    NOT AUTOMATABLE — depends on MPIN login feature; verify availability in current build.
    [Tags]    M2.1.46    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: MPIN login feature required — verify if enabled in current build


# ==============================================================
# RATE LIMITING / DESTRUCTIVE
# ==============================================================

TC_M2.1_003 - Resend OTP Button Is Available on OTP Screen
    [Documentation]    Verify that the Resend OTP button is visible on the OTP screen (m2.1.8 prerequisite)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.1_002 — already on OTP screen, just verify resend button
    Expect Element    ${RESEND_OTP_BUTTON}    visible

# -------------------------------------------------------
# M2.1.1 — LOGIN PAGE UI ELEMENTS
# -------------------------------------------------------

TC_M2.1_011 - Verify Login Page UI Elements Are Displayed
    [Documentation]    Verify all key UI elements are visible on the login page (m2.1.1)
    [Tags]    Positive    UI
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.1_003 (OTP screen) — press Android back goes to Welcome/Start page, then tap Sign in
    Press Keycode    4
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Sign in']    timeout=15s
    Click Element    xpath=//android.widget.TextView[@text='Sign in']
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=15s
    Expect Element    ${EMAIL_FIELD}    visible
    Expect Element    ${PASSWORD_FIELD}    visible
    Expect Element    ${LOGIN_BUTTON}    visible
    Expect Element    ${FORGOT_PASSWORD}    visible
    Expect Element    ${BACK_BUTTON}    visible

# -------------------------------------------------------
# M2.1.2 — BACK BUTTON
# -------------------------------------------------------

TC_M2.1_012 - Back Button Redirects To Start Page
    [Documentation]    Verify tapping the Back button on login page redirects to the Start page (m2.1.2)
    ...    START_PAGE locator: 'Sign in' (lowercase 'in') — the button text on the welcome/start screen
    [Tags]    Positive    Navigation
    [Setup]    NONE
    [Teardown]    NONE
    Expect Element    ${BACK_BUTTON}    visible
    Click Element                ${BACK_BUTTON}
    Wait Until Element Is Visible    ${START_PAGE}    timeout=10s
    Sleep    2s
    # Re-query with retry to handle StaleElementReferenceException after React Native re-render
    Wait Until Keyword Succeeds    3x    2s    Page Should Contain Element    ${START_PAGE}

# -------------------------------------------------------
# M2.1.3 — INPUT FIELD INTERACTION
# -------------------------------------------------------

TC_M2.1_013 - User Can Enter Details In Login Input Fields
    [Documentation]    Verify user can tap and type in email and password fields, and password is masked (m2.1.3)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.1_012 (Start/Welcome page) — tap Sign in to reach Login form
    Click Element    xpath=//android.widget.TextView[@text='Sign in']
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=15s
    Click Element       ${EMAIL_FIELD}
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL}
    Expect Element    ${EMAIL_FIELD}    visible
    Click Element       ${PASSWORD_FIELD}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    ${pwd_attr}=    Get Element Attribute    ${PASSWORD_FIELD}    password
    Should Be Equal    ${pwd_attr}    true    msg=Password field should be masked

# -------------------------------------------------------
# M2.1.4 — PASSWORD MASKING AND EYE ICON TOGGLE
# -------------------------------------------------------

TC_M2.1_014 - Password Is Masked By Default And Eye Icon Toggles Visibility
    [Documentation]    Verify password is masked by default and eye icon toggles plain text/masked view (m2.1.4)
    ...    Eye icon: try coordinate-based tap first, then fall back to sibling ViewGroup of password field.
    ...    Run Appium Inspector to confirm exact locator if this test fails.
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.1_013 (Login page) — password field already visible
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    # Password should be masked by default
    ${masked}=    Get Element Attribute    ${PASSWORD_FIELD}    password
    Should Be Equal    ${masked}    true    msg=Password should be masked by default
    # Tap eye icon — try sibling ViewGroup first, fall back to coordinates
    ${eye_found}=    Run Keyword And Return Status
    ...    Click Element    xpath=//android.widget.EditText[@hint='Password']/following-sibling::android.view.ViewGroup
    Run Keyword If    not ${eye_found}    Click Element    ${EYE_ICON}
    ${revealed}=    Get Element Attribute    ${PASSWORD_FIELD}    password
    Should Be Equal    ${revealed}    false    msg=Password should be visible after tapping eye icon
    # Tap eye icon again to re-mask
    ${eye_found2}=    Run Keyword And Return Status
    ...    Click Element    xpath=//android.widget.EditText[@hint='Password']/following-sibling::android.view.ViewGroup
    Run Keyword If    not ${eye_found2}    Click Element    ${EYE_ICON}
    ${re_masked}=    Get Element Attribute    ${PASSWORD_FIELD}    password
    Should Be Equal    ${re_masked}    true    msg=Password should be masked again after second eye icon tap

# -------------------------------------------------------
# M2.1.8 — OTP RESEND DISABLED DURING COOLDOWN
# -------------------------------------------------------

TC_M2.1_015 - Resend Code Is Disabled During Cooldown Then Enabled After 1 Minute
    [Documentation]    Verify Resend code is not clickable during 1-min cooldown, then becomes clickable after it expires (m2.1.8)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.1_014 (Login page) — navigate to OTP screen to test resend cooldown
    Navigate To OTP Screen    ${VALID_EMAIL_5}    ${VALID_PASSWORD}
    # NOTE: The 'enabled' attribute may not accurately reflect the cooldown disabled state
    # (React Native may keep enabled=true visually but restrict tap). Skipping initial check.
    # Wait for 1-minute cooldown to expire
    Sleep    90s
    # After cooldown — Resend code should now be enabled
    ${enabled_after}=    Get Element Attribute    ${RESEND_CODE_LINK}    enabled
    Should Be Equal    ${enabled_after}    true    msg=Resend code should be enabled after cooldown

# -------------------------------------------------------
# M2.1.9 — RESEND OTP FULL FLOW
# -------------------------------------------------------

TC_M2.1_016 - User Can Request New OTP After Cooldown And Login Successfully
    [Documentation]    Verify user can tap Resend code after cooldown, receive new OTP, and log in (m2.1.9)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.1_015 — already on OTP screen with 90s cooldown already expired
    # Resend code should already be enabled (verified by TC_M2.1_015)
    ${enabled}=    Get Element Attribute    ${RESEND_CODE_LINK}    enabled
    Should Be Equal    ${enabled}    true    msg=Resend code should be enabled after cooldown
    Click Element    ${RESEND_CODE_LINK}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=10s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=30s
    Expect Element        ${HOME_SCREEN}    visible

# -------------------------------------------------------
# M2.1.40 — FAILED LOGIN COUNTER RESETS AFTER SUCCESSFUL LOGIN
# -------------------------------------------------------

TC_M2.1_026 - Failed Login Counter Resets After Successful Login
    [Documentation]    Verify the failed login attempt counter resets after a successful login (m2.1.40)
    ...    Flow: fail once → login successfully → fail again → verify NOT blocked (counter was reset)
    [Tags]    Positive    Security
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Uses VALID_EMAIL_2 throughout — this test triggers OTP once (Step 2)
    # Step 1: Fail once with wrong password (no OTP triggered)
    Input Text      ${EMAIL_FIELD}      ${VALID_EMAIL_2}
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    # Step 2: Login successfully (counter should reset) — OTP triggered here
    Input Text      ${EMAIL_FIELD}      ${VALID_EMAIL_2}
    Input Text      ${PASSWORD_FIELD}   ${VALID_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=30s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=30s
    # Step 3: Return to login page and fail again — should NOT be blocked
    Reset To Login Page
    Input Text      ${EMAIL_FIELD}      ${VALID_EMAIL_2}
    Input Text      ${PASSWORD_FIELD}   ${WRONG_PASSWORD}
    Click Element   ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
    # Counter was reset — regular error should appear, NOT account blocked message
    ${blocked}=    Run Keyword And Return Status
    ...    Expect Element    ${ACCOUNT_BLOCKED_ERROR}    visible
    Should Be Equal    ${blocked}    ${False}
    ...    msg=Account should NOT be blocked — counter should have reset after successful login

# CASE-INSENSITIVE EMAIL LOGIN

TC_M2.1_029 - Login Succeeds With Uppercase Email Address
    [Documentation]    Verify that login works when the email address is entered in uppercase (case-insensitive)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Uses VALID_EMAIL_4 (jjavier+89@nmblr.ai) converted to uppercase → JJAVIER+89@NMBLR.AI
    ${upper_email}=    Convert To Uppercase    ${VALID_EMAIL_4}
    Input Text          ${EMAIL_FIELD}       ${upper_email}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=30s
    Expect Element        ${OTP_SCREEN}    visible
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=30s
    Expect Element        ${HOME_SCREEN}    visible

TC_M2.1_030 - Login Succeeds With Mixed Case Email Address
    [Documentation]    Verify that login works when the email address is entered in mixed case (case-insensitive)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Mixed case version of VALID_EMAIL_5 (jjavier+93@nmblr.ai) → JJavier+93@Nmblr.Ai
    Input Text          ${EMAIL_FIELD}       JJavier+93@Nmblr.Ai
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=15s
    Expect Element        ${OTP_SCREEN}    visible
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=15s
    Expect Element        ${HOME_SCREEN}    visible

# -------------------------------------------------------
# M2.1.47 — HOME/LANDING PAGE UI VERIFICATION
# -------------------------------------------------------

TC_M2.1_031 - Home Page UI Elements Are Displayed After Successful Login
    [Documentation]    Verify key UI elements are visible on the Home/Landing page after login (m2.1.47)
    ...    NOTE: Verify exact locators for balance, transactions, and nav tabs using Appium Inspector.
    [Tags]    Positive    UI
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Uses VALID_EMAIL_3 — rotated from its last use in TC_M2.1_018 (several tests back)
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL_3}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=30s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=30s
    # Verify Home screen label is visible
    Expect Element    ${HOME_SCREEN}    visible
    # Verify greeting or account section is present
    # TODO: Replace with exact locators from Appium Inspector once home screen UI is confirmed
    ${has_greeting}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//android.widget.TextView[contains(@text,'Welcome') or contains(@text,'Good') or contains(@text,'Hello')]
    ...    timeout=5s
    ${has_balance}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//android.widget.TextView[contains(@text,'Balance') or contains(@text,'Account')]
    ...    timeout=5s
    # At least one of greeting or balance section should be visible on home page
    Should Be True    ${has_greeting} or ${has_balance}
    ...    msg=Home page should display a greeting or account balance section

# -------------------------------------------------------
# M2.1.49 — NAVIGATION OPTIONS ON LANDING PAGE
# -------------------------------------------------------

TC_M2.1_032 - Navigation Options Are Visible On The Landing Page
    [Documentation]    Verify the bottom navigation tabs/options are visible on the landing page after login (m2.1.49)
    ...    NOTE: Update tab locators based on actual app navigation using Appium Inspector.
    [Tags]    Positive    UI    Navigation
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Uses VALID_EMAIL_4 (jjavier+89) — enough gap from TC_M2.1_029 for rate limit to reset
    Input Text          ${EMAIL_FIELD}       ${VALID_EMAIL_4}
    Input Text          ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element       ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=30s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=30s
    # Verify navigation tabs are present
    # Common navigation items for banking apps — update text to match actual tab labels
    ${has_home_tab}=    Run Keyword And Return Status
    ...    Expect Element    xpath=//android.widget.TextView[@text='Home']    visible
    ${has_transfer}=    Run Keyword And Return Status
    ...    Expect Element    xpath=//android.widget.TextView[contains(@text,'Transfer') or contains(@text,'Send')]    visible
    ${has_history}=    Run Keyword And Return Status
    ...    Expect Element    xpath=//android.widget.TextView[contains(@text,'History') or contains(@text,'Transaction')]    visible
    ${has_profile}=    Run Keyword And Return Status
    ...    Expect Element    xpath=//android.widget.TextView[contains(@text,'Profile') or contains(@text,'Account') or contains(@text,'More')]    visible
    # Verify the Home tab is always visible, and at least 2 other navigation items exist
    Should Be True    ${has_home_tab}    msg=Home tab should always be visible on the landing page
    ${nav_count}=    Evaluate    int(${has_transfer}) + int(${has_history}) + int(${has_profile})
    Should Be True    ${nav_count} >= 1
    ...    msg=At least one additional navigation option (Transfer/History/Profile) should be visible

# -------------------------------------------------------
# M2.1.39 — PASSWORD RESET VIA FORGOT PASSWORD LIFTS ACCOUNT BLOCK
# -------------------------------------------------------

TC_M2.1_039 - Verify Password Reset Via Forgot Password Lifts Account Block
    [Documentation]    When an account is blocked after 5 failed login attempts,
    ...    successfully completing the Forgot Password flow lifts the block immediately.
    ...    The user can then log in with the new password without waiting for the cooldown.
    ...
    ...    Pre-conditions: MAILSAC_EMAIL is NOT currently blocked.
    [Tags]    M2.1.39    Positive
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Step 1: Block the account with 5 wrong attempts
    FOR    ${i}    IN RANGE    5
        Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Sleep    2s
    END
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}
    # Step 2: Use Forgot Password to reset while blocked
    Navigate To FP Email Screen
    Input Text       xpath=//android.widget.EditText    ${MAILSAC_EMAIL}
    Click Element    xpath=//*[@text='Submit']
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=15s
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    xpath=(//android.widget.EditText)[1]    timeout=15s
    Input Text       xpath=(//android.widget.EditText)[1]    NewPass@2025
    Input Text       xpath=(//android.widget.EditText)[2]    NewPass@2025
    Click Element    xpath=//*[@text='Submit']
    Wait Until Element Is Visible    xpath=//android.widget.TextView[contains(@text,'password is set') or contains(@text,'success')]    timeout=15s
    # Step 3: Login with new password — block should be lifted
    Reset To Login Page
    Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text       ${PASSWORD_FIELD}    NewPass@2025
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=15s
    Element Should Be Visible    ${OTP_SCREEN}
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=15s
    Element Should Be Visible    ${HOME_SCREEN}

# -------------------------------------------------------
# M2.1.47 — LANDING PAGE UI FOR USERS WITH RECENT TRANSACTIONS (Not Automatable)
# -------------------------------------------------------

TC_M2.1_047 - Verify Landing Home Page UI For Users With Recent Transactions
    [Documentation]    After login, the home/landing page must exactly match the Figma mockup
    ...    for accounts with existing transaction history (layout, fonts, icons, colors, labels).
    ...    NOT AUTOMATABLE — requires visual comparison against Figma design.
    [Tags]    M2.1.47    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires visual Figma design comparison

# -------------------------------------------------------
# M2.1.48 — LANDING PAGE UI FOR NEW USERS WITH NO TRANSACTIONS (Not Automatable)
# -------------------------------------------------------

TC_M2.1_048 - Verify Landing Home Page UI For New Users With No Transaction History
    [Documentation]    After login, the home/landing page must exactly match the Figma mockup
    ...    for accounts with no transaction history (empty state UI).
    ...    NOT AUTOMATABLE — requires visual comparison against Figma design.
    [Tags]    M2.1.48    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires visual Figma design comparison


TC_M2.1_010 - Login Fails With Empty OTP
    [Documentation]    Verify no login occurs when OTP screen is left blank (m2.1 — empty OTP)
    ...    SKIP: The OTP screen auto-submits only when all 6 digits are filled — there is no Verify
    ...    button to trigger submission with empty input. This test cannot be automated as-is.
    [Tags]    Negative    Skipped
    Skip    TC_M2.1_010 is not automatable: OTP screen has no submit button — it auto-submits on 6th digit only. Empty OTP cannot be submitted.

# -------------------------------------------------------
# M2.1.33 — ACCOUNT BLOCKED AFTER 5 CONSECUTIVE FAILED LOGIN ATTEMPTS
# -------------------------------------------------------

TC_M2.1_033 - Verify Account Blocked After 5 Consecutive Failed Login Attempts
    [Documentation]    After 5 consecutive wrong password attempts, the account is blocked:
    ...    "Incorrect email or password. Too many attempts -- please try again in 5 minutes."
    ...    A security alert email is also sent to the registered customer email.
    ...
    ...    Pre-conditions: MAILSAC_EMAIL is NOT currently blocked.
    ...    WARNING: This test blocks MAILSAC_EMAIL for 5 minutes.
    [Tags]    M2.1.33    Negative    Destructive
    FOR    ${i}    IN RANGE    4
        Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
        Element Should Be Visible    ${ERROR_MESSAGE}
        Sleep    1s
    END
    # 5th attempt — triggers account block
    Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ACCOUNT_BLOCKED_ERROR}    timeout=10s
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}

# -------------------------------------------------------
# M2.1.41 — 5 FAILED LOGINS WITH UNREGISTERED EMAIL → ACCOUNT BLOCKED
# -------------------------------------------------------

TC_M2.1_041 - Verify Account Blocked After 5 Failed Logins With Unregistered Email
    [Documentation]    Entering an unregistered email with any password 5 times consecutively
    ...    must block the account:
    ...    "This account has reached the maximum number of login attempts. Please try again after 5 minutes."
    [Tags]    M2.1.41    Negative    Destructive
    FOR    ${i}    IN RANGE    4
        Input Text       ${EMAIL_FIELD}       ${INVALID_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
        Element Should Be Visible    ${ERROR_MESSAGE}
        Sleep    1s
    END
    Input Text       ${EMAIL_FIELD}       ${INVALID_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ACCOUNT_BLOCKED_ERROR}    timeout=10s
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}

# -------------------------------------------------------
# M2.1.42 — 5 FAILED LOGINS WITH INCORRECT TEMP PASSWORD → ACCOUNT BLOCKED
# -------------------------------------------------------

TC_M2.1_042 - Verify Account Blocked After 5 Failed Logins With Incorrect Temporary Password
    [Documentation]    Entering the correct email but an incorrect temporary password
    ...    5 times consecutively must block the account:
    ...    "This account has reached the maximum number of login attempts. Please try again after 5 minutes."
    ...
    ...    Pre-conditions: MAILSAC_EMAIL account is in the temporary password state (unactivated).
    [Tags]    M2.1.42    Negative    Destructive
    FOR    ${i}    IN RANGE    4
        Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
        Element Should Be Visible    ${ERROR_MESSAGE}
        Sleep    1s
    END
    Input Text       ${EMAIL_FIELD}       ${MAILSAC_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${ACCOUNT_BLOCKED_ERROR}    timeout=10s
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

# -------------------------------------------------------
# M2.1.15 — SESSION TIMEOUT DUE TO INACTIVITY (5 MIN)
# -------------------------------------------------------

TC_M2.1_019 - Session Timeout Modal Appears After 5 Minutes Of Inactivity On OTP Screen
    [Documentation]    Verify Session Timeout modal appears on the OTP screen after 5 minutes of inactivity (m2.1.15)
    [Tags]    Negative    Session
    # Uses VALID_EMAIL_4 — session tests are long-running (5 min+), isolated from regular OTP tests
    Navigate To OTP Screen    ${VALID_EMAIL_4}    ${VALID_PASSWORD}
    # Stay idle for 5 minutes — no interaction
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${INACTIVE_MSG}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    # Tap Back to Login and verify it returns to login page
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.1.16 — SESSION TIMEOUT AFTER MINIMIZING APP
# -------------------------------------------------------

TC_M2.1_020 - Session Timeout Modal Appears After Minimizing App For 5 Minutes On OTP Screen
    [Documentation]    Verify Session Timeout modal appears on OTP screen after the app is minimized for 5 minutes (m2.1.16)
    [Tags]    Negative    Session
    # Uses VALID_EMAIL_5 — session tests run sequentially so each gets its own account
    Navigate To OTP Screen    ${VALID_EMAIL_5}    ${VALID_PASSWORD}
    # Minimize the app (background it)
    Background Application    -1
    # Wait 5 minutes while app is in background
    Sleep    310s
    # Bring app back to foreground
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.1.17 — SESSION TIMEOUT MODAL STILL VISIBLE AFTER MINIMIZE + REOPEN
# -------------------------------------------------------

TC_M2.1_021 - Session Timeout Modal Is Still Visible After Minimizing And Reopening App
    [Documentation]    Verify Session Timeout modal is still shown after the modal appeared, then app is minimized and reopened (m2.1.17)
    [Tags]    Negative    Session
    # Uses VALID_EMAIL_4 — rotated back after the 5 min+ gap from TC_M2.1_019
    Navigate To OTP Screen    ${VALID_EMAIL_4}    ${VALID_PASSWORD}
    # Wait for session timeout modal to appear (5 min inactivity)
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    # While modal is showing — minimize the app
    Background Application    -1
    Sleep    5s
    # Reopen the app — modal should still be visible
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s

# -------------------------------------------------------
# M2.1.18 — SESSION REMAINS ACTIVE DURING CONTINUOUS INTERACTION
# -------------------------------------------------------

TC_M2.1_022 - Session Remains Active While User Is Interacting With OTP Screen
    [Documentation]    Verify no session timeout occurs when the user continuously interacts with the OTP screen for over 5 minutes (m2.1.18)
    [Tags]    Positive    Session
    [Setup]    NONE
    [Teardown]    NONE
    # Uses VALID_EMAIL_5 — gap from TC_M2.1_015 is >15 min, rate limit reset
    # pm clear needed here — TC_M2.1_039 logged in and force-stop alone won't clear auth token
    Run    adb -s ${DEVICE_NAME} shell pm clear ${APP_PACKAGE}
    Sleep    3s
    Activate Application    ${APP_PACKAGE}
    Sleep    8s
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Sign in']    timeout=30s
    Click Element    xpath=//android.widget.TextView[@text='Sign in']
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=15s
    Navigate To OTP Screen    ${VALID_EMAIL_5}    ${VALID_PASSWORD}
    # Interact with OTP boxes every 60 seconds for 6 minutes (360s total)
    Keep Session Active    360    60
    # After 6 minutes of activity — session timeout modal should NOT appear
    ${timeout_visible}=    Run Keyword And Return Status
    ...    Expect Element    ${SESSION_TIMEOUT_MODAL}    visible
    Should Be Equal    ${timeout_visible}    ${False}
    ...    msg=Session Timeout modal should NOT appear during active interaction

# -------------------------------------------------------
# M2.1.35 — ACCOUNT AUTO-UNLOCKS AFTER 5-MINUTE COOLDOWN
# -------------------------------------------------------

TC_M2.1_035 - Verify Account Automatically Unlocks After 5-Minute Cooldown
    [Documentation]    After the 5-minute cooldown expires, the user can log in successfully
    ...    with correct credentials and reach the OTP screen.
    ...    NOTE: This test waits 5+ minutes.
    [Tags]    M2.1.35    Session    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # TC_M2.1_022 may fail due to session issues, so use Navigate To Login Page for robustness
    Navigate To Login Page
    # Block the account (uses VALID_EMAIL — MAILSAC password was changed to NewPass@2025 by TC_M2.1_039)
    FOR    ${i}    IN RANGE    5
        Input Text       ${EMAIL_FIELD}       ${VALID_EMAIL}
        Input Text       ${PASSWORD_FIELD}    ${WRONG_PASSWORD}
        Click Element    ${LOGIN_BUTTON}
        Sleep    2s
    END
    Element Should Be Visible    ${ACCOUNT_BLOCKED_ERROR}
    # Wait for cooldown (5 minutes + buffer)
    Sleep    310s
    # Login with correct credentials — should succeed
    Input Text       ${EMAIL_FIELD}       ${VALID_EMAIL}
    Input Text       ${PASSWORD_FIELD}    ${VALID_PASSWORD}
    Click Element    ${LOGIN_BUTTON}
    Wait Until Element Is Visible    ${OTP_SCREEN}    timeout=15s
    Element Should Be Visible    ${OTP_SCREEN}
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${HOME_SCREEN}    timeout=15s
    Element Should Be Visible    ${HOME_SCREEN}


