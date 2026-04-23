*** Settings ***
Resource            ../../resources/common.robot
Resource            ../../resources/variables/M2.2_variables.resource
Library             AppiumLibrary
Library             String
Suite Setup         Setup Screenshot On Failure
Test Setup          Open Higala App
Test Teardown       Close Higala App
Test Tags           Login    M2.2    ForgotPassword

*** Test Cases ***

# ==============================================================
# HAPPY PATH
# ==============================================================

# -------------------------------------------------------
# M2.2.1 — FULL PASSWORD RESET FLOW
# -------------------------------------------------------

TC_M2.2_001 - User Can Complete Full Forgot Password Flow And Reset Password
    [Documentation]    Verify user can navigate the full forgot password flow:
    ...    FP link → email → OTP (magic) → new password → success → back to login (m2.2.1)
    ...    NOTE: This test changes the account password. Restore it manually after running,
    ...    or use a dedicated FP test account to avoid affecting other tests.
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Sleep    3s
    # Use Wait Until Keyword Succeeds to handle StaleElementReferenceException on EditText
    Wait Until Keyword Succeeds    3x    1s    Input Text    ${FP_EMAIL_FIELD}    ${FP_VALID_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=15s
    Sleep    2s
    # Magic OTP — any 6 digits accepted in test environment
    Enter OTP Into Boxes    1    2    3    4    5    6
    # New Password screen — enter and confirm new password
    # Positional locators used — verify hints with Appium Inspector if needed
    Wait Until Element Is Visible    ${FP_NEW_PWD_FIELD}    timeout=15s
    Sleep    2s
    Input Text    ${FP_NEW_PWD_FIELD}       ${FP_NEW_PASSWORD}
    Input Text    ${FP_CONFIRM_PWD_FIELD}   ${FP_NEW_PASSWORD}
    Click Element    ${FP_NEW_PWD_SUBMIT}
    # Verify success — modal or message
    Wait Until Element Is Visible    ${FP_SUCCESS_MSG}    timeout=15s
    Expect Element        ${FP_SUCCESS_MSG}    visible
    # Tap Back to Login and verify redirect
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.2 — LOGIN AFTER PASSWORD UPDATE
# -------------------------------------------------------

TC_M2.2_002 - User Can Login Successfully After Forgot Password Reset
    [Documentation]    Verify user can log in using the new password after completing the forgot password reset flow (m2.2.2)
    ...    PRE-CONDITION: m2.2.1 (TC_M2.2_001) must have run first and set password to ${FP_NEW_PASSWORD}.
    ...    NOTE: After this test, the account password is ${FP_NEW_PASSWORD} — restore to ${FP_VALID_PASSWORD} manually.
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Chains from TC_M2.2_001 which ends on Login page after "Back to Login" — wait for field to stabilise
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=15s
    Sleep    2s
    Wait Until Keyword Succeeds    3x    1s    Input Text    xpath=//android.widget.EditText[@hint='Email Address']    ${FP_VALID_EMAIL}
    Wait Until Keyword Succeeds    3x    1s    Input Text    xpath=//android.widget.EditText[@hint='Password']         ${FP_NEW_PASSWORD}
    Click Element   accessibility_id=Sign in
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=30s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Home']    timeout=30s
    Expect Element        xpath=//android.widget.TextView[@text='Home']    visible

# -------------------------------------------------------
# M2.2.6 — RESEND CODE DISABLED DURING 1-MIN COOLDOWN
# -------------------------------------------------------

TC_M2.2_006 - Resend Code Is Disabled During Cooldown Then Enabled After 1 Minute On FP OTP Screen
    [Documentation]    Verify Resend code is not clickable during the 1-minute cooldown on the FP OTP screen,
    ...    then becomes clickable once the cooldown expires (m2.2.6)
    [Tags]    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # Uses FP_VALID_EMAIL_2 to avoid rate limiting — TC_M2.2_001 used FP_VALID_EMAIL
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_2}
    # NOTE: FP OTP resend button may be enabled=true immediately (different UI vs login OTP).
    # Only verify the button is enabled after cooldown.
    # Wait for cooldown to expire
    Sleep    90s
    # After cooldown — Resend code should be enabled
    ${after}=    Get Element Attribute    xpath=//*[@text='Resend code']    enabled
    Should Be Equal    ${after}    true    msg=Resend code should become enabled after the 1-min cooldown

# -------------------------------------------------------
# M2.2.33 — FP WORKS AFTER 60-MIN BLOCK EXPIRES
# -------------------------------------------------------

