*** Settings ***
Resource            ../../resources/common.robot
Resource            ../../resources/variables/M3_variables.resource
Library             AppiumLibrary
Library             String
Suite Setup         Run Keywords    Open Higala App    AND    Setup Screenshot On Failure
Suite Teardown      Close Higala App
Test Teardown       Reset To Login Page
Test Tags           AccountManagement    M3

*** Test Cases ***

# ==============================================================
# HAPPY PATH
# ==============================================================

TC_M3.1_001 - Verify That The User Can View Their Profile Summary
    [Documentation]    Navigate to Profile tab and verify the summary section displays
    ...    the user's Full Name, Email Address, Gender, Date of Birth, and Mobile Number.
    ...
    ...    Pre-conditions: User is logged in with AM_VALID_EMAIL.
    [Tags]    M3.1.1    Positive
    Navigate To Profile Screen
    # Verify key profile summary fields are visible (confirmed from screenshot)
    Expect Element    xpath=//android.widget.TextView[@text='Email address']    visible
    Expect Element    xpath=//android.widget.TextView[@text='Gender']    visible
    Expect Element    xpath=//android.widget.TextView[@text='Date of Birth']    visible
    Expect Element    xpath=//android.widget.TextView[@text='Mobile number']    visible
    Expect Element    ${AM_MORE_DETAILS_BTN}    visible

TC_M3.1_002 - Verify That The User Can View Their Personal Info
    [Documentation]    Tap "More Details" from Profile screen and verify My Profile screen
    ...    shows all expected sections: Personal Details (ID Type, ID Number, ID Expiry Date),
    ...    Address (Present, Permanent), and Additional Details (Nationality, Gender, DOB,
    ...    Occupation, Company Industry, Monthly Income, TIN, US FATCA).
    ...
    ...    Pre-conditions: User is logged in with AM_VALID_EMAIL.
    [Tags]    M3.1.2    Positive
    Navigate To My Profile Screen
    # Personal Details section
    Expect Element    ${AM_PERSONAL_DETAILS_HDR}    visible
    Expect Element    ${AM_ID_TYPE_LABEL}    visible
    Expect Element    ${AM_ID_NUMBER_LABEL}    visible
    Expect Element    ${AM_ID_EXPIRY_LABEL}    visible
    # Address section
    Expect Element    ${AM_ADDRESS_HDR}    visible
    Expect Element    ${AM_PRESENT_ADDR_LABEL}    visible
    Expect Element    ${AM_PERMANENT_ADDR_LABEL}    visible
    # Scroll down to reveal Additional Details
    Swipe    start_x=500    start_y=1200    end_x=500    end_y=400    duration=500ms
    Sleep    1s
    Expect Element    ${AM_ADDITIONAL_DETAILS_HDR}    visible
    Expect Element    ${AM_NATIONALITY_LABEL}    visible
    Expect Element    ${AM_OCCUPATION_LABEL}    visible
    Expect Element    ${AM_MONTHLY_INCOME_LABEL}    visible
    Expect Element    ${AM_TIN_LABEL}    visible
    Expect Element    ${AM_US_FATCA_LABEL}    visible

TC_M3.2_001 - Verify That The User Can Edit Profile Details Except Full Name And Email Address
    [Documentation]    Navigate to Edit Account screen. Verify full name and email address
    ...    fields are NOT present. Edit the Occupation field, tap Save, and verify
    ...    the profile is updated successfully.
    ...
    ...    Pre-conditions: User is logged in with AM_VALID_EMAIL.
    ...    NOTE: Full name and email address are read-only and should not appear on this screen.
    [Tags]    M3.2.1    Positive
    Navigate To Edit Account Screen
    # Verify the screen title is "Edit Account"
    Expect Element    ${AM_EDIT_ACCOUNT_SCREEN}    visible
    # Full name and email fields must NOT be present (read-only, not shown for editing)
    Page Should Not Contain Element    xpath=//android.widget.TextView[@text='Full Name' or @text='Email' or @text='Email address']
    # Scroll down to reveal Occupation field
    Swipe    start_x=500    start_y=1200    end_x=500    end_y=400    duration=500ms
    Sleep    1s
    # Edit the Occupation free-text field (required)
    Wait Until Element Is Visible    ${AM_OCCUPATION_INPUT}    timeout=10s
    Clear Text    ${AM_OCCUPATION_INPUT}
    Input Text    ${AM_OCCUPATION_INPUT}    Teacher
    Hide Keyboard
    # Scroll to Save button and tap
    Swipe    start_x=500    start_y=1200    end_x=500    end_y=400    duration=500ms
    Sleep    1s
    Wait Until Element Is Visible    ${AM_SAVE_BTN}    timeout=10s
    Click Element    ${AM_SAVE_BTN}
    Wait Until Element Is Visible    ${AM_EDIT_SUCCESS_MSG}    timeout=15s
    Expect Element    ${AM_EDIT_SUCCESS_MSG}    visible

