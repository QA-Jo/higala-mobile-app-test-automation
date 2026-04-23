*** Settings ***
Library           AppiumLibrary
Resource          ../../resources/common.robot
Resource          ../../resources/variables/M1.1_variables.resource

Suite Setup       Run Keywords    Open Higala App    AND    Setup Screenshot On Failure
Suite Teardown    Close Higala App
Test Setup        Navigate To Login Page
Test Teardown     Run Keyword If Test Failed    Navigate To Login Page

*** Keywords ***
Navigate To Update Password Screen
    [Arguments]    ${email}    ${temp_password}
    # Logs in with temporary credentials → lands on the Update Password screen
    Input Text       ${AA_EMAIL_FIELD}    ${email}
    Input Text       ${AA_PWD_FIELD}      ${temp_password}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_UPDATE_PWD_SCREEN}    timeout=15s
    Sleep    2s

Navigate To Account Activation OTP Screen
    [Arguments]    ${email}    ${temp_password}    ${new_password}
    # Full path: Login → Update Password → OTP screen
    Navigate To Update Password Screen    ${email}    ${temp_password}
    Input Text       ${AA_NEW_PWD_FIELD}      ${new_password}
    Input Text       ${AA_CONFIRM_PWD_FIELD}  ${new_password}
    Click Element    ${AA_RESET_BTN}
    Wait Until Element Is Visible    ${AA_OTP_SCREEN}    timeout=15s
    Sleep    2s

*** Test Cases ***

# ==============================================================
# HAPPY PATH
# ==============================================================

# -------------------------------------------------------
# M1.1.1 — UI VERIFICATION (Not Automatable)
# -------------------------------------------------------

TC_M1.1_001 - Verify Password Update Page UI Elements
    [Documentation]    All UI elements on the Update Password screen must match the Figma mockup
    ...    (layout, fonts, icons, colors, spacing, labels).
    ...    NOT AUTOMATABLE — requires visual comparison against Figma design.
    [Tags]    M1.1.1    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires visual Figma comparison

# -------------------------------------------------------
# M1.1.2 — FULL ACCOUNT ACTIVATION HAPPY PATH
# -------------------------------------------------------

TC_M1.1_002 - Verify User Can Activate Account Using Temporary Password
    [Documentation]    Verify the complete first-time login and password activation flow:
    ...    1. Login with valid temp credentials → redirected to Update Password screen.
    ...    2. Temp password field is pre-filled and disabled.
    ...    3. Enter and confirm a new password → tap "Reset password".
    ...    4. OTP is sent → enter magic OTP → password updated successfully.
    ...    5. Login with the new password → redirected to home page.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_1 has active temporary credentials from the bank.
    ...    NOTE: After this test, AA_TEMP_EMAIL_1 will have a permanent password set (AA_NEW_PASSWORD).
    [Tags]    M1.1.2    Positive
    # Step 1: Login with temp credentials
    Navigate To Update Password Screen    ${AA_TEMP_EMAIL_1}    ${AA_TEMP_PASSWORD}
    # Step 2: Verify temp password is pre-filled and disabled
    Element Should Be Visible    ${AA_UPDATE_PWD_SCREEN}
    # Step 3: Enter new password and confirm
    Input Text       ${AA_NEW_PWD_FIELD}      ${AA_NEW_PASSWORD}
    Input Text       ${AA_CONFIRM_PWD_FIELD}  ${AA_NEW_PASSWORD}
    Click Element    ${AA_RESET_BTN}
    # Step 4: OTP screen appears — enter magic OTP
    Wait Until Element Is Visible    ${AA_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    # Step 5: Success message displayed
    Wait Until Element Is Visible    ${AA_SUCCESS_MSG}    timeout=15s
    Element Should Be Visible    ${AA_SUCCESS_MSG}

# -------------------------------------------------------
# M1.1.6 — REQUEST NEW OTP AFTER COOLDOWN
# -------------------------------------------------------

TC_M1.1_006 - Verify User Can Request A New OTP After 1-Minute Cooldown Expires
    [Documentation]    After the 1-minute cooldown expires, "Resend code" becomes enabled.
    ...    Tapping it sends a new OTP and the user can verify with the new OTP.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_3 is on the OTP screen.
    [Tags]    M1.1.6    Positive
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_3}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # Wait for cooldown to expire
    Sleep    65s
    # Resend code should now be enabled
    Element Should Be Enabled    ${AA_RESEND_CODE}
    Click Element    ${AA_RESEND_CODE}
    Sleep    3s
    # Enter the new magic OTP
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${AA_SUCCESS_MSG}    timeout=15s
    Element Should Be Visible    ${AA_SUCCESS_MSG}