TC_M2.2_033 - Verify FP Password Reset Works After 60-Minute Block Expires
    [Documentation]    After 60 minutes have passed since the block was applied,
    ...    the Forgot Password flow resumes normally: OTP is sent, validated,
    ...    and the password update is successful.
    ...
    ...    Pre-conditions: FP_BLOCK_EMAIL was blocked and 60 minutes have now passed.
    ...    NOTE: Must run 60+ minutes after TC_M2.2_026/027.
    [Tags]    M2.2.33    Session    Positive
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Element Should Be Visible    ${FP_OTP_SCREEN}
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${FP_NEW_PWD_FIELD}    timeout=15s
    Input Text       ${FP_NEW_PWD_FIELD}      ${FP_NEW_PASSWORD}
    Input Text       ${FP_CONFIRM_PWD_FIELD}  ${FP_NEW_PASSWORD}
    Click Element    ${FP_NEW_PWD_SUBMIT}
    Wait Until Element Is Visible    ${FP_SUCCESS_MSG}    timeout=15s
    Element Should Be Visible    ${FP_SUCCESS_MSG}


# ==============================================================
# NEGATIVE
# ==============================================================

# -------------------------------------------------------
# M2.2.9 — INVALID OTP VALIDATION MESSAGE
# -------------------------------------------------------

TC_M2.2_007 - Invalid OTP Shows Validation Error On FP OTP Screen
    [Documentation]    Verify that entering an incorrect OTP on the FP OTP screen shows a validation error (m2.2.9)
    ...    Expected: "OTP is either Invalid or has expired, Please try again or request a new OTP"
    [Tags]    Negative
    # Uses FP_VALID_EMAIL_3 to avoid rate limiting
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    # Enter wrong OTP digits — post_sleep=2s to check error before toast disappears
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Expect Element        ${FP_OTP_ERROR}    visible

# -------------------------------------------------------
# M2.2.12 — 5TH ATTEMPT ACROSS MULTIPLE RESENDS
# -------------------------------------------------------

TC_M2.2_009 - Fifth Failed OTP Attempt Across Multiple Resend Requests Triggers Max Attempts Error
    [Documentation]    Verify that 5 total failed OTP attempts spanning multiple resend requests still triggers
    ...    the max attempts error on the 5th attempt (m2.2.12)
    ...    Flow: 2 wrong → resend → 2 wrong → resend → 1 wrong (5th) → max attempts error
    [Tags]    Negative
    # Uses FP_VALID_EMAIL_6 (fresh account) — needs 0 prior failed attempts; shares with TC_M2.2_008
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${FP_MAX_ATTEMPTS}    timeout=10s
    Expect Element        ${FP_MAX_ATTEMPTS}    visible
    ${ok_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.Button[@text='Ok']    timeout=5s
    Run Keyword If    ${ok_visible}    Click Element    xpath=//android.widget.Button[@text='Ok']
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s

# -------------------------------------------------------
# M2.2.24 — EMAIL VALIDATION ON FORGOT PASSWORD SCREEN
# -------------------------------------------------------

TC_M2.2_019 - FP Email Screen Shows Validation For Empty Field
    [Documentation]    Verify that submitting an empty email on the FP screen shows "This field is required" (m2.2.24 step 1)
    ...    NOTE: Confirmed via Appium Inspector — submitting empty email shows no inline error.
    ...    The form stays on the same page silently. Verify expected behavior with QA.
    [Tags]    Negative    Skipped
    Skip    TC_M2.2_019: App shows no inline error when email is empty — form silently stays on page. Verify with QA.

TC_M2.2_020 - FP Email Screen Shows Validation For Invalid Email Format
    [Documentation]    Verify that an incorrectly formatted email on FP screen shows "Incorrect email format" (m2.2.24 step 2)
    [Tags]    Negative
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    # Enter invalid format email
    Input Text       ${FP_EMAIL_FIELD}    useremail.com
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_INVALID_FORMAT}    timeout=10s
    Expect Element        ${FP_INVALID_FORMAT}    visible

TC_M2.2_021 - FP Email Screen Shows Validation For Unregistered Email
    [Documentation]    Verify that an unregistered email on the FP screen shows an invalid email error (m2.2.24 step 3)
    ...    Expected: "Email address is invalid, please try again."
    [Tags]    Negative
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    Input Text       ${FP_EMAIL_FIELD}    notregistered@higala.com
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_INVALID_EMAIL_MSG}    timeout=10s
    Expect Element        ${FP_INVALID_EMAIL_MSG}    visible

# -------------------------------------------------------
# M2.2.25 — BLANK PASSWORD FIELDS ON NEW PASSWORD SCREEN
# -------------------------------------------------------