TC_M3.3_002 - Verify Successful Login And Access To Digital Bank Account After Password Update
    [Documentation]    After TC_M3.3_001 updates the password, log in using AM_CP_EMAIL
    ...    with the new password AM_CP_NEW_PASSWORD. Verify user reaches Home screen.
    ...
    ...    Pre-conditions: TC_M3.3_001 must have run successfully.
    ...    AM_CP_EMAIL current password is now AM_CP_NEW_PASSWORD.
    [Tags]    M3.3.2    Positive
    Login With Credentials    ${AM_CP_EMAIL}    ${AM_CP_NEW_PASSWORD}
    Expect Element    ${AM_HOME_SCREEN}    visible

TC_M3.3_008 - Verify That The User Can Request A New OTP On Change Password
    [Documentation]    Wait for 1-minute cooldown to expire on OTP screen, then tap
    ...    "Resend code" and verify a new OTP is sent successfully.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.8    Positive
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    # Wait for cooldown to expire before resend is enabled
    Sleep    65s
    Wait Until Element Is Visible    ${AM_RESEND_CODE}    timeout=10s
    Click Element    ${AM_RESEND_CODE}
    Sleep    3s
    # OTP screen should still be visible — new OTP sent
    Expect Element    ${AM_OTP_SCREEN}    visible

TC_M3.3_020 - Verify No Block When Valid OTP Is Used On 5th Attempt In 3rd Session
    [Documentation]    After 2 unverified sessions, initiate Session 3. Enter 4 incorrect OTPs,
    ...    then enter the correct magic OTP on the 5th attempt. Verify no block is triggered
    ...    and Session 4 starts normally.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered. Use a fresh/unblocked account.
    [Tags]    M3.3.20    Positive
    # Session 1 — 3 wrong OTPs then close (unverified)
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 2 — 3 wrong OTPs then close (unverified)
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 3 — 4 wrong OTPs, then correct OTP on 5th attempt (verified)
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    # 5th attempt — correct magic OTP
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${AM_SUCCESS_MSG}    timeout=15s
    Expect Element    ${AM_SUCCESS_MSG}    visible
    # Session 4 — should start normally (no block)
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    # Block error should NOT appear
    ${blocked}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${AM_BLOCKED_ERROR}    timeout=5s
    Should Be Equal    ${blocked}    ${False}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Expect Element    ${AM_CP_SCREEN}    visible

TC_M3.4_001 - Verify That The User Can Successfully Log Out
    [Documentation]    Navigate to Profile screen, scroll down to the Logout button,
    ...    tap it, and verify the user is redirected directly to the Sign In screen.
    ...    No confirmation modal — logout is immediate.
    ...
    ...    Pre-conditions: User is logged in with AM_VALID_EMAIL.
    [Tags]    M3.4.1    Positive
    Navigate To Profile Screen
    # Logout button is below "Get in Touch" section — scroll down to reveal it
    Swipe    start_x=500    start_y=1200    end_x=500    end_y=400    duration=500ms
    Sleep    1s
    Wait Until Element Is Visible    ${AM_LOGOUT_BTN}    timeout=10s
    Click Element    ${AM_LOGOUT_BTN}
    # No confirmation modal — user is redirected directly to Sign In screen
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=15s
    Expect Element    xpath=//android.widget.EditText[@hint='Email Address']    visible



# ==============================================================
# NEGATIVE
# ==============================================================