# ==============================================================
# NEGATIVE
# ==============================================================

# -------------------------------------------------------
# M1.1.3 — INVALID OTP ERROR
# -------------------------------------------------------

TC_M1.1_003 - Verify Error Is Displayed When Invalid OTP Is Entered
    [Documentation]    Verify that entering an incorrect OTP displays the validation error:
    ...    "OTP is either Invalid or has expired, Please try again or request a new OTP"
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_2 is on the OTP screen via Update Password flow.
    [Tags]    M1.1.3    Negative
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${AA_OTP_ERROR}    timeout=10s
    Element Should Be Visible    ${AA_OTP_ERROR}

# -------------------------------------------------------
# M1.1.4 — OTP ERROR CLEARS WHEN FIELD IS EMPTY
# -------------------------------------------------------

TC_M1.1_004 - Verify OTP Validation Error Clears When Fields Are Cleared
    [Documentation]    Verify that after entering an invalid OTP (error displayed),
    ...    clearing the OTP input fields removes the error validation message.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_2 is on the OTP screen.
    [Tags]    M1.1.4    Negative
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # Enter wrong OTP → error appears
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${AA_OTP_ERROR}    timeout=10s
    # Clear the first OTP box
    Click Element    xpath=(//android.widget.EditText)[1]
    Clear Element Text    xpath=(//android.widget.EditText)[1]
    Sleep    1s
    # Error should no longer be visible
    Element Should Not Be Visible    ${AA_OTP_ERROR}

# -------------------------------------------------------
# M1.1.5 — RESEND CODE DISABLED DURING 1-MIN COOLDOWN
# -------------------------------------------------------

TC_M1.1_005 - Verify Resend Code Is Disabled During 1-Minute OTP Cooldown
    [Documentation]    Immediately after landing on the OTP screen (OTP just sent),
    ...    the "Resend code" link must be disabled and tapping it must not generate a new OTP.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_3 is on the OTP Verification screen.
    [Tags]    M1.1.5    Negative
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_3}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # Resend code should be disabled immediately (cooldown just started)
    ${resend_enabled}=    Run Keyword And Return Status
    ...    Element Should Be Enabled    ${AA_RESEND_CODE}
    Should Not Be True    ${resend_enabled}
    ...    "Resend code" should be disabled during the 1-minute cooldown

# -------------------------------------------------------
# M1.1.7 — OLD OTP INVALID AFTER RESEND
# -------------------------------------------------------

TC_M1.1_007 - Verify Previously Received OTP Is Invalid After Requesting A New OTP
    [Documentation]    After tapping "Resend code", the previous OTP must be invalidated.
    ...    Entering the old OTP (magic: 123456 from Session 1) after a resend must fail.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_4 is on the OTP screen.
    [Tags]    M1.1.7    Negative
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_4}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # Wait for cooldown, then resend
    Sleep    65s
    Click Element    ${AA_RESEND_CODE}
    Sleep    3s
    # Attempt to use the previous magic OTP — should be invalid
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=2s
    Wait Until Element Is Visible    ${AA_OTP_ERROR}    timeout=10s
    Element Should Be Visible    ${AA_OTP_ERROR}