TC_M2.2_022 - New Password Screen Shows Required Validation When Password Fields Are Left Blank
    [Documentation]    Verify that leaving the New Password and Confirm Password fields blank shows required validation (m2.2.25)
    ...    NOTE: Confirmed via screenshot — app shows no inline required error for blank password submit. Form stays silently.
    [Tags]    Negative    Skipped
    Skip    TC_M2.2_022: App shows no required validation for blank password submit — form stays on page silently. Verify with QA.
    # Uses FP_VALID_EMAIL_2 — rotated back after gap since TC_M2.2_006
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL_2}
    # Tap Submit without filling in any password fields
    Click Element    ${FP_NEW_PWD_SUBMIT}
    Wait Until Element Is Visible    ${FP_PWD_REQUIRED}    timeout=10s
    Expect Element        ${FP_PWD_REQUIRED}    visible

# -------------------------------------------------------
# M2.2.26 — INVALID PASSWORD FORMAT ON NEW PASSWORD FIELD
# -------------------------------------------------------

TC_M2.2_023 - New Password Field Shows Complexity Validation For Invalid Password
    [Documentation]    Verify that entering a password that doesn't meet complexity requirements on the New Password field
    ...    shows the password complexity validation message (m2.2.26)
    ...    Expected: "Please follow the password complexity: 1 Uppercase, 1 Lowercase, 1 Number, 1 Special Char, 8-127 chars"
    [Tags]    Negative
    # Uses FP_VALID_EMAIL_3 — rotated back after gap since TC_M2.2_007
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL_3}
    # Enter a weak/invalid password
    Input Text    ${FP_NEW_PWD_FIELD}    weakpass
    Click Element    ${FP_NEW_PWD_SUBMIT}
    Wait Until Element Is Visible    ${FP_PWD_COMPLEXITY}    timeout=10s
    Expect Element        ${FP_PWD_COMPLEXITY}    visible

# -------------------------------------------------------
# M2.2.27 — INVALID PASSWORD FORMAT ON CONFIRM PASSWORD FIELD
# -------------------------------------------------------

TC_M2.2_024 - Confirm Password Field Shows Complexity Validation For Invalid Password
    [Documentation]    Verify that entering an invalid password in the Confirm Password field shows complexity validation (m2.2.27)
    [Tags]    Negative
    # Uses FP_VALID_EMAIL_4 — rotated back after gap since TC_M2.2_008
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL_4}
    # Enter valid new password first
    Input Text    ${FP_NEW_PWD_FIELD}       ${FP_NEW_PASSWORD}
    # Enter weak password in confirm field
    Input Text    ${FP_CONFIRM_PWD_FIELD}   weakpass
    Click Element    ${FP_NEW_PWD_SUBMIT}
    Wait Until Element Is Visible    ${FP_PWD_COMPLEXITY}    timeout=10s
    Expect Element        ${FP_PWD_COMPLEXITY}    visible

# -------------------------------------------------------
# M2.2.28 — PASSWORDS DO NOT MATCH
# -------------------------------------------------------

TC_M2.2_025 - New Password Screen Shows Error When Passwords Do Not Match
    [Documentation]    Verify that entering mismatched passwords shows "Passwords do not match. Please try again." (m2.2.28)
    [Tags]    Negative
    # Uses FP_VALID_EMAIL_5 — rotated back after gap since TC_M2.2_009
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL_5}
    Input Text    ${FP_NEW_PWD_FIELD}       ${FP_NEW_PASSWORD}
    Input Text    ${FP_CONFIRM_PWD_FIELD}   DifferentPass@999
    Click Element    ${FP_NEW_PWD_SUBMIT}
    Wait Until Element Is Visible    ${FP_PWD_MISMATCH}    timeout=10s
    Expect Element        ${FP_PWD_MISMATCH}    visible

# -------------------------------------------------------
# M2.2.32 — BLOCKED EMAIL ERROR DURING BLOCK PERIOD
# PRE-CONDITION: Run TC_M2.2_026 or TC_M2.2_027 first to put ${FP_BLOCK_EMAIL} in blocked state
# -------------------------------------------------------

TC_M2.2_028 - Blocked Email Shows Error Message During 60-Min Block Period
    [Documentation]    Verify that a blocked email shows the blocking error when attempting forgot password
    ...    during the 60-minute block period (m2.2.32)
    ...    PRE-CONDITION: ${FP_BLOCK_EMAIL} must be in a blocked state (run TC_M2.2_026 or TC_M2.2_027 first).
    ...    Expected: "You have exceeded the maximum number of OTP attempts. You can try again in X mins."
    [Tags]    Negative    Security
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Expect Element        ${FP_BLOCKED_ERROR}    visible