TC_M3.2_002 - Verify Validation Error When Required Editable Fields Are Left Blank
    [Documentation]    On Edit Account screen, clear the Occupation and TIN required free-text
    ...    fields. Verify "This field is required." error appears inline for each cleared field.
    ...    The Save button remains disabled — no need to tap it.
    ...
    ...    Pre-conditions: User is logged in with AM_VALID_EMAIL.
    [Tags]    M3.2.2    Negative
    Navigate To Edit Account Screen
    # Scroll down to reveal Occupation field
    Swipe    start_x=500    start_y=1200    end_x=500    end_y=400    duration=500ms
    Sleep    1s
    # Clear Occupation (required) — triggers inline "This field is required." error
    Wait Until Element Is Visible    ${AM_OCCUPATION_INPUT}    timeout=10s
    Clear Text    ${AM_OCCUPATION_INPUT}
    Hide Keyboard
    Wait Until Element Is Visible    ${AM_FIELD_REQUIRED}    timeout=10s
    Expect Element    ${AM_FIELD_REQUIRED}    visible
    # Scroll down to TIN field and clear it
    Swipe    start_x=500    start_y=1200    end_x=500    end_y=400    duration=500ms
    Sleep    1s
    Wait Until Element Is Visible    ${AM_TIN_INPUT}    timeout=10s
    Clear Text    ${AM_TIN_INPUT}
    Hide Keyboard
    # Both fields now show "This field is required." error
    Expect Element    ${AM_FIELD_REQUIRED}    visible
    # Save button must remain disabled — do not click
    ${save_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${AM_SAVE_BTN}
    Should Be Equal    ${save_enabled}    ${False}

TC_M3.3_007 - Verify Resend Code Is Disabled During 1-Minute OTP Cooldown On Change Password
    [Documentation]    On the OTP screen after initiating a Change Password flow,
    ...    verify the "Resend code" link is disabled until the 1-minute cooldown expires.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.7    Negative
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    # "Resend available in 1:00" timer text appears during cooldown (confirmed from screenshot)
    Expect Element    ${AM_RESEND_TIMER}    visible
    # Tapping "Resend code" during cooldown must NOT send a new OTP — OTP screen remains
    Click Element    ${AM_RESEND_CODE}
    Sleep    2s
    Expect Element    ${AM_OTP_SCREEN}    visible
    Expect Element    ${AM_RESEND_TIMER}    visible

TC_M3.3_009 - Verify Previously Received OTP Is Invalid After Requesting New OTP On Change Password
    [Documentation]    After requesting a new OTP via "Resend code", enter the original
    ...    (previously received) OTP. Verify the system rejects it with an invalid OTP error.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.9    Negative
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    Sleep    65s
    Wait Until Element Is Visible    ${AM_RESEND_CODE}    timeout=10s
    Click Element    ${AM_RESEND_CODE}
    Sleep    3s
    # Enter a dummy invalid OTP (representing the old, now-invalidated one)
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Wait Until Element Is Visible    ${AM_OTP_ERROR}    timeout=10s
    Expect Element    ${AM_OTP_ERROR}    visible

TC_M3.3_010 - Verify Validation Message For Incorrect OTP On Change Password
    [Documentation]    On the OTP screen after initiating Change Password, enter an incorrect
    ...    OTP and verify the error message is displayed.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.10    Negative
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Wait Until Element Is Visible    ${AM_OTP_ERROR}    timeout=10s
    Expect Element    ${AM_OTP_ERROR}    visible

TC_M3.3_012 - Verify Validation On 5th Failed OTP Attempt On Change Password
    [Documentation]    Enter 4 incorrect OTPs, then a 5th incorrect OTP. Verify the
    ...    "Verification Failed: You have reached the maximum number of attempts..." modal
    ...    appears and user is redirected to the Change Password screen.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.12    Negative
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=3s
    Wait Until Element Is Visible    ${AM_MAX_ATTEMPTS}    timeout=10s
    Expect Element    ${AM_MAX_ATTEMPTS}    visible
    Click Element    ${AM_OK_BTN}
    # User should be redirected back to Change Password screen
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Expect Element    ${AM_CP_SCREEN}    visible

TC_M3.3_013 - Verify Validation On 5th OTP Attempt Across Multiple Resend Requests On Change Password
    [Documentation]    Enter 2 incorrect OTPs, resend, enter 2 more incorrect OTPs, resend,
    ...    enter 1 final incorrect OTP (5th total). Verify max attempts modal appears.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.13    Negative
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=3s
    Wait Until Element Is Visible    ${AM_MAX_ATTEMPTS}    timeout=10s
    Expect Element    ${AM_MAX_ATTEMPTS}    visible
    Click Element    ${AM_OK_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Expect Element    ${AM_CP_SCREEN}    visible

TC_M3.3_018 - Verify Blocked Error Message When Attempting Change Password During Block Period
    [Documentation]    While AM_BLOCK_EMAIL_1 is still within the 60-minute block period
    ...    (run after TC_M3.3_015), attempt Change Password again. Verify the blocked error
    ...    message with remaining time is displayed each time.
    ...
    ...    Pre-conditions: AM_BLOCK_EMAIL_1 is currently blocked (TC_M3.3_015 ran within 60 min).
    [Tags]    M3.3.18    Negative
    Navigate To Profile Screen    ${AM_BLOCK_EMAIL_1}    ${AM_VALID_PASSWORD}
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AM_BLOCKED_ERROR}    visible
    Click Element    ${AM_OK_BTN}
    # Attempt again — error should still appear with updated remaining time
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AM_BLOCKED_ERROR}    visible