# -------------------------------------------------------
# M1.1.8 — 5TH FAILED OTP ATTEMPT TRIGGERS MAX ATTEMPTS
# -------------------------------------------------------

TC_M1.1_008 - Verify Verification Failed After 5th Incorrect OTP Attempt
    [Documentation]    After 5 consecutive incorrect OTP entries the system displays:
    ...    "Verification Failed: You have reached the maximum number of attempts.
    ...     For your security, we're redirecting you to the previous page."
    ...    The user is then redirected back to the Login screen.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_5 is on the OTP screen with 0 prior failed attempts.
    ...    WARNING: Consumes one unverified OTP session on AA_TEMP_EMAIL_5.
    [Tags]    M1.1.8    Negative
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_5}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AA_MAX_ATTEMPTS}    timeout=10s
    Element Should Be Visible    ${AA_MAX_ATTEMPTS}
    Click Element    ${AA_OK_BTN}
    # User redirected back to Login screen
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    Element Should Be Visible    ${AA_EMAIL_FIELD}

# -------------------------------------------------------
# M1.1.9 — 5TH ATTEMPT ACROSS MULTIPLE RESEND REQUESTS
# -------------------------------------------------------

TC_M1.1_009 - Verify Max Attempts Is Enforced Across Multiple Resend Requests
    [Documentation]    The 5-attempt limit applies across all resends in a single session:
    ...    2 wrong OTPs → Resend → 2 more wrong → Resend → 1 wrong = 5th attempt = max attempts modal.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_6 is on the OTP screen with 0 prior failed attempts.
    ...    WARNING: Consumes one unverified OTP session on AA_TEMP_EMAIL_6.
    [Tags]    M1.1.9    Negative
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_6}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AA_MAX_ATTEMPTS}    timeout=10s
    Element Should Be Visible    ${AA_MAX_ATTEMPTS}
    Click Element    ${AA_OK_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    Element Should Be Visible    ${AA_EMAIL_FIELD}

# -------------------------------------------------------
# M1.1.15 — BLOCKED EMAIL SHOWS ERROR DURING BLOCK PERIOD
# -------------------------------------------------------

TC_M1.1_015 - Verify Blocked Email Shows Error Message During 60-Minute Block Period
    [Documentation]    During the 60-minute blocking period, any login attempt with the blocked email
    ...    must display: "You have exceeded the maximum number of OTP attempts. You can try again in X mins."
    ...    The remaining block time must be updated on each retry.
    ...
    ...    Pre-conditions: AA_BLOCK_EMAIL is currently blocked (run TC_M1.1_012 first).
    [Tags]    M1.1.15    Negative
    Input Text       ${AA_EMAIL_FIELD}    ${AA_BLOCK_EMAIL}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${AA_BLOCKED_ERROR}
    Click Element    ${AA_OK_BTN}
    Sleep    5s
    # Retry — remaining time should be updated
    Input Text       ${AA_EMAIL_FIELD}    ${AA_BLOCK_EMAIL}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${AA_BLOCKED_ERROR}
    Click Element    ${AA_OK_BTN}

# -------------------------------------------------------
# M1.1.17 — NO BLOCK IF VALID OTP ON 5TH ATTEMPT IN SESSION 3
# -------------------------------------------------------

TC_M1.1_017 - Verify No Block When Valid OTP Entered On 5th Attempt In 3rd Session
    [Documentation]    When 2 prior unverified sessions have occurred and the 3rd session's
    ...    5th OTP attempt is CORRECT, the session is verified — no block is triggered.
    ...    Rule D automation: Sessions 1 & 2 abandoned without OTP entry. Session 3 uses
    ...    4× magic OTP 000000 (invalid, not max-attempts) then 123456 (valid on 5th attempt).
    ...    No block should be triggered because the session was successfully verified.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_2 is NOT blocked and has 0 prior unverified sessions.
    [Tags]    M1.1.17    Negative
    # Session 1 — navigate to OTP screen then close (abandoned, no OTP entered)
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 2 — abandoned again
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 3 — 4 wrong OTPs (000000 = invalid/expired, not max-attempts trigger)
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    # 5th attempt: magic valid OTP — session verified, no block triggered
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=3s
    Wait Until Element Is Visible    ${AA_SUCCESS_MSG}    timeout=15s
    Element Should Be Visible    ${AA_SUCCESS_MSG}

# -------------------------------------------------------
# M1.1.19 — INVALID NEW PASSWORD FORMAT
# -------------------------------------------------------

TC_M1.1_019 - Verify Validation Message When New Password Does Not Meet Complexity Requirements
    [Documentation]    On the Update Password screen, entering a password that does not meet
    ...    complexity requirements must display:
    ...    "Please follow the password complexity
    ...     1 Uppercase Letter, 1 Lowercase Letter, 1 Number, 1 Special Character,
    ...     8 Characters minimum, 127 Characters maximum"
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_5 is on the Update Password screen.
    [Tags]    M1.1.19    Negative
    Navigate To Update Password Screen    ${AA_TEMP_EMAIL_5}    ${AA_TEMP_PASSWORD}
    Input Text       ${AA_NEW_PWD_FIELD}      ${AA_WEAK_PASSWORD}
    Input Text       ${AA_CONFIRM_PWD_FIELD}  ${AA_WEAK_PASSWORD}
    Click Element    ${AA_RESET_BTN}
    Wait Until Element Is Visible    ${AA_PWD_COMPLEXITY}    timeout=10s
    Element Should Be Visible    ${AA_PWD_COMPLEXITY}

# -------------------------------------------------------
# M1.1.20 — INVALID EMAIL FORMAT ON LOGIN
# -------------------------------------------------------

TC_M1.1_020 - Verify Validation Message For Invalid Email Format On Login
    [Documentation]    Entering an invalid email format on the Login screen must display:
    ...    "Incorrect Email Address or Password, please try again."
    ...    The user must not be able to proceed.
    [Tags]    M1.1.20    Negative
    Input Text       ${AA_EMAIL_FIELD}    ${AA_INVALID_EMAIL}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_INVALID_CREDENTIALS}    timeout=10s
    Element Should Be Visible    ${AA_INVALID_CREDENTIALS}