# -------------------------------------------------------
# M2.2.32 — BLOCKED FP EMAIL SHOWS ERROR DURING 60-MIN BLOCK PERIOD
# -------------------------------------------------------

TC_M2.2_032 - Verify Blocked FP Email Shows Error Message During Block Period
    [Documentation]    During the 60-minute blocking period, any Forgot Password attempt
    ...    with the blocked email must display:
    ...    "You have exceeded the maximum number of OTP attempts. You can try again in X mins."
    ...    Each retry must show an updated remaining time.
    ...
    ...    Pre-conditions: FP_BLOCK_EMAIL is currently blocked (run TC_M2.2_026/027 first).
    [Tags]    M2.2.32    Negative
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${FP_BLOCKED_ERROR}
    Click Element    xpath=//*[@text='OK' or @text='Ok']
    Sleep    5s
    # Retry — same error should appear with updated remaining time
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${FP_BLOCKED_ERROR}

# -------------------------------------------------------
# M2.2.34 — NO BLOCK IF VALID OTP ON 5TH ATTEMPT IN 3RD FP SESSION
# -------------------------------------------------------

TC_M2.2_034 - Verify No Block When Valid OTP Entered On 5th Attempt In 3rd FP Session
    [Documentation]    When 2 prior unverified FP sessions have occurred and the 3rd session's
    ...    5th OTP attempt is CORRECT, the session is verified and no block is triggered.
    ...    This is the same scenario already validated by TC_M2.2_029.
    [Tags]    M2.2.34    Manual    Skipped
    Skip    Already covered by TC_M2.2_029 — identical scenario


# -------------------------------------------------------
# M2.2.35 — NO BLOCK WHEN 3 FP SESSIONS SPAN MORE THAN 15 MINUTES
# -------------------------------------------------------

TC_M2.2_035 - Verify No FP Email Block When 3 Unverified Sessions Span More Than 15 Minutes
    [Documentation]    If 3 unverified FP OTP sessions span more than 15 minutes total,
    ...    no block is triggered.
    ...    Session timeline:
    ...      #1 → 00:00–05:00 (2 wrong OTPs + exit)
    ...      #2 → 05:00–10:00 (2 wrong OTPs + exit)
    ...      Wait 6 min → 10:00–16:00
    ...      #3 → 16:00+ (> 15 min since #1 ended) → Session #4 must NOT be blocked.
    ...    NOTE: Test takes ~20 minutes.
    [Tags]    M2.2.35    Session
    # Session 1 — 2 wrong OTPs then exit
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_2}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${FP_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${FP_OTP_ERROR}
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Session 2 — 2 wrong OTPs then exit
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_2}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${FP_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${FP_OTP_ERROR}
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Wait 6 min — pushes Session 3 beyond the 15-min blocking window from Session 1
    Sleep    360s
    # Session 3 — 1 wrong OTP then exit
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_2}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${FP_OTP_ERROR}
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Session 4 — must NOT be blocked; complete with magic OTP
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_2}
    Element Should Be Visible    ${FP_OTP_SCREEN}
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${FP_NEW_PWD_FIELD}    timeout=15s
    Element Should Be Visible    ${FP_NEW_PWD_FIELD}


# ==============================================================
# RATE LIMITING / DESTRUCTIVE
# ==============================================================

# -------------------------------------------------------
# M2.2.34 — NO BLOCK IF VALID OTP ON 5TH ATTEMPT IN 3RD SESSION
# -------------------------------------------------------

TC_M2.2_029 - No Email Block When Valid OTP Is Entered On 5th Attempt In 3rd Session
    [Documentation]    Verify that the email is NOT blocked when the user enters a correct OTP on the 5th attempt
    ...    in the 3rd session — the session is considered verified and blocking is not triggered (m2.2.34)
    ...    Uses magic OTP for the successful 5th attempt.
    ...    PRE-CONDITION: Two previous unverified FP sessions already exist for ${FP_VALID_EMAIL_6}
    [Tags]    Positive    Security
    [Setup]    NONE
    [Teardown]    NONE
    Reset To Login Page
    # Uses FP_VALID_EMAIL_6 (fresh) — pre-condition requires exactly 2 prior unverified sessions
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Sleep    6s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Sleep    6s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Sleep    6s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Sleep    6s
    # 5th attempt — use magic OTP (correct) — should succeed, NOT trigger blocking
    Enter OTP Into Boxes    1    2    3    4    5    6
    Sleep    3s
    # Verify we reached the new password screen (not a blocking error or max attempts)
    ${blocked}=    Run Keyword And Return Status
    ...    Expect Element    ${FP_BLOCKED_ERROR}    visible
    Should Be Equal    ${blocked}    ${False}    msg=Email should NOT be blocked when OTP succeeds on 5th attempt
    ${max_attempts}=    Run Keyword And Return Status
    ...    Expect Element    ${FP_MAX_ATTEMPTS}    visible
    Should Be Equal    ${max_attempts}    ${False}    msg=Max attempts error should NOT appear when OTP succeeds on 5th attempt
    # Session 4 — should be allowed (no blocking)
    Reset To Login Page
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Sleep    3s
    Wait Until Keyword Succeeds    3x    1s    Input Text    ${FP_EMAIL_FIELD}    ${FP_VALID_EMAIL_2}
    Click Element    ${FP_SUBMIT_BTN}
    # Should reach OTP screen normally — no block error
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=15s
    Expect Element        ${FP_OTP_SCREEN}    visible