TC_M3.3_027 - Verify Error When Required Fields Are Left Blank On Change Password Screen
    [Documentation]    On the Change Password screen, leave one or more fields blank and
    ...    tap Submit. Verify "<Field> is required." error appears and form does not proceed.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.27    Negative
    Navigate To Change Password Screen
    # Leave all fields blank and tap Submit
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_FIELD_REQUIRED}    timeout=10s
    Expect Element    ${AM_FIELD_REQUIRED}    visible
    Page Should Not Contain Element    ${AM_OTP_SCREEN}

TC_M3.3_028 - Verify Error When Incorrect Current Password Is Entered
    [Documentation]    On the Change Password screen, enter an incorrect current password,
    ...    fill in valid new and confirm passwords, tap Submit.
    ...    Verify "Current Password does not match, please try again." error.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.28    Negative
    Navigate To Change Password Screen
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_WRONG_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_CURRENT_PWD_MISMATCH}    timeout=10s
    Expect Element    ${AM_CURRENT_PWD_MISMATCH}    visible

TC_M3.3_029 - Verify Password Complexity Error On New Password Field
    [Documentation]    Enter a weak password in the New Password field. Verify the
    ...    password complexity hint is displayed and Submit remains disabled.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.29    Negative
    Navigate To Change Password Screen
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_WEAK_PASSWORD}
    Wait Until Element Is Visible    ${AM_PWD_COMPLEXITY}    timeout=10s
    Expect Element    ${AM_PWD_COMPLEXITY}    visible
    # Submit button should be disabled
    ${submit_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${AM_CP_SUBMIT_BTN}
    Should Be Equal    ${submit_enabled}    ${False}

TC_M3.3_030 - Verify Password Complexity Error On Confirm Password Field
    [Documentation]    Enter a weak password in the Confirm Password field. Verify the
    ...    password complexity hint is displayed and Submit remains disabled.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.30    Negative
    Navigate To Change Password Screen
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_WEAK_PASSWORD}
    Wait Until Element Is Visible    ${AM_PWD_COMPLEXITY}    timeout=10s
    Expect Element    ${AM_PWD_COMPLEXITY}    visible
    ${submit_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${AM_CP_SUBMIT_BTN}
    Should Be Equal    ${submit_enabled}    ${False}

TC_M3.3_031 - Verify Mismatched New And Confirm Password Error
    [Documentation]    Enter a valid new password but a different value in the Confirm field.
    ...    Tap Submit. Verify "Passwords do not match, please try again." error is shown.
    ...
    ...    Pre-conditions: AM_VALID_EMAIL is registered with AM_VALID_PASSWORD.
    [Tags]    M3.3.31    Negative
    Navigate To Change Password Screen
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_WRONG_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_PWD_MISMATCH}    timeout=10s
    Expect Element    ${AM_PWD_MISMATCH}    visible



# ==============================================================
# RATE LIMITING / DESTRUCTIVE
# ==============================================================