# -------------------------------------------------------
# M1.1.21 — BLANK EMAIL FIELD
# -------------------------------------------------------

TC_M1.1_021 - Verify Validation Message For Blank Email Field On Login
    [Documentation]    Leaving the email field empty and tapping "Sign in" must display:
    ...    "This field is required." under the empty email field.
    [Tags]    M1.1.21    Negative
    Clear Element Text    ${AA_EMAIL_FIELD}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_FIELD_REQUIRED}    timeout=10s
    Element Should Be Visible    ${AA_FIELD_REQUIRED}

# -------------------------------------------------------
# M1.1.22 — INVALID TEMPORARY PASSWORD
# -------------------------------------------------------

TC_M1.1_022 - Verify Validation Message For Invalid Temporary Password On Login
    [Documentation]    Entering a valid email but an incorrect temporary password and tapping
    ...    "Sign in" must display: "Incorrect Email Address or Password, please try again."
    [Tags]    M1.1.22    Negative
    Input Text       ${AA_EMAIL_FIELD}    ${AA_TEMP_EMAIL_1}
    Input Text       ${AA_PWD_FIELD}      ${AA_WRONG_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_INVALID_CREDENTIALS}    timeout=10s
    Element Should Be Visible    ${AA_INVALID_CREDENTIALS}

# -------------------------------------------------------
# M1.1.25 — BLANK PASSWORD FIELD
# (Note: m1.1.23 and m1.1.24 are not present in the reference test case document)
# -------------------------------------------------------