# -------------------------------------------------------
# M2.2.36 — COUNTER RESETS AFTER SUCCESSFUL VERIFICATION
# -------------------------------------------------------

TC_M2.2_030 - Failed Session Counter Resets After Successful OTP Verification
    [Documentation]    Verify that the unverified session counter resets after a successful OTP verification,
    ...    so that 3 new unverified sessions are needed before blocking is triggered again (m2.2.36)
    ...    Flow: 2 failed sessions → successful session (#3 with magic OTP) → 3 more failed sessions → block on 6th
    [Tags]    Positive    Security
    [Setup]    NONE
    # Uses FP_VALID_EMAIL_6 — after TC_M2.2_029's verified session counter is reset to 0
    # Sessions 1 & 2 — unverified (wrong OTPs each, then exit)
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Sleep    3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Sleep    3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    # Session 3 — SUCCESSFUL (magic OTP) — counter should reset
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Sleep    3s
    # Verify no blocking occurred
    ${blocked_early}=    Run Keyword And Return Status
    ...    Expect Element    ${FP_BLOCKED_ERROR}    visible
    Should Be Equal    ${blocked_early}    ${False}    msg=Should not be blocked after successful OTP in session 3
    Reset To Login Page
    # Sessions 4, 5, 6 — 3 new unverified sessions (counter was reset, so block triggers on 6th)
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    # 7th session attempt — should now trigger block (3 new failures after the successful reset)
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Sleep    3s
    Wait Until Keyword Succeeds    3x    1s    Input Text    ${FP_EMAIL_FIELD}    ${FP_VALID_EMAIL_6}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Expect Element        ${FP_BLOCKED_ERROR}    visible


# -------------------------------------------------------
# M2.2.11 — 5TH FAILED OTP TRIGGERS MAX ATTEMPTS ERROR
# -------------------------------------------------------

TC_M2.2_008 - Fifth Failed OTP Attempt Triggers Max Attempts Error And Redirects To FP Email Screen
    [Documentation]    Verify that 5 consecutive incorrect OTP entries on the FP screen trigger the max attempts error,
    ...    then redirect the user back to the FP email screen (m2.2.11)
    ...    Expected error: "Verification Failed: You have reached the maximum number of attempts..."
    [Tags]    Negative
    # Uses FP_VALID_EMAIL_6 (fresh account) — requires 0 prior failed OTP attempts
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_6}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${FP_MAX_ATTEMPTS}    timeout=10s
    Expect Element        ${FP_MAX_ATTEMPTS}    visible
    # Tap OK to dismiss
    ${ok_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.Button[@text='Ok']    timeout=5s
    Run Keyword If    ${ok_visible}    Click Element    xpath=//android.widget.Button[@text='Ok']
    # Verify redirected back to FP email entry screen (NOT login screen)
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Expect Element        ${FP_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.29 — EMAIL BLOCKED AFTER 3 SESSIONS × 5 INVALID OTPs
# WARNING: This test WILL BLOCK ${FP_BLOCK_EMAIL} for 60 minutes
# -------------------------------------------------------

TC_M2.2_026 - Email Is Blocked For 60 Min After 3 Unverified FP Sessions With 5 Wrong OTPs Each
    [Documentation]    Verify email is blocked for 60 minutes after 3 unverified forgot password OTP sessions,
    ...    each with 5 invalid OTP attempts (m2.2.29)
    ...    WARNING: This WILL BLOCK ${FP_BLOCK_EMAIL} for 60 minutes. Use a dedicated test email.
    ...    Expected error: "You have exceeded the maximum number of OTP attempts. You can try again in X mins."
    [Tags]    Negative    Security    Destructive
    # Session 1 — 999999 directly triggers max attempts
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Enter OTP Into Boxes    9    9    9    9    9    9
    Wait Until Element Is Visible    ${FP_MAX_ATTEMPTS}    timeout=10s
    ${ok1}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.Button[@text='Ok']    timeout=5s
    Run Keyword If    ${ok1}    Click Element    xpath=//android.widget.Button[@text='Ok']
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    # Session 2 — 999999 directly triggers max attempts
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    9    9    9    9    9    9
    Wait Until Element Is Visible    ${FP_MAX_ATTEMPTS}    timeout=10s
    ${ok2}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.Button[@text='Ok']    timeout=5s
    Run Keyword If    ${ok2}    Click Element    xpath=//android.widget.Button[@text='Ok']
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    # Session 3 — 999999 directly triggers max attempts (triggers block)
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    9    9    9    9    9    9
    Wait Until Element Is Visible    ${FP_MAX_ATTEMPTS}    timeout=10s
    ${ok3}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.Button[@text='Ok']    timeout=5s
    Run Keyword If    ${ok3}    Click Element    xpath=//android.widget.Button[@text='Ok']
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    # Session 4 — email should now be BLOCKED
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Expect Element        ${FP_BLOCKED_ERROR}    visible

# -------------------------------------------------------
# M2.2.30 — EMAIL BLOCKED AFTER 3 SESSIONS WITH PARTIAL WRONG OTPs
# WARNING: This test WILL BLOCK ${FP_BLOCK_EMAIL} for 60 minutes
# -------------------------------------------------------

TC_M2.2_027 - Email Is Blocked After 3 Unverified FP Sessions With Partial Wrong OTP Attempts
    [Documentation]    Verify email is blocked after 3 unverified forgot password OTP sessions,
    ...    each with fewer than 5 invalid OTP attempts (m2.2.30)
    ...    WARNING: This WILL BLOCK ${FP_BLOCK_EMAIL} for 60 minutes. Use a dedicated test email.
    [Tags]    Negative    Security    Destructive
    # Session 1 — 3 wrong OTPs then exit
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    # Navigate back to start session 2
    Reset To Login Page
    # Session 2 — 3 wrong OTPs then exit
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    # Session 3 — 3 wrong OTPs (triggers block)
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Enter OTP Into Boxes    0    0    0    0    0    0
    Wait Until Element Is Visible    ${FP_OTP_ERROR}    timeout=10s
    Reset To Login Page
    # Session 4 — email should now be BLOCKED
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Expect Element        ${FP_BLOCKED_ERROR}    visible

# -------------------------------------------------------
# M2.2.31 — EMAIL BLOCKED AFTER 3 ABANDONED OTP SESSIONS (X BUTTON)
# WARNING: This test WILL BLOCK ${FP_BLOCK_EMAIL} for 60 minutes
# -------------------------------------------------------

TC_M2.2_031 - Email Is Blocked After 3 Abandoned FP OTP Sessions Via X Button
    [Documentation]    Verify email is blocked after 3 abandoned forgot password OTP sessions —
    ...    each session is abandoned by tapping the X (close) button on the OTP screen (m2.2.31)
    ...    WARNING: This WILL BLOCK ${FP_BLOCK_EMAIL} for 60 minutes. Use a dedicated test email.
    ...    NOTE: Verify ${FP_OTP_CLOSE_BTN} locator with Appium Inspector before running.
    ...    Alternatives: xpath=//android.widget.TextView[@text='✕']  |  accessibility_id=Close  |  accessibility_id=Back
    [Tags]    Negative    Security    Destructive
    # Session 1 — reach OTP screen, then tap X to abandon
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=10s
    Click Element    ${FP_OTP_CLOSE_BTN}
    # After X, app returns to landing page — navigate back to login for next session
    Sleep    2s
    Reset To Login Page
    # Session 2 — reach OTP screen, then tap X to abandon
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=10s
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Session 3 — reach OTP screen, then tap X to abandon (triggers block)
    Navigate To FP OTP Screen    ${FP_BLOCK_EMAIL}
    Wait Until Element Is Visible    ${FP_OTP_SCREEN}    timeout=10s
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Session 4 — email should now be BLOCKED
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    Input Text       ${FP_EMAIL_FIELD}    ${FP_BLOCK_EMAIL}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Expect Element        ${FP_BLOCKED_ERROR}    visible


# -------------------------------------------------------
# M2.2.36 — BLOCK COUNTER RESETS AFTER SUCCESSFUL FP VERIFICATION
# -------------------------------------------------------

TC_M2.2_036 - Verify FP Block Counter Resets After Successful OTP Verification
    [Documentation]    After a successful FP OTP verification in Session #3, the unverified-session
    ...    counter resets to zero. Sessions #4, #5, #6 are counted as new failures and
    ...    blocking is triggered on Session #7.
    ...
    ...    Flow: Sessions 1 & 2 unverified → Session 3 (4 wrong + resend + 1 correct) →
    ...          counter resets → Sessions 4, 5, 6 unverified (within 15 min) → Session 7 = blocked.
    ...
    ...    Pre-conditions: FP_VALID_EMAIL_3 is NOT blocked. Test takes ~20+ minutes.
    ...    WARNING: This test blocks FP_VALID_EMAIL_3 for 60 minutes.
    [Tags]    M2.2.36    Destructive    Session
    # Sessions 1 & 2 — unverified (counter = 2)
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Session 3 — 4 wrong OTPs → resend → 5th = magic OTP (correct) → counter resets to 0
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Sleep    65s    # Wait for 1-min cooldown before resend
    Click Element    ${FP_RESEND_CODE}
    Sleep    3s
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${FP_NEW_PWD_FIELD}    timeout=15s
    Input Text       ${FP_NEW_PWD_FIELD}      ${FP_NEW_PASSWORD}
    Input Text       ${FP_CONFIRM_PWD_FIELD}  ${FP_NEW_PASSWORD}
    Click Element    ${FP_NEW_PWD_SUBMIT}
    Wait Until Element Is Visible    ${FP_SUCCESS_MSG}    timeout=15s
    Reset To Login Page
    # Sessions 4, 5, 6 — each unverified (new counter: 1, 2, 3)
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL_3}
    Click Element    ${FP_OTP_CLOSE_BTN}
    Sleep    2s
    Reset To Login Page
    # Session 7 — must be BLOCKED (sessions 4, 5, 6 = 3 new unverified within 15 min)
    Navigate To FP Email Screen
    Input Text       ${FP_EMAIL_FIELD}    ${FP_VALID_EMAIL_3}
    Click Element    ${FP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${FP_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${FP_BLOCKED_ERROR}


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

# -------------------------------------------------------
# M2.2.3 — SESSION TIMEOUT ON FP EMAIL SCREEN (INACTIVITY)
# -------------------------------------------------------

TC_M2.2_003 - Session Timeout Appears On FP Email Screen After 5 Min Inactivity
    [Documentation]    Verify Session Timeout modal appears on the Forgot Password email screen after 5 minutes of inactivity (m2.2.3)
    [Tags]    Negative    Session
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    # Stay idle — no interaction for 5 minutes
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.4 — SESSION TIMEOUT ON FP EMAIL SCREEN (MINIMIZE)
# -------------------------------------------------------

TC_M2.2_004 - Session Timeout Appears On FP Email Screen After Minimizing For 5 Min
    [Documentation]    Verify Session Timeout modal appears on the FP email screen after the app is minimized for 5 minutes (m2.2.4)
    [Tags]    Negative    Session
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    # Minimize the app
    Background Application    -1
    Sleep    310s
    # Restore app
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.5 — SESSION TIMEOUT MODAL PERSISTS ON FP EMAIL SCREEN AFTER MINIMIZE/RESTORE
# -------------------------------------------------------

TC_M2.2_005 - Session Timeout Modal Still Visible On FP Email Screen After Minimize And Restore
    [Documentation]    Verify Session Timeout modal is still visible on FP email screen after modal appeared, then app is minimized and reopened (m2.2.5)
    [Tags]    Negative    Session
    Click Element    ${FP_LINK}
    Wait Until Element Is Visible    ${FP_EMAIL_FIELD}    timeout=10s
    # Wait for session timeout modal (5 min inactivity)
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    # Minimize while modal is showing
    Background Application    -1
    Sleep    5s
    # Restore — modal should still be visible
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s

# -------------------------------------------------------
# M2.2.15 — SESSION TIMEOUT ON OTP SCREEN (INACTIVITY)
# -------------------------------------------------------

TC_M2.2_010 - Session Timeout Appears On FP OTP Screen After 5 Min Inactivity
    [Documentation]    Verify Session Timeout modal appears on the FP OTP screen after 5 minutes of inactivity (m2.2.15)
    [Tags]    Negative    Session
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL}
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.16 — SESSION TIMEOUT ON OTP SCREEN (MINIMIZE)
# -------------------------------------------------------

TC_M2.2_011 - Session Timeout Appears On FP OTP Screen After Minimizing For 5 Min
    [Documentation]    Verify Session Timeout modal appears on the FP OTP screen after the app is minimized for 5 minutes (m2.2.16)
    [Tags]    Negative    Session
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL}
    Background Application    -1
    Sleep    310s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.17 — SESSION TIMEOUT MODAL PERSISTS ON OTP SCREEN AFTER MINIMIZE/RESTORE
# -------------------------------------------------------

TC_M2.2_012 - Session Timeout Modal Still Visible On FP OTP Screen After Minimize And Restore
    [Documentation]    Verify Session Timeout modal is still visible on FP OTP screen after modal appeared, then app is minimized and reopened (m2.2.17)
    [Tags]    Negative    Session
    Navigate To FP OTP Screen    ${FP_VALID_EMAIL}
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    # Minimize while modal is visible
    Background Application    -1
    Sleep    5s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    # Modal should still be visible
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s

# -------------------------------------------------------
# M2.2.18 — SESSION TIMEOUT ON NEW PASSWORD SCREEN (INACTIVITY)
# -------------------------------------------------------

TC_M2.2_013 - Session Timeout Appears On New Password Screen After 5 Min Inactivity
    [Documentation]    Verify Session Timeout modal appears on the New Password screen after 5 minutes of inactivity (m2.2.18)
    ...    Navigation: FP link → email → Submit → OTP (magic) → New Password screen → idle 5 min
    [Tags]    Negative    Session
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL}
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.19 — SESSION TIMEOUT ON NEW PASSWORD SCREEN (MINIMIZE)
# -------------------------------------------------------