TC_M3.3_001 - Verify That The User Can Update Their Password Successfully
    [Documentation]    Navigate to Change Password screen using AM_CP_EMAIL/AM_CP_PASSWORD.
    ...    Enter current password, valid new password, confirm new password, tap Submit.
    ...    Verify OTP screen appears, enter magic OTP, and confirm success message.
    ...
    ...    Pre-conditions: AM_CP_EMAIL is registered and current password is AM_CP_PASSWORD.
    ...    DESTRUCTIVE: After this TC, AM_CP_EMAIL password becomes AM_CP_NEW_PASSWORD.
    ...    Restore manually before re-running.
    [Tags]    M3.3.1    Positive    Destructive
    Navigate To Change Password Screen    ${AM_CP_EMAIL}    ${AM_CP_PASSWORD}
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_CP_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    1    2    3    4    5    6
    # Success screen: "Your new password is set!" with "Back to home" button
    Wait Until Element Is Visible    ${AM_SUCCESS_MSG}    timeout=15s
    Expect Element    ${AM_SUCCESS_MSG}    visible
    Click Element    ${AM_BACK_TO_HOME_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s

TC_M3.3_015 - Verify Email Blocked For 60 Minutes After 3 Unverified Sessions With Max Attempts Per Session
    [Documentation]    Using AM_BLOCK_EMAIL_1: initiate 3 Change Password OTP sessions,
    ...    entering 5 incorrect OTPs per session. After the 3rd session (within 15 min),
    ...    verify the 4th attempt shows a 60-minute block error.
    ...
    ...    Pre-conditions: AM_BLOCK_EMAIL_1 is registered and unblocked.
    ...    DESTRUCTIVE: AM_BLOCK_EMAIL_1 will be blocked for 60 minutes after this TC.
    [Tags]    M3.3.15    Negative    Destructive
    # Session 1 — 999999 directly triggers max attempts
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}    ${AM_BLOCK_EMAIL_1}    ${AM_VALID_PASSWORD}
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=3s
    Wait Until Element Is Visible    ${AM_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AM_OK_BTN}
    # Session 2 — 999999 directly triggers max attempts
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=3s
    Wait Until Element Is Visible    ${AM_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AM_OK_BTN}
    # Session 3 — 999999 directly triggers max attempts (triggers block)
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=3s
    Wait Until Element Is Visible    ${AM_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AM_OK_BTN}
    # Session 4 — attempt should show blocked error
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AM_BLOCKED_ERROR}    visible
    Click Element    ${AM_OK_BTN}

TC_M3.3_016 - Verify Email Blocked After 3 Unverified Sessions With Less Than Max Attempts Per Session
    [Documentation]    Using AM_BLOCK_EMAIL_2: initiate 3 Change Password OTP sessions,
    ...    entering 3 incorrect OTPs per session then exiting. After the 3rd session,
    ...    verify the 4th attempt shows a 60-minute block error.
    ...
    ...    Pre-conditions: AM_BLOCK_EMAIL_2 is registered and unblocked.
    ...    DESTRUCTIVE: AM_BLOCK_EMAIL_2 will be blocked for 60 minutes after this TC.
    [Tags]    M3.3.16    Negative    Destructive
    # Session 1 — 3 wrong OTPs then close
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}    ${AM_BLOCK_EMAIL_2}    ${AM_VALID_PASSWORD}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 2 — 3 wrong OTPs then close
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 3 — 3 wrong OTPs then close (triggers block)
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 4 — should show blocked error on Change Password button
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AM_BLOCKED_ERROR}    visible
    Click Element    ${AM_OK_BTN}

TC_M3.3_017 - Verify Email Blocked After 3 Abandoned OTP Sessions
    [Documentation]    Using AM_BLOCK_EMAIL_3: initiate 3 Change Password OTP sessions,
    ...    leaving the OTP field blank and closing each session without any attempt.
    ...    After the 3rd abandoned session (within 15 min), the 4th attempt should show block error.
    ...
    ...    Pre-conditions: AM_BLOCK_EMAIL_3 is registered and unblocked.
    ...    DESTRUCTIVE: AM_BLOCK_EMAIL_3 will be blocked for 60 minutes after this TC.
    [Tags]    M3.3.17    Negative    Destructive
    # Session 1 — open OTP screen then close without attempting
    Navigate To Change Password OTP Screen    ${AM_VALID_PASSWORD}    ${AM_CP_NEW_PASSWORD}    ${AM_BLOCK_EMAIL_3}    ${AM_VALID_PASSWORD}
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 2 — open OTP screen then close
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 3 — open OTP screen then close (triggers block)
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=10s
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${AM_VALID_PASSWORD}
    Input Text       ${AM_NEW_PWD_FIELD}        ${AM_CP_NEW_PASSWORD}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${AM_CP_NEW_PASSWORD}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Click Element    ${AM_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=10s
    # Session 4 — should show blocked error
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_CHANGE_PWD_BTN}    timeout=10s
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AM_BLOCKED_ERROR}    visible
    Click Element    ${AM_OK_BTN}