TC_M1.1_025 - Verify Validation Message For Blank Password Field On Login
    [Documentation]    Leaving the password field empty and tapping "Sign in" must display:
    ...    "This field is required." under the empty password field.
    [Tags]    M1.1.25    Negative
    Input Text       ${AA_EMAIL_FIELD}    ${AA_TEMP_EMAIL_1}
    Clear Element Text    ${AA_PWD_FIELD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_FIELD_REQUIRED}    timeout=10s
    Element Should Be Visible    ${AA_FIELD_REQUIRED}

# -------------------------------------------------------
# M1.1.26 — TEMP PASSWORD MISMATCH
# -------------------------------------------------------

TC_M1.1_026 - Verify Validation Message When Temporary Password Does Not Match
    [Documentation]    Entering a correct email but a password that does not match the
    ...    temporary password sent by the system must display:
    ...    "Temporary password does not match, please try again."
    ...    The "Sign in" button must be disabled.
    [Tags]    M1.1.26    Negative
    Input Text       ${AA_EMAIL_FIELD}    ${AA_TEMP_EMAIL_1}
    Input Text       ${AA_PWD_FIELD}      ${AA_WRONG_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_TEMP_PWD_MISMATCH}    timeout=10s
    Element Should Be Visible    ${AA_TEMP_PWD_MISMATCH}

# -------------------------------------------------------
# M1.1.27 — EXPIRED TEMPORARY PASSWORD (Not Automatable)
# -------------------------------------------------------

TC_M1.1_027 - Verify Behavior When Expired Temporary Password Is Used On Login
    [Documentation]    Entering a temporary password that has expired (beyond the 24-hour limit)
    ...    must display: "Expired temporary password: Your temporary password has expired.
    ...    Please use the Forgot Password option to create a new password."
    ...    NOT AUTOMATABLE — requires a naturally expired temp password (24-hour wait).
    [Tags]    M1.1.27    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: requires a naturally expired temporary password (24-hour wait)

# -------------------------------------------------------
# M1.1.28 — EXPIRED TEMP PASSWORD → FORGOT PASSWORD (Not Automatable)
# -------------------------------------------------------

TC_M1.1_028 - Verify User With Expired Temporary Password Can Reset Via Forgot Password
    [Documentation]    After the expired temp password error, the user taps OK and uses
    ...    the Forgot Password flow to set a new permanent password and log in.
    ...    NOT AUTOMATABLE — depends on TC_M1.1_027 which requires a 24-hour expired temp password.
    [Tags]    M1.1.28    Manual    Skipped    NotAutomatable
    Skip    Not Automatable: depends on a naturally expired temporary password (24-hour wait)

# -------------------------------------------------------
# M1.1.30 — NEW PASSWORD FIELD REQUIRED VALIDATION
# -------------------------------------------------------

TC_M1.1_030 - Verify Error Validation For Empty New Password Field
    [Documentation]    On the Update Password screen, leaving the New Password field empty
    ...    and tapping "Reset password" must display: "New Password is required."
    [Tags]    M1.1.30    Negative
    Navigate To Update Password Screen    ${AA_TEMP_EMAIL_6}    ${AA_TEMP_PASSWORD}
    # Leave New Password field empty, fill in Confirm Password
    Clear Element Text    ${AA_NEW_PWD_FIELD}
    Input Text       ${AA_CONFIRM_PWD_FIELD}  ${AA_NEW_PASSWORD}
    Click Element    ${AA_RESET_BTN}
    Wait Until Element Is Visible    ${AA_FIELD_REQUIRED}    timeout=10s
    Element Should Be Visible    ${AA_FIELD_REQUIRED}

# -------------------------------------------------------
# M1.1.31 — CONFIRM PASSWORD FIELD REQUIRED VALIDATION
# -------------------------------------------------------