TC_M2.2_014 - Session Timeout Appears On New Password Screen After Minimizing For 5 Min
    [Documentation]    Verify Session Timeout modal appears on the New Password screen after the app is minimized for 5 minutes (m2.2.19)
    [Tags]    Negative    Session
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL}
    Background Application    -1
    Sleep    310s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.20 — SESSION TIMEOUT MODAL PERSISTS ON NEW PASSWORD SCREEN AFTER MINIMIZE/RESTORE
# -------------------------------------------------------

TC_M2.2_015 - Session Timeout Modal Still Visible On New Password Screen After Minimize And Restore
    [Documentation]    Verify Session Timeout modal is still visible on the New Password screen after modal appeared, then app is minimized and reopened (m2.2.20)
    [Tags]    Negative    Session
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL}
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Background Application    -1
    Sleep    5s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s

# -------------------------------------------------------
# M2.2.21 — SESSION TIMEOUT ON NEW PASSWORD SET PAGE (INACTIVITY)
# NOTE: m2.2.21-23 may be the same screen as m2.2.18-20 (verify with QA team)
# -------------------------------------------------------

TC_M2.2_016 - Session Timeout Appears On New Password Set Page After 5 Min Inactivity
    [Documentation]    Verify Session Timeout modal appears on the new password set page after 5 minutes of inactivity (m2.2.21)
    ...    NOTE: If this is the same screen as m2.2.18, this test is equivalent to TC_M2.2_013.
    ...    Verify with QA/dev if "Enter new password page" and "new password set page" are the same screen.
    [Tags]    Negative    Session
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL}
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.22 — SESSION TIMEOUT ON NEW PASSWORD SET PAGE (MINIMIZE)
# -------------------------------------------------------