TC_M3.3_022 - Verify Block Counter Resets After Successful OTP Verification
    [Tags]    M3.3.22    Destructive    Session    Manual    Skipped
    Skip    Requires 3 unverified + 1 verified + 3 new unverified sessions (~20 min); run manually on device


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

TC_M3.1_003 - Verify Session Timeout Modal On Profile Screen After 5 Minutes Of Inactivity
    [Tags]    M3.1.3    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity wait; run manually on device

TC_M3.1_004 - Verify Session Timeout Modal On Profile Screen After Minimizing
    [Tags]    M3.1.4    Session    Manual    Skipped
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M3.1_005 - Verify Session Timeout Modal Is Still Visible On Profile Screen After Minimize And Restore
    [Tags]    M3.1.5    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M3.1_006 - Verify Session Remains Active While Interacting With Profile Screen
    [Tags]    M3.1.6    Session    Manual    Skipped
    Skip    Session keep-alive — requires continuous 8-minute interaction; run manually on device

TC_M3.1_007 - Verify Session Timeout Modal On My Profile Screen After 5 Minutes Of Inactivity
    [Tags]    M3.1.7    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity on My Profile screen; run manually on device

TC_M3.1_008 - Verify Session Timeout Modal On My Profile Screen After Minimizing
    [Tags]    M3.1.8    Session    Manual    Skipped
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M3.1_009 - Verify Session Timeout Modal Is Still Visible On My Profile Screen After Minimize And Restore
    [Tags]    M3.1.9    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M3.1_010 - Verify Session Timeout Resets On User Activity On My Profile Screen
    [Tags]    M3.1.10    Session    Manual    Skipped
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M3.2_003 - Verify Session Timeout Modal On Edit Account Screen After 5 Minutes Of Inactivity
    [Tags]    M3.2.3    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity on Edit Account screen; run manually on device

TC_M3.2_004 - Verify Session Timeout Modal On Edit Account Screen After Minimizing
    [Tags]    M3.2.4    Session    Manual    Skipped
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M3.2_005 - Verify Session Timeout Modal Is Still Visible On Edit Account Screen After Minimize And Restore
    [Tags]    M3.2.5    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M3.2_006 - Verify Session Timeout Resets On User Activity On Edit Account Screen
    [Tags]    M3.2.6    Session    Manual    Skipped
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M3.3_003 - Verify Session Timeout Modal On Change Password Screen After 5 Minutes Of Inactivity
    [Tags]    M3.3.3    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity on Change Password screen; run manually on device

TC_M3.3_004 - Verify Session Timeout Modal On Change Password Screen After Minimizing
    [Tags]    M3.3.4    Session    Manual    Skipped
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M3.3_005 - Verify Session Timeout Modal Is Still Visible On Change Password Screen After Minimize And Restore
    [Tags]    M3.3.5    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M3.3_006 - Verify Session Timeout Resets On User Activity On Change Password Screen
    [Tags]    M3.3.6    Session    Manual    Skipped
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M3.3_011 - Verify Validation Message For Expired OTP On Change Password
    [Tags]    M3.3.11    Session    Manual    Skipped
    Skip    OTP expiry — requires waiting 5+ minutes for OTP to expire; run manually on device

TC_M3.3_014 - Verify OTP Session Expiry Modal Before Reaching Max Attempts On Change Password
    [Tags]    M3.3.14    Session    Manual    Skipped
    Skip    Requires 5-minute OTP session expiry wait before max attempts; run manually on device

TC_M3.3_019 - Verify Change Password Resumes Successfully After 60-Minute Block Expires
    [Tags]    M3.3.19    Session    Manual    Skipped
    Skip    Requires 60-minute wait for block to expire; run manually on device

TC_M3.3_021 - Verify No Block When 3 Unverified Sessions Span More Than 15 Minutes
    [Tags]    M3.3.21    Session    Manual    Skipped
    Skip    Requires ~20-minute timing window across sessions; run manually on device

TC_M3.3_023 - Verify Session Timeout Modal On OTP Screen After 5 Minutes Of Inactivity
    [Tags]    M3.3.23    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity on Change Password OTP screen; run manually on device