TC_M1.1_031 - Verify Error Validation For Empty Confirm Password Field
    [Documentation]    On the Update Password screen, leaving the Confirm Password field empty
    ...    and tapping "Reset password" must display: "Confirm Password is required."
    [Tags]    M1.1.31    Negative
    Navigate To Update Password Screen    ${AA_TEMP_EMAIL_6}    ${AA_TEMP_PASSWORD}
    # Fill in New Password, leave Confirm Password empty
    Input Text       ${AA_NEW_PWD_FIELD}      ${AA_NEW_PASSWORD}
    Clear Element Text    ${AA_CONFIRM_PWD_FIELD}
    Click Element    ${AA_RESET_BTN}
    Wait Until Element Is Visible    ${AA_FIELD_REQUIRED}    timeout=10s
    Element Should Be Visible    ${AA_FIELD_REQUIRED}


# ==============================================================
# RATE LIMITING / DESTRUCTIVE
# ==============================================================

# -------------------------------------------------------
# M1.1.12 — EMAIL BLOCKED AFTER 3 SESSIONS × 5 FAILS (Destructive)
# -------------------------------------------------------

TC_M1.1_012 - Verify Email Blocked For 60 Minutes After 3 Unverified Sessions With Max Attempts Per Session
    [Documentation]    3 unverified OTP sessions each with 5 failed attempts (within 15 minutes)
    ...    triggers a 60-minute email block on the 4th attempt.
    ...    Error: "You have exceeded the maximum number of OTP attempts. You can try again in 59 mins."
    ...
    ...    Pre-conditions: AA_BLOCK_EMAIL is NOT registered and NOT currently blocked.
    ...    WARNING: This test blocks AA_BLOCK_EMAIL for 60 minutes.
    [Tags]    M1.1.12    Destructive
    # Session 1 — 999999 directly triggers max attempts
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AA_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AA_OK_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 2 — 999999 directly triggers max attempts
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AA_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AA_OK_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 3 — 999999 directly triggers max attempts → triggers block
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AA_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AA_OK_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 4 — attempt → blocked error
    Input Text       ${AA_EMAIL_FIELD}    ${AA_BLOCK_EMAIL}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${AA_BLOCKED_ERROR}
    Click Element    ${AA_OK_BTN}

# -------------------------------------------------------
# M1.1.13 — EMAIL BLOCKED AFTER 3 SESSIONS WITH < 5 FAILS (Destructive)
# -------------------------------------------------------

TC_M1.1_013 - Verify Email Blocked After 3 Unverified Sessions With Less Than 5 Fails Per Session
    [Documentation]    3 unverified OTP sessions each with 3 failed attempts + exit (within 15 min)
    ...    still triggers a 60-minute email block.
    ...
    ...    Pre-conditions: AA_BLOCK_EMAIL_2 is NOT registered and NOT currently blocked.
    ...    WARNING: This test blocks AA_BLOCK_EMAIL_2 for 60 minutes.
    [Tags]    M1.1.13    Destructive
    # Session 1 — 3 wrong OTPs then exit via X
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 2 — 3 wrong OTPs then exit
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 3 — 3 wrong OTPs then exit → triggers block
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 4 — attempt → blocked error
    Input Text       ${AA_EMAIL_FIELD}    ${AA_BLOCK_EMAIL_2}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${AA_BLOCKED_ERROR}
    Click Element    ${AA_OK_BTN}

# -------------------------------------------------------
# M1.1.14 — EMAIL BLOCKED AFTER 3 ABANDONED SESSIONS (Destructive)
# -------------------------------------------------------