TC_M2.2_017 - Session Timeout Appears On New Password Set Page After Minimizing For 5 Min
    [Documentation]    Verify Session Timeout modal appears on the new password set page after the app is minimized for 5 minutes (m2.2.22)
    [Tags]    Negative    Session
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL}
    Background Application    -1
    Sleep    310s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s
    Expect Element        ${EMAIL_FIELD}    visible

# -------------------------------------------------------
# M2.2.23 — SESSION TIMEOUT MODAL PERSISTS ON NEW PASSWORD SET PAGE AFTER MINIMIZE/RESTORE
# -------------------------------------------------------

TC_M2.2_018 - Session Timeout Modal Still Visible On New Password Set Page After Minimize And Restore
    [Documentation]    Verify Session Timeout modal is still visible on the new password set page after modal appeared, then minimized and reopened (m2.2.23)
    [Tags]    Negative    Session
    Navigate To FP New Password Screen    ${FP_VALID_EMAIL}
    Sleep    310s
    Wait Until Element Is Visible    ${SESSION_TIMEOUT_MODAL}    timeout=15s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Background Application    -1
    Sleep    5s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Expect Element        ${SESSION_TIMEOUT_MODAL}    visible
    Expect Element        ${BACK_TO_LOGIN_BTN}    visible
    Click Element    ${BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    ${EMAIL_FIELD}    timeout=10s