TC_M3.3_024 - Verify Session Timeout Modal On OTP Screen After Minimizing
    [Tags]    M3.3.24    Session    Manual    Skipped
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M3.3_025 - Verify Session Timeout Modal Is Still Visible On OTP Screen After Minimize And Restore
    [Tags]    M3.3.25    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M3.3_026 - Verify Session Timeout Resets On User Activity On OTP Screen
    [Tags]    M3.3.26    Session    Manual    Skipped
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M3.3_032 - Verify Session Timeout Modal On New Password Set Screen After 5 Minutes Of Inactivity
    [Tags]    M3.3.32    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity on new password set screen; run manually on device

TC_M3.3_033 - Verify Session Timeout Modal On New Password Set Screen After Minimizing
    [Tags]    M3.3.33    Session    Manual    Skipped
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M3.3_034 - Verify Session Timeout Modal Is Still Visible On New Password Set Screen After Minimize And Restore
    [Tags]    M3.3.34    Session    Manual    Skipped
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M3.3_035 - Verify Session Timeout Resets On User Activity On New Password Set Screen
    [Tags]    M3.3.35    Session    Manual    Skipped
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

*** Keywords ***

Login With Credentials
    [Arguments]    ${email}    ${password}
    # Logs in from the Login screen (email + password → OTP → Home)
    # Assumes the Login screen is already active
    Input Text       xpath=//android.widget.EditText[@hint='Email Address']    ${email}
    Input Text       xpath=//android.widget.EditText[@hint='Password']         ${password}
    Click Element    accessibility_id=Sign in
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=30s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${AM_HOME_SCREEN}    timeout=30s
    Sleep    2s

Navigate To Profile Screen
    [Arguments]    ${email}=${AM_VALID_EMAIL}    ${password}=${AM_VALID_PASSWORD}
    # From Login screen: login → land on Home → tap Profile tab
    Login With Credentials    ${email}    ${password}
    Click Element    ${AM_PROFILE_TAB}
    Wait Until Element Is Visible    ${AM_MORE_DETAILS_BTN}    timeout=10s
    Sleep    2s

Navigate To My Profile Screen
    [Arguments]    ${email}=${AM_VALID_EMAIL}    ${password}=${AM_VALID_PASSWORD}
    # Login → Profile → tap "More Details" → My Profile screen
    Navigate To Profile Screen    ${email}    ${password}
    Click Element    ${AM_MORE_DETAILS_BTN}
    Wait Until Element Is Visible    ${AM_MY_PROFILE_SCREEN}    timeout=10s
    Sleep    2s

Navigate To Edit Account Screen
    [Arguments]    ${email}=${AM_VALID_EMAIL}    ${password}=${AM_VALID_PASSWORD}
    # Login → Profile → tap "Edit Profile" row → Edit Account screen
    Navigate To Profile Screen    ${email}    ${password}
    Click Element    ${AM_EDIT_PROFILE_BTN}
    Wait Until Element Is Visible    ${AM_EDIT_ACCOUNT_SCREEN}    timeout=10s
    Sleep    2s

Navigate To Change Password Screen
    [Arguments]    ${email}=${AM_VALID_EMAIL}    ${password}=${AM_VALID_PASSWORD}
    # Login → Profile → tap "Change Password" row → "Update Password" screen
    # NOTE: The row label says "Change Password" but the screen title is "Update Password"
    Navigate To Profile Screen    ${email}    ${password}
    Click Element    ${AM_CHANGE_PWD_BTN}
    Wait Until Element Is Visible    ${AM_CP_SCREEN}    timeout=20s
    Sleep    2s

Navigate To Change Password OTP Screen
    [Arguments]    ${current_pwd}    ${new_pwd}    ${email}=${AM_VALID_EMAIL}    ${password}=${AM_VALID_PASSWORD}
    # Full path: Login → Profile → Change Password → fill fields → Submit → OTP screen
    Navigate To Change Password Screen    ${email}    ${password}
    Input Text       ${AM_CURRENT_PWD_FIELD}    ${current_pwd}
    Input Text       ${AM_NEW_PWD_FIELD}        ${new_pwd}
    Input Text       ${AM_CONFIRM_PWD_FIELD}    ${new_pwd}
    Click Element    ${AM_CP_SUBMIT_BTN}
    Wait Until Element Is Visible    ${AM_OTP_SCREEN}    timeout=15s
    Sleep    2s