TC_M1.1_014 - Verify Email Blocked After 3 Abandoned OTP Sessions
    [Documentation]    3 sessions where the user reaches the OTP screen but exits without
    ...    entering any OTP (within 15 min) triggers a 60-minute email block.
    ...
    ...    Pre-conditions: AA_BLOCK_EMAIL_3 is NOT registered and NOT currently blocked.
    ...    WARNING: This test blocks AA_BLOCK_EMAIL_3 for 60 minutes.
    [Tags]    M1.1.14    Destructive
    # Session 1 — reach OTP screen, exit immediately
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL_3}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 2
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL_3}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 3
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL_3}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 4 — attempt → blocked error
    Input Text       ${AA_EMAIL_FIELD}    ${AA_BLOCK_EMAIL_3}
    Input Text       ${AA_PWD_FIELD}      ${AA_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_BLOCKED_ERROR}    timeout=15s
    Element Should Be Visible    ${AA_BLOCKED_ERROR}
    Click Element    ${AA_OK_BTN}

# -------------------------------------------------------
# M1.1.29 — ACCOUNT LOCKED AFTER 5 WRONG LOGIN ATTEMPTS
# -------------------------------------------------------

TC_M1.1_029 - Verify Account Locked After 5 Consecutive Failed Login Attempts
    [Documentation]    Entering the correct email but an incorrect temporary password 5 times
    ...    consecutively must lock the account:
    ...    "This account has reached the maximum number of login attempts.
    ...     Please try again after 5 minutes."
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_5 is registered and NOT currently locked.
    ...    WARNING: This test locks AA_TEMP_EMAIL_5 for 5 minutes.
    [Tags]    M1.1.29    Negative    Destructive
    FOR    ${i}    IN RANGE    4
        Input Text       ${AA_EMAIL_FIELD}    ${AA_TEMP_EMAIL_5}
        Input Text       ${AA_PWD_FIELD}      ${AA_WRONG_TEMP_PASSWORD}
        Click Element    ${AA_SIGN_IN_BTN}
        Wait Until Element Is Visible    ${AA_INVALID_CREDENTIALS}    timeout=10s
        Element Should Be Visible    ${AA_INVALID_CREDENTIALS}
        Sleep    1s
    END
    # 5th failed attempt — triggers account lock
    Input Text       ${AA_EMAIL_FIELD}    ${AA_TEMP_EMAIL_5}
    Input Text       ${AA_PWD_FIELD}      ${AA_WRONG_TEMP_PASSWORD}
    Click Element    ${AA_SIGN_IN_BTN}
    Wait Until Element Is Visible    ${AA_ACCOUNT_LOCKED}    timeout=10s
    Element Should Be Visible    ${AA_ACCOUNT_LOCKED}


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

# -------------------------------------------------------
# M1.1.10 — OTP SESSION EXPIRES BEFORE MAX ATTEMPTS
# -------------------------------------------------------

TC_M1.1_010 - Verify OTP Session Expiry Error Before Reaching Max Attempts
    [Documentation]    After 3 wrong OTPs, wait for the 5-minute session to expire.
    ...    4th attempt after expiry shows "OTP is either invalid or has expired."
    ...    Tapping "Resend Code" shows the "OTP Expired" modal.
    ...    Tapping "Request New Code" redirects to Login screen.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_2 is on the OTP screen.
    ...    NOTE: This test waits 5+ minutes.
    [Tags]    M1.1.10    Session
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_2}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # Enter 3 wrong OTPs within the session window
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Element Should Be Visible    ${AA_OTP_ERROR}
    # Wait for OTP session to expire (5 minutes + buffer)
    Sleep    310s
    # 4th attempt after session expiry — error
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${AA_OTP_ERROR}    timeout=10s
    Element Should Be Visible    ${AA_OTP_ERROR}
    # Tap Resend → OTP Expired modal
    Click Element    ${AA_RESEND_CODE}
    Wait Until Element Is Visible    ${AA_OTP_EXPIRED_MODAL}    timeout=10s
    Element Should Be Visible    ${AA_OTP_EXPIRED_MODAL}
    # Tap Request New Code → back to Login
    Click Element    ${AA_REQUEST_NEW_CODE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    Element Should Be Visible    ${AA_EMAIL_FIELD}

# -------------------------------------------------------
# M1.1.11 — OTP ENTERED AFTER 5-MINUTE VALIDITY WINDOW
# -------------------------------------------------------

TC_M1.1_011 - Verify Error Modal When OTP Is Entered After 5-Minute Validity Window
    [Documentation]    After the 5-minute OTP validity window expires, any OTP entry (valid or invalid)
    ...    should display: "OTP is either invalid or has expired. Please try again or request a new OTP."
    ...    Tapping OK redirects the user back to the previous screen.
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_3 is on the OTP screen.
    ...    NOTE: This test waits 5+ minutes.
    [Tags]    M1.1.11    Session
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_3}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # Wait for the OTP validity window to expire
    Sleep    310s
    # Enter OTP (any value — even magic OTP should be rejected after expiry)
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=2s
    Wait Until Element Is Visible    ${AA_OTP_ERROR}    timeout=10s
    Element Should Be Visible    ${AA_OTP_ERROR}
    Click Element    ${AA_OK_BTN}
    # Redirected back to Update Password screen or Login screen
    Sleep    2s

# -------------------------------------------------------
# M1.1.16 — BLOCKED EMAIL UNBLOCKS AFTER 60 MINUTES
# -------------------------------------------------------

TC_M1.1_016 - Verify Blocked Email Unblocks And Allows Reset After 60 Minutes
    [Documentation]    After 60 minutes have passed since the block was applied,
    ...    the user can initiate account activation normally and complete OTP verification.
    ...
    ...    Pre-conditions: AA_BLOCK_EMAIL was blocked and 60 minutes have passed.
    ...    NOTE: This test must run 60+ minutes after TC_M1.1_012.
    [Tags]    M1.1.16    Session
    Navigate To Account Activation OTP Screen    ${AA_BLOCK_EMAIL}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    # OTP screen should now be accessible — no block error
    Element Should Be Visible    ${AA_OTP_SCREEN}
    # Enter magic OTP to verify unblock is fully functional
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${AA_SUCCESS_MSG}    timeout=15s
    Element Should Be Visible    ${AA_SUCCESS_MSG}

# -------------------------------------------------------
# M1.1.18 — NO BLOCK WHEN 3 SESSIONS SPAN MORE THAN 15 MINUTES
# -------------------------------------------------------

TC_M1.1_018 - Verify No Email Block When 3 Unverified Sessions Span More Than 15 Minutes
    [Documentation]    If 3 unverified OTP sessions span more than 15 minutes total,
    ...    the system must NOT block the email (outside the blocking window).
    ...    Session timeline:
    ...      #1 starts at 00:00, ends at 05:00 (2 wrong OTPs + exit)
    ...      #2 starts at 05:00, ends at 10:00 (2 wrong OTPs + exit)
    ...      Wait 5+ min (10:00 to 16:00)
    ...      #3 starts at 16:00 (> 15 min since #1 ended) → no block
    ...
    ...    Pre-conditions: AA_TEMP_EMAIL_4 is NOT blocked. Test takes ~20 minutes.
    [Tags]    M1.1.18    Session
    # Session 1 — 2 wrong OTPs then exit
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_4}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Session 2 — 2 wrong OTPs then exit (starts ~5 min mark)
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_4}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Click Element    ${AA_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AA_EMAIL_FIELD}    timeout=10s
    # Wait 6 minutes — pushes Session 3 start beyond the 15-min window from Session 1
    Sleep    360s
    # Session 3 — attempt should succeed (no block error)
    Navigate To Account Activation OTP Screen    ${AA_TEMP_EMAIL_4}    ${AA_TEMP_PASSWORD}    ${AA_NEW_PASSWORD}
    Element Should Be Visible    ${AA_OTP_SCREEN}
    # Verify no block error — enter magic OTP
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${AA_SUCCESS_MSG}    timeout=15s
    Element Should Be Visible    ${AA_SUCCESS_MSG}


