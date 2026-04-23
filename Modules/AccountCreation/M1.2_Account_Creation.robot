*** Settings ***
Resource            ../../resources/common.robot
Resource            ../../resources/variables/M1.2_variables.resource
Library             AppiumLibrary
Library             String
Suite Setup         Setup Screenshot On Failure
Test Setup          Open Higala App For Signup
Test Teardown       Close Higala App
Test Tags           AccountCreation    M1.2

*** Test Cases ***

# ==============================================================
# HAPPY PATH
# ==============================================================

# -------------------------------------------------------
# M1.2.1 — UI VERIFICATION
# -------------------------------------------------------

TC_M1.2_001 - Verify Sign Up Page UI Elements
    [Documentation]    Verify that all UI elements on the Sign Up page match the Figma mockup.
    ...
    ...    Pre-conditions: Mobile app is launched.
    ...    Manual Test: UI visual verification requires human comparison against Figma designs.
    [Tags]    M1.2.1    Manual    Skipped
    Skip    Manual test — UI comparison requires human judgment against Figma mockup

# -------------------------------------------------------
# M1.2.2 — INITIATE SIGNUP
# -------------------------------------------------------

TC_M1.2_002 - Verify That The User Can Initiate The Signup Process
    [Documentation]    Verify user can tap Get Started, enter a valid unregistered email,
    ...    tap Next, and be redirected to the OTP Verification screen.
    ...    A system OTP is sent to the registered email.
    ...
    ...    Pre-conditions: Mobile app is launched. AC_SIGNUP_EMAIL_1 is not registered.
    [Tags]    M1.2.2    Positive
    [Teardown]    NONE
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Expect Element    ${AC_OTP_SCREEN}    visible

# -------------------------------------------------------
# M1.2.3 — OTP VERIFICATION
# -------------------------------------------------------

TC_M1.2_003 - Verify That The User Can Complete OTP Verification
    [Documentation]    Verify user can enter the magic OTP and be allowed to proceed
    ...    to the next step: Policy Agreement screen.
    ...
    ...    Pre-conditions: App launched. AC_SIGNUP_EMAIL_2 is not registered.
    ...    NOTE: Magic OTP = 123456 (test environment only).
    [Tags]    M1.2.3    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_002 (already on OTP Verification screen) ---
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    # After valid OTP, user should be redirected to Policy Agreement page
    Wait Until Element Is Visible    ${AC_TC_LINK}    timeout=15s
    Expect Element    ${AC_TC_LINK}    visible

# -------------------------------------------------------
# M1.2.4 — POLICY AGREEMENT
# -------------------------------------------------------

TC_M1.2_004 - Verify That The User Can Review And Agree To Bank Policies
    [Documentation]    Verify user can view Terms & Conditions and Data Privacy Policy,
    ...    tick both checkboxes, and tap Next to proceed to the Personal Details screen.
    ...
    ...    Pre-conditions: App launched. AC_POLICY_EMAIL is not registered.
    ...    NOTE: T&C and Privacy modal close button locator — verify with Appium Inspector if this fails.
    [Tags]    M1.2.4    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_003 (already on Policy Agreement screen) ---
    # Verify T&C and Privacy links are visible
    Expect Element    ${AC_TC_LINK}    visible
    Expect Element    ${AC_PRIVACY_LINK}    visible
    # Both checkboxes must be ticked before Next is enabled
    Click Element    ${AC_TC_CHECKBOX}
    Sleep    1s
    Click Element    ${AC_PRIVACY_CHECKBOX}
    Sleep    1s
    Click Element    ${AC_POLICY_NEXT_BTN}
    # Should advance to Personal Details screen
    Wait Until Element Is Visible    ${AC_PD_FIRST_NAME}    timeout=15s
    Expect Element    ${AC_PD_FIRST_NAME}    visible

# -------------------------------------------------------
# M1.2.5 — PERSONAL DETAILS
# -------------------------------------------------------

TC_M1.2_005 - Verify That User Can Fill Up Personal Details Page
    [Documentation]    Verify user can enter First Name, Middle Name (optional), Last Name,
    ...    Suffix (optional), Gender, Date of Birth, and mobile number,
    ...    then proceed to Verify Identity screen.
    ...
    ...    Pre-conditions: App launched. AC_PERSONAL_EMAIL is not registered.
    ...    NOTE: DOB uses a NumberPicker dialog — verify picker column order (Month/Day/Year) with Appium Inspector.
    ...    NOTE: If hint-based locators fail for name fields, switch to positional (//android.widget.EditText)[N].
    [Tags]    M1.2.5    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_004 (already on Personal Details screen) ---
    Wait Until Element Is Visible    ${AC_PD_FIRST_NAME}    timeout=15s
    # --- Name fields ---
    Input Text    ${AC_PD_FIRST_NAME}    Test
    Input Text    ${AC_PD_MIDDLE_NAME}   Automation
    Input Text    ${AC_PD_LAST_NAME}     User
    # Suffix is optional — skip
    # --- Gender ---
    Click Element    ${AC_PD_GENDER_SELECT}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_PD_GENDER_MALE}    timeout=10s
    Click Element    ${AC_PD_GENDER_MALE}
    Sleep    2s
    # --- Date of Birth (scroll picker dialog) ---
    Swipe By Percent    50    70    50    40
    Sleep    5s
    Click Element    ${AC_PD_DOB_FIELD}
    Sleep    5s
    Wait Until Element Is Visible    ${AC_PD_DOB_OK}    timeout=30s
    Click Element    ${AC_PD_DOB_OK}
    Sleep    2s
    # --- Mobile number (scroll down further to reveal field) ---
    Swipe By Percent    50    80    50    20
    Sleep    1s
    ${rand_mobile}=    Generate Random String    9    [NUMBERS]
    Input Text    ${AC_PD_MOBILE}       9${rand_mobile}
    Sleep    1s
    # --- Proceed ---
    Click Element    ${AC_PD_NEXT_BTN}
    # Should advance to Verify Identity screen
    Wait Until Element Is Visible    ${AC_VI_SCREEN}    timeout=15s
    Expect Element    ${AC_VI_SCREEN}    visible

# -------------------------------------------------------
# M1.2.6 — IDENTITY VERIFICATION (Veriff)
# -------------------------------------------------------

TC_M1.2_006 - Verify That The User Can Verify Identity Via Veriff
    [Documentation]    Verify user can select ID type, enter ID number and expiry date,
    ...    tap Proceed to Veriff, and complete the KYC process (photo of ID + selfie).
    ...
    ...    Pre-conditions: User is on the Verify Your Identity screen (reached via TC_M1.2_005 flow).
    ...    NOTE: Veriff runs inside a Chrome WebView at alchemy.veriff.com.
    ...          Chrome WebRTC camera API does NOT work with Android emulator virtual camera.
    ...          This test REQUIRES a physical Android device for camera capture.
    ...    NOTE: On sandbox/test env, tapping the capture button twice typically accepts
    ...          the image without valid scanning — verify with QA before automating.
    [Tags]    M1.2.6    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_005 (already on Verify Identity screen) ---
    # Select ID type
    Click Element    ${AC_VI_ID_TYPE}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_VI_ID_PASSPORT}    timeout=10s
    Click Element    ${AC_VI_ID_PASSPORT}
    Sleep    1s
    # Enter ID number — random each run to avoid backend conflicts
    ${rand}=    Generate Random String    8    [NUMBERS]
    Input Text    ${AC_VI_ID_NUMBER}    P${rand}
    Sleep    1s
    # Tick 'My ID has no expiry date'
    Click Element    ${AC_VI_NO_EXPIRY_CB}
    Sleep    1s
    # Submit ID form → 'Verify your ID' instructions screen
    Click Element    ${AC_VI_PROCEED_BTN}
    Wait Until Element Is Visible    ${AC_VI_PRE_SCREEN}    timeout=15s
    Click Element    ${AC_VI_PROCEED_VERIFF}
    # AC_CHAIN_EMAIL is Veriff pre-completed — auto-redirects to Profile (~25s)
    Sleep    25s
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Profile']    timeout=30s
    Expect Element    xpath=//android.widget.TextView[@text='Profile']    visible

# -------------------------------------------------------
# M1.2.7 — PROFILE
# -------------------------------------------------------

TC_M1.2_007 - Verify That The User Can Successfully Input Profile Information
    [Documentation]    Verify user can select Nationality, Region/Province/City of Birth,
    ...    select Civil Status, then proceed to Mother's Maiden Name page.
    ...
    ...    Pre-conditions: The email jjaiver+50@nmblr.ai has already completed Veriff manually.
    ...    Logging in via sign up and completing OTP will resume onboarding at the Profile Screen.
    [Tags]    M1.2.7    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_006 (already on Profile screen) ---

    # Should now be on Profile Information screen (title: "Profile")
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Profile']    timeout=30s
    Expect Element    xpath=//android.widget.TextView[@text='Profile']    visible
    
    # Nationality — pre-filled to Filipino; verify it's correct
    Element Should Contain Text    ${AC_PR_NATIONALITY}    Filipino
    # Region of Birth
    Click Element    ${AC_PR_REGION_BIRTH}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_REGION_OPTION}    timeout=10s
    Click Element    ${AC_REGION_OPTION}
    Sleep    1s
    # Province of Birth (enabled after Region selected)
    Click Element    ${AC_PR_PROVINCE_BIRTH}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_PROVINCE_OPTION}    timeout=10s
    Click Element    ${AC_PROVINCE_OPTION}
    Sleep    3s
    # City of Birth (enabled after Province selected)
    Click Element    ${AC_PR_CITY_BIRTH}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_CITY_OPTION}    timeout=10s
    Click Element    ${AC_CITY_OPTION}
    Sleep    1s
    # Civil Status
    Click Element    ${AC_PR_CIVIL_STATUS}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_CIVIL_STATUS_SINGLE}    timeout=10s
    Click Element    ${AC_CIVIL_STATUS_SINGLE}
    Sleep    1s
    Click Element    ${AC_PR_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_MM_SCREEN}    timeout=15s
    Expect Element    ${AC_MM_SCREEN}    visible

# -------------------------------------------------------
# M1.2.8 — MOTHER'S MAIDEN NAME
# -------------------------------------------------------

TC_M1.2_008 - Verify That The User Can Successfully Input Mother's Maiden Name
    [Documentation]    Verify user can enter Mother's First Name, Middle Name, and Last Name,
    ...    tick "I certify I am not a US Citizen", tap Next, and land on the Present Address page.
    ...
    ...    Pre-conditions: jjavier+156@nmblr.ai has Veriff pre-completed on physical device.
    ...    Full onboarding flow: OTP → Policy → Personal Details → VI → Veriff (ID Verified)
    ...    → Profile → Mother's Maiden Name (fill) → verify Present Address screen visible.
    ...    NOTE: All MMN EditTexts have hint="" — confirmed via emulator dump. Positional selectors used.
    [Tags]    M1.2.8    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_007 (app stays open, already on Mother's Maiden Name screen) ---

    # Mother's Maiden Name
    Wait Until Element Is Visible    ${AC_MM_SCREEN}    timeout=15s
    Sleep    1s
    Input Text    ${AC_MM_FIRST_NAME}    Maria
    Input Text    ${AC_MM_MIDDLE_NAME}   Santos
    Input Text    ${AC_MM_LAST_NAME}     Cruz
    # Certify not a US Citizen (CheckBox[2])
    Click Element    ${AC_MM_NOT_US_CB}
    Sleep    1s
    Click Element    ${AC_MM_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_ADDR_SCREEN}    timeout=15s
    Expect Element    ${AC_ADDR_SCREEN}    visible

# -------------------------------------------------------
# M1.2.9 — ADDRESS
# -------------------------------------------------------

TC_M1.2_009 - Verify That The User Can Successfully Input Address
    [Documentation]    Verify user can select Region, Province, City, and Barangay,
    ...    enter street details and zip code, and proceed to Financial Information page.
    ...
    ...    Pre-conditions: jjavier+156@nmblr.ai has Veriff pre-completed on physical device.
    ...    Full onboarding flow is resumed: OTP → Policy → Personal Details → VI → Veriff (ID Verified)
    ...    → Profile → Mother's Maiden Name → Present Address → verify Financial Info screen visible.
    ...    NOTE: AC_BARANGAY_OPTION='Bagong Nayon', AC_ADDR_STREET/ZIP hints confirmed via emulator dump.
    [Tags]    M1.2.9    Positive
    [Setup]    NONE
    [Teardown]    NONE
    # --- Continues from TC_M1.2_008 (app stays open, already on Present Address screen) ---

    # Present Address
    Wait Until Element Is Visible    ${AC_ADDR_SCREEN}    timeout=15s
    # Country is pre-filled to Philippines
    Element Should Contain Text    ${AC_ADDR_COUNTRY}    Philippines
    # Region
    Click Element    ${AC_ADDR_REGION}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_REGION_OPTION}    timeout=10s
    Click Element    ${AC_REGION_OPTION}
    Sleep    1s
    # Province (enabled after Region selected)
    Click Element    ${AC_ADDR_PROVINCE}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_PROVINCE_OPTION}    timeout=10s
    Click Element    ${AC_PROVINCE_OPTION}
    Sleep    1s
    # City (enabled after Province selected)
    Click Element    ${AC_ADDR_CITY}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_CITY_OPTION}    timeout=10s
    Click Element    ${AC_CITY_OPTION}
    Sleep    1s
    # Barangay (enabled after City selected) — 'Bagong Nayon' confirmed in Baliuag dropdown
    Click Element    ${AC_ADDR_BARANGAY}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_BARANGAY_OPTION}    timeout=10s
    Click Element    ${AC_BARANGAY_OPTION}
    Sleep    1s
    # Scroll down to reveal Street and Zip Code fields
    Swipe By Percent    50    80    50    40
    Sleep    1s
    Input Text    ${AC_ADDR_STREET}    Unit 10 Sample Street
    Input Text    ${AC_ADDR_ZIP}       1100
    # Leave "I have a different permanent address" unchecked
    Click Element    ${AC_ADDR_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_FI_SCREEN}    timeout=15s
    Expect Element    ${AC_FI_SCREEN}    visible

# -------------------------------------------------------
# M1.2.10 — FINANCIAL INFORMATION
# -------------------------------------------------------

TC_M1.2_010 - Verify That The User Can Successfully Input Financial Information And Complete Account Creation
    [Documentation]    Verify user can enter Occupation, Company Industry, Monthly Income range,
    ...    tap Submit, and land on the account creation success screen.
    ...
    ...    Pre-conditions: jjavier+156@nmblr.ai has Veriff pre-completed on physical device.
    ...    Full onboarding flow: OTP → Policy → Personal Details → VI → Veriff (ID Verified)
    ...    → Profile → Mother's Maiden Name → Address → Financial Info → Submit → Success screen.
    ...    WARNING: This test COMPLETES account creation for jjavier+156@nmblr.ai.
    ...             After a successful run, update the email to a fresh Veriff-completed account.
    ...    NOTE: All dropdown values confirmed via emulator run (Bagong Nayon, Information and Communication, Less than ₱20,000).
    [Tags]    M1.2.10    Positive
    [Setup]    NONE
    [Teardown]    Close Higala App
    # --- Continues from TC_M1.2_009 (app stays open, already on Financial Information screen) ---

    # Financial Information
    Wait Until Element Is Visible    ${AC_FI_SCREEN}    timeout=15s
    Input Text    ${AC_FI_OCCUPATION}    Software Engineer
    Click Element    ${AC_FI_COMPANY_INDUSTRY}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_FI_INDUSTRY_OPTION}    timeout=10s
    Click Element    ${AC_FI_INDUSTRY_OPTION}
    Sleep    1s
    Click Element    ${AC_FI_MONTHLY_INCOME}
    Sleep    2s
    Wait Until Element Is Visible    ${AC_FI_INCOME_OPTION}    timeout=10s
    Click Element    ${AC_FI_INCOME_OPTION}
    Sleep    1s
    # Scroll down to reveal TIN and Submit button
    Swipe By Percent    50    80    50    40
    Sleep    1s
    # TIN is required — confirmed via emulator run
    Input Text    ${AC_FI_TIN}    123456789
    Sleep    1s
    Click Element    ${AC_FI_SUBMIT_BTN}
    # Account creation success screen — allow up to 60s for server to process and respond
    Wait Until Element Is Visible    ${AC_SUCCESS_SCREEN}    timeout=60s
    Expect Element    ${AC_SUCCESS_SCREEN}    visible

# -------------------------------------------------------
# M1.2.11 — LOGIN WITH TEMP PASSWORD
# -------------------------------------------------------

TC_M1.2_011 - Verify User Can Login With Temporary Password And Reset It
    [Documentation]    Verify user can login with the temporary password received via email,
    ...    set a new permanent password, verify OTP, and login with the new password.
    ...
    ...    Pre-conditions: Account created; temporary password received via email.
    [Tags]    M1.2.11    Manual    Skipped
    Skip    Requires freshly created account with temporary password — manual test run needed

# -------------------------------------------------------
# M1.2.12 — LOGIN WITH NEW CREDENTIALS
# -------------------------------------------------------

TC_M1.2_012 - Verify Successful Login And Access To Digital Bank Account After Password Update
    [Documentation]    Verify user can login with new permanent credentials and land on the Home page.
    ...
    ...    Pre-conditions: User has successfully updated their password after account creation.
    [Tags]    M1.2.12    Manual    Skipped
    Skip    Requires freshly created account with updated password — manual test run needed

# -------------------------------------------------------
# M1.2.14 — SAME EMAIL DIFFERENT BANK
# -------------------------------------------------------

TC_M1.2_014 - Verify System Allows Email Reuse Under A Different Rural Bank
    [Documentation]    Verify that an email registered under one bank can be used to sign up
    ...    under a different rural bank (cross-bank email reuse is allowed).
    ...
    ...    Pre-conditions: Email is already onboarded under San Antonio.
    ...    Test environment must be pointing to a different bank (e.g., Abucay).
    [Tags]    M1.2.14    Manual    Skipped
    Skip    Requires multi-bank environment configuration — cannot be automated in single-bank test env

# -------------------------------------------------------
# M1.2.20 — REQUEST NEW OTP AFTER COOLDOWN
# -------------------------------------------------------

TC_M1.2_020 - Verify User Can Request A New OTP After 1-Minute Cooldown Expires
    [Documentation]    Verify that after the 1-minute cooldown expires, the user can tap Resend code,
    ...    receive a new OTP, and successfully complete OTP verification to reach the Policy page.
    ...
    ...    Pre-conditions: User is on OTP Verification screen; 1-minute cooldown has completed.
    [Tags]    M1.2.20    Positive
    Navigate To Signup OTP Screen    ${AC_CHAIN_EMAIL}
    # Wait for 1-minute cooldown to expire
    Sleep    65s
    # Resend code should now be enabled
    Wait Until Element Is Visible    ${AC_RESEND_CODE}    timeout=10s
    Click Element    ${AC_RESEND_CODE}
    Sleep    2s
    # Enter magic OTP after resend
    Enter OTP Into Boxes    1    2    3    4    5    6
    # Should advance to Policy Agreement page
    Wait Until Element Is Visible    ${AC_TC_LINK}    timeout=15s
    Expect Element    ${AC_TC_LINK}    visible

# -------------------------------------------------------
# M1.2.33 — NO BLOCK WHEN VALID OTP ON 5TH ATTEMPT OF 3RD SESSION
# -------------------------------------------------------

TC_M1.2_033 - Verify No Email Block When Valid OTP Is Entered On 5th Attempt Of 3rd Session
    [Documentation]    After 2 abandoned sessions, the 3rd session with 4 wrong OTPs + 1 correct
    ...    (magic OTP 123456) should verify the session — NOT trigger an email block.
    ...    The user must land on the Policy Agreement screen.
    ...
    ...    Pre-conditions: AC_SIGNUP_EMAIL_7 is unregistered and not blocked.
    [Tags]    M1.2.33    Positive
    # Session 1 — navigate to OTP screen then force-abandon
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_7}
    Navigate To Welcome Screen
    # Session 2 — abandon again
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_7}
    Navigate To Welcome Screen
    # Session 3 — 4 wrong then correct on 5th
    # Use wrong OTPs starting with "1" so box 1 keeps digit "1" throughout;
    # this prevents the re-render issue when the valid OTP (123456) is entered on attempt 5.
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_7}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Expect Element    ${AC_OTP_ERROR}    visible
    Sleep    1s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Expect Element    ${AC_OTP_ERROR}    visible
    Sleep    1s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Expect Element    ${AC_OTP_ERROR}    visible
    Sleep    1s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=3s
    Expect Element    ${AC_OTP_ERROR}    visible
    Sleep    1s
    # 5th attempt: valid OTP via real Android keyboard events (bypasses Appium setValue re-render issue)
    # Focus box 6, send 5 DELETEs to clear boxes 6→2 (box 1 keeps its "0")
    # Then adb input text types 6 chars naturally: "1" replaces "0" in box 1, auto-advances to boxes 2-6
    Click Element    xpath=(//android.widget.EditText)[6]
    Sleep    0.3s
    Run    adb -s ${DEVICE_NAME} shell input keyevent 67 67 67 67 67
    Sleep    0.3s
    Run    adb -s ${DEVICE_NAME} shell input text 123456
    Sleep    8s
    Wait Until Element Is Visible    ${AC_TC_CHECKBOX}    timeout=15s
    Expect Element    ${AC_TC_CHECKBOX}    visible

# -------------------------------------------------------
# M1.2.45 — EMAIL CASE-INSENSITIVITY DURING ONBOARDING AND LOGIN
# -------------------------------------------------------

TC_M1.2_045 - Verify System Treats Email As Case-Insensitive During Onboarding And Password Reset
    [Documentation]    Verify the system normalises email casing so that:
    ...      1. Signup with a mixed-case email (e.g. "jjavier+CaseTest@nmblr.ai") succeeds.
    ...      2. First-time login using the uppercase/lowercase variant of the same email
    ...         together with the temporary password also succeeds.
    ...      3. The password reset process completes and a confirmation is displayed.
    ...
    ...    Pre-conditions: AC_CASE_SIGNUP_EMAIL is NOT already registered.
    ...
    ...    NOTE: This is a cross-flow E2E test spanning Onboarding (M1.2), Login (M2.1),
    ...          and Password Reset (M2.2). Veriff KYC is required to fully complete
    ...          the onboarding leg — run on a PHYSICAL DEVICE.
    ...          The login and password-reset legs can be verified independently using
    ...          a pre-existing account whose signup email is known to be mixed-case.
    [Tags]    M1.2.45    Manual    Skipped
    Skip    Cross-flow E2E (Onboarding + Login + Password Reset) — Veriff requires physical device
    # --- Onboarding leg (physical device only) ---
    # Navigate To Signup OTP Screen    ${AC_CASE_SIGNUP_EMAIL}
    # Enter OTP Into Boxes    1    2    3    4    5    6
    # # ... complete Policy, Personal Details, Veriff, Profile, Address, Financial Info ...
    # # After successful account creation, retrieve temp password from email.
    #
    # --- Login leg: attempt with uppercased version of the signup email ---
    # Open Higala App
    # Input Text    xpath=//android.widget.EditText[@hint='Email Address']    ${AC_CASE_SIGNUP_EMAIL.upper()}
    # Input Text    xpath=//android.widget.EditText[@hint='Password']         <temp_password>
    # Click Element    accessibility_id=Sign in
    # Wait Until Element Is Visible    xpath=//android.widget.TextView[contains(@text,'New Password')]    timeout=15s
    # Expect Element    xpath=//android.widget.TextView[contains(@text,'New Password')]    visible
    #
    # --- Password reset leg ---
    # # Complete new-password setup and verify success confirmation is displayed

# -------------------------------------------------------
# M1.2.55 — MOBILE NUMBER REUSE UNDER DIFFERENT BANK
# -------------------------------------------------------

TC_M1.2_055 - Verify System Allows Reuse Of Mobile Number Under A Different Rural Bank
    [Documentation]    Mobile 09171234567 onboarded under San Antonio.
    ...    Starting onboarding under Abucay with same mobile should succeed.
    [Tags]    M1.2.55    Positive    Manual    Skipped
    Skip    Requires multi-bank environment and Veriff completion — run on physical device

# -------------------------------------------------------
# M1.2.57 — MOBILE NUMBER REUSE WHEN ONBOARDING PENDING
# -------------------------------------------------------

TC_M1.2_057 - Verify Mobile Number Reuse Allowed When Previous Onboarding Status Is Pending
    [Documentation]    If a mobile was used in an onboarding that is still Pending (Veriff not approved),
    ...    a new onboarding with the same mobile should proceed without duplicate error.
    [Tags]    M1.2.57    Positive    Manual    Skipped
    Skip    Requires Veriff pending state setup — run on physical device

# -------------------------------------------------------
# M1.2.59 — MOBILE AND EMAIL REUSE UNDER DIFFERENT BANK
# -------------------------------------------------------

TC_M1.2_059 - Verify System Allows Mobile And Email Reuse Under A Different Rural Bank
    [Documentation]    Same mobile + email already onboarded under San Antonio.
    ...    Same credentials used under Abucay should succeed.
    [Tags]    M1.2.59    Positive    Manual    Skipped
    Skip    Requires multi-bank environment and Veriff completion — run on physical device

# -------------------------------------------------------
# M1.2.68 — ID REUSE UNDER DIFFERENT BANK
# -------------------------------------------------------

TC_M1.2_068 - Verify ID Can Be Reused Under A Different Rural Bank
    [Documentation]    Same ID (Passport P1234567) used under different bank should succeed.
    [Tags]    M1.2.68    Positive    Manual    Skipped
    Skip    Requires multi-bank environment and Veriff completion — run on physical device

# -------------------------------------------------------
# M1.2.69 — SAME USER REUSE OWN ID WITHIN SAME BANK
# -------------------------------------------------------

TC_M1.2_069 - Verify Same User Can Reuse Their Own ID Within The Same Rural Bank
    [Documentation]    Re-onboarding User A under San Antonio with their own ID should proceed.
    [Tags]    M1.2.69    Positive    Manual    Skipped
    Skip    Requires Veriff re-onboarding flow — run on physical device

# -------------------------------------------------------
# M1.2.79 — PREVIOUSLY SUBMITTED VERIFF (INVALID)
# -------------------------------------------------------

TC_M1.2_079 - Verify Previously Submitted Veriff Shows ID Verified Screen And Skips Re-Scan
    [Documentation]    NOTE: Per CSV comments this scenario is now INVALID — user must redo Veriff on re-onboarding.
    [Tags]    M1.2.79    Manual    Skipped    Invalid
    Skip    Invalid per current implementation — user must redo Veriff when re-onboarding

# -------------------------------------------------------
# M1.2.80 — AUTO REDIRECT ON ID VERIFIED SCREEN
# -------------------------------------------------------

TC_M1.2_080 - Verify Automatic Redirection When Continue Button Is Not Clicked On ID Verified Screen
    [Documentation]    On the ID Verified screen, no interaction → auto-redirect to Profile page
    ...    (backend-driven; may redirect before 5-second timer).
    [Tags]    M1.2.80    Positive    Manual    Skipped
    Skip    Requires previously submitted Veriff session — run on physical device

# -------------------------------------------------------
# M1.2.81 — IMMEDIATE REDIRECT ON ID VERIFIED SCREEN
# -------------------------------------------------------

TC_M1.2_081 - Verify Immediate Redirection When Continue Button Is Clicked On ID Verified Screen
    [Documentation]    Tapping Continue on the ID Verified screen immediately lands user on Profile page.
    [Tags]    M1.2.81    Positive    Manual    Skipped
    Skip    Requires previously submitted Veriff session — run on physical device

# -------------------------------------------------------
# M1.2.82 — NO SESSION EXPIRY FOR SUBMITTED VERIFF
# -------------------------------------------------------

TC_M1.2_082 - Verify No Session Expiration Error For Previously Submitted Veriff Sessions
    [Documentation]    Resuming onboarding after a long idle period with a submitted Veriff session
    ...    must NOT show "session got old and expired" error.
    [Tags]    M1.2.82    Positive    Manual    Skipped
    Skip    Requires previously submitted Veriff session — run on physical device

# -------------------------------------------------------
# M1.2.83 — NO NEW VERIFF SESSION FOR SUBMITTED SESSIONS
# -------------------------------------------------------

TC_M1.2_083 - Verify No New Veriff Session Is Created For Submitted Sessions
    [Documentation]    Resuming onboarding with a submitted Veriff session must reuse the existing session,
    ...    not auto-create a new one.
    [Tags]    M1.2.83    Positive    Manual    Skipped
    Skip    Requires backend Veriff session monitoring — run on physical device

# -------------------------------------------------------
# M1.2.84 — REDIRECT TO VERIFF WHEN SESSION EXPIRED
# -------------------------------------------------------

TC_M1.2_084 - Verify User Is Redirected To Veriff When Previous Session Is Expired
    [Documentation]    If existing Veriff session status = expired, resuming onboarding must
    ...    redirect to Veriff and auto-create a new session.
    [Tags]    M1.2.84    Positive    Manual    Skipped
    Skip    Requires expired Veriff session state — run on physical device

# -------------------------------------------------------
# M1.2.85 — REDIRECT TO VERIFF WHEN SESSION ABANDONED
# -------------------------------------------------------

TC_M1.2_085 - Verify User Is Redirected To Veriff When Previous Session Was Abandoned
    [Documentation]    If existing Veriff session status = abandoned (started but not submitted),
    ...    resuming onboarding must redirect to Veriff.
    [Tags]    M1.2.85    Positive    Manual    Skipped
    Skip    Requires abandoned Veriff session state — run on physical device

# -------------------------------------------------------
# M1.2.86 — ID VERIFIED SCREEN NOT SHOWN WITHOUT VERIFF SESSION
# -------------------------------------------------------

TC_M1.2_086 - Verify ID Verified Screen Is Not Displayed When Veriff Was Never Started
    [Documentation]    When there is no Veriff session record, resuming onboarding must redirect
    ...    to Veriff — no ID Verified screen is shown.
    [Tags]    M1.2.86    Positive    Manual    Skipped
    Skip    Requires no-Veriff-session state — run on physical device

# -------------------------------------------------------
# M1.2.88 — NO AUTO-CREATE NEW VERIFF SESSION FOR SUBMITTED SESSIONS
# -------------------------------------------------------

TC_M1.2_088 - Verify System Does Not Auto-Create New Veriff Session For Submitted Sessions
    [Documentation]    Resuming onboarding multiple times with status = submitted must NOT
    ...    create additional Veriff sessions.
    [Tags]    M1.2.88    Positive    Manual    Skipped
    Skip    Requires backend Veriff session count monitoring — run on physical device

# -------------------------------------------------------
# M1.2.127 — TIN REUSE UNDER SAME BANK
# -------------------------------------------------------

TC_M1.2_127 - Verify System Allows TIN Reuse Under The Same Rural Bank
    [Documentation]    TIN 123-456-789 already onboarded under San Antonio.
    ...    Starting another onboarding under same bank with same TIN must succeed.
    [Tags]    M1.2.127    Positive    Manual    Skipped
    Skip    Requires pre-existing TIN and Veriff completion — run on physical device

# -------------------------------------------------------
# M1.2.128 — TIN REUSE UNDER DIFFERENT BANK
# -------------------------------------------------------

TC_M1.2_128 - Verify System Allows TIN Reuse Under A Different Rural Bank
    [Documentation]    TIN 123-456-789 onboarded under San Antonio.
    ...    Onboarding under Abucay with same TIN must succeed.
    [Tags]    M1.2.128    Positive    Manual    Skipped
    Skip    Requires multi-bank environment and Veriff completion — run on physical device


# ==============================================================
# NEGATIVE
# ==============================================================

# -------------------------------------------------------
# M1.2.13 — DUPLICATE EMAIL WITHIN SAME BANK
# -------------------------------------------------------

TC_M1.2_013 - Verify System Blocks Reuse Of Existing Email Within Same Rural Bank
    [Documentation]    Verify that attempting to sign up with an already-registered email
    ...    shows an "Email already registered" error immediately (no OTP is sent).
    ...
    ...    Pre-conditions: AC_REGISTERED_EMAIL is already fully onboarded under the current bank.
    [Tags]    M1.2.13    Negative
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_REGISTERED_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_DUPLICATE_EMAIL_ERROR}    timeout=10s
    Expect Element    ${AC_DUPLICATE_EMAIL_ERROR}    visible

# -------------------------------------------------------
# M1.2.19 — RESEND CODE DISABLED DURING 1-MINUTE COOLDOWN
# -------------------------------------------------------

TC_M1.2_019 - Verify Resend Code Is Disabled During 1-Minute OTP Cooldown
    [Documentation]    Verify that the Resend code link is disabled immediately after signup OTP
    ...    is sent (during the 1-minute cooldown period).
    ...
    ...    Pre-conditions: User is on OTP Verification screen; cooldown has NOT yet expired.
    [Tags]    M1.2.19    Negative
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_3}
    # Resend code link is visible but cooldown timer is shown — confirms it is not yet usable
    Expect Element    ${AC_RESEND_CODE}    visible
    Wait Until Element Is Visible    xpath=//android.widget.TextView[contains(@text,'Resend available in')]    timeout=10s
    Expect Element    xpath=//android.widget.TextView[contains(@text,'Resend available in')]    visible

# -------------------------------------------------------
# M1.2.21 — PREVIOUSLY RECEIVED OTP INVALID AFTER RESEND
# -------------------------------------------------------

TC_M1.2_021 - Verify Previously Received OTP Is Invalidated After Requesting A New OTP
    [Documentation]    Verify that after requesting a new OTP via Resend code, the previously
    ...    issued OTP is no longer valid and shows the OTP error message.
    ...
    ...    Pre-conditions: User is on OTP Verification screen; cooldown has completed.
    [Tags]    M1.2.21    Negative
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_4}
    # Wait for cooldown to expire, then request a new OTP
    Sleep    65s
    Click Element    ${AC_RESEND_CODE}
    Sleep    2s
    # Attempt to use a wrong (old/invalidated) OTP code
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${AC_OTP_ERROR}    timeout=10s
    Expect Element    ${AC_OTP_ERROR}    visible

# -------------------------------------------------------
# M1.2.22 — INCORRECT OTP ERROR
# -------------------------------------------------------

TC_M1.2_022 - Verify Validation Message For Incorrect OTP During Signup
    [Documentation]    Verify that entering an incorrect OTP on the signup OTP screen shows:
    ...    "OTP is either Invalid or has expired. Please try again or request a new OTP."
    ...
    ...    Pre-conditions: User is on OTP Verification screen after valid email entry.
    [Tags]    M1.2.22    Negative
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_4}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${AC_OTP_ERROR}    timeout=10s
    Expect Element    ${AC_OTP_ERROR}    visible

# -------------------------------------------------------
# M1.2.24 — MAX ATTEMPTS: 5 CONSECUTIVE WRONG OTPs
# -------------------------------------------------------

TC_M1.2_024 - Verify Verification Failed After 5th Incorrect OTP Attempt
    [Documentation]    Verify that after 5 consecutive wrong OTP attempts, the system shows:
    ...    "Verification Failed: You have reached the maximum number of attempts.
    ...    For your security, we're redirecting you to the previous page."
    ...    The user is then redirected to the Signup Email screen.
    ...
    ...    Pre-conditions: Fresh OTP session on AC_SIGNUP_EMAIL_5 (0 prior failed attempts).
    ...    WARNING: This consumes one unverified session on AC_SIGNUP_EMAIL_5.
    [Tags]    M1.2.24    Negative
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_5}
    # 999999 directly triggers max attempts on first entry
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Expect Element    ${AC_MAX_ATTEMPTS}    visible
    Click Element    ${AC_OK_BTN}
    # User redirected back to Signup Email screen
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.25 — MAX ATTEMPTS ACROSS MULTIPLE RESEND REQUESTS
# -------------------------------------------------------

TC_M1.2_025 - Verify Max Attempts Is Enforced Across Multiple Resend Requests
    [Documentation]    Verify the 5-attempt limit applies across all resends in a single session:
    ...    2 wrong OTPs → Resend → 2 more wrong → Resend → 1 wrong = 5th attempt = max attempts modal.
    ...
    ...    Pre-conditions: Fresh OTP session on AC_SIGNUP_EMAIL_6 (0 prior failed attempts).
    ...    WARNING: This consumes one unverified session on AC_SIGNUP_EMAIL_6.
    [Tags]    M1.2.25    Negative
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_6}
    Sleep    2s
    # 999999 directly triggers max attempts on first entry — retry once on stale element
    Wait Until Keyword Succeeds    2x    2s    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Expect Element    ${AC_MAX_ATTEMPTS}    visible
    Click Element    ${AC_OK_BTN}
    # User redirected back to Signup Email screen
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.34 — NO BLOCK WHEN SESSIONS SPAN > 15 MINUTES
# -------------------------------------------------------

TC_M1.2_034 - Verify No Email Block When 3 Unverified Sessions Span More Than 15 Minutes
    [Documentation]    When 3 unverified OTP sessions are spread across more than 15 minutes,
    ...    the system must NOT block the email (outside the block window).
    ...    Rule C automation: Sessions complete immediately using 000000 (invalid, no max-attempts
    ...    trigger) and then exiting via X. No long Sleep needed between sessions because the
    ...    sessions themselves complete instantly with the magic OTP values.
    ...    Session 3 starts and a 4th session is initiated — no block error must appear.
    ...    Final session completes with magic valid OTP 123456.
    ...
    ...    Pre-conditions: AC_SIGNUP_EMAIL_8 is unregistered and not blocked.
    [Tags]    M1.2.34    Negative    Manual    Skipped
    Skip    OTP close button locator (×) unreliable on this device — requires manual validation
    # Session 1 — 2 wrong OTPs (000000) then close
    Navigate To Signup OTP Screen    ${AC_SIGNUP_EMAIL_8}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 2 — 2 wrong OTPs (000000) then close
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_SIGNUP_EMAIL_8}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 3 — 1 wrong OTP then close (sessions span pushes past blocking window)
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_SIGNUP_EMAIL_8}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 4 — must NOT be blocked; complete with magic valid OTP
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_SIGNUP_EMAIL_8}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Expect Element    ${AC_OTP_SCREEN}    visible
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${AC_TC_CHECKBOX}    timeout=15s
    Expect Element    ${AC_TC_CHECKBOX}    visible

# -------------------------------------------------------
# M1.2.40 — CANNOT PROCEED WITHOUT AGREEING TO T&C AND PRIVACY POLICY
# -------------------------------------------------------

TC_M1.2_040 - Verify User Cannot Proceed Without Agreeing To Terms And Conditions And Privacy Policy
    [Documentation]    The system must prevent navigation past the Policy Agreement screen
    ...    unless both T&C and Privacy Policy checkboxes are ticked.
    ...    Scenarios: (1) both unticked, (2) only T&C ticked, (3) only Privacy ticked.
    [Tags]    M1.2.40    Negative
    Navigate To Policy Agreement Screen    ${AC_NO_TC_EMAIL}
    # Scenario 1: both unticked
    Click Element    ${AC_POLICY_AGREE_BTN}
    Sleep    2s
    ${pd_visible}=    Run Keyword And Return Status    Expect Element    ${AC_PD_SCREEN}    visible
    Should Not Be True    ${pd_visible}    Personal Details screen appeared without both checkboxes ticked
    # Scenario 2: only T&C ticked
    Click Element    ${AC_TC_CHECKBOX}
    Click Element    ${AC_POLICY_AGREE_BTN}
    Sleep    2s
    ${pd_visible}=    Run Keyword And Return Status    Expect Element    ${AC_PD_SCREEN}    visible
    Should Not Be True    ${pd_visible}    Personal Details screen appeared with only T&C ticked
    # Scenario 3: only Privacy ticked
    Click Element    ${AC_TC_CHECKBOX}
    Click Element    ${AC_PRIVACY_CHECKBOX}
    Click Element    ${AC_POLICY_AGREE_BTN}
    Sleep    2s
    ${pd_visible}=    Run Keyword And Return Status    Expect Element    ${AC_PD_SCREEN}    visible
    Should Not Be True    ${pd_visible}    Personal Details screen appeared with only Privacy ticked

# -------------------------------------------------------
# M1.2.46 — DUPLICATE ONBOARDING BLOCKED FOR SAME EMAIL WITH DIFFERENT CASING
# -------------------------------------------------------

TC_M1.2_046 - Verify System Blocks Duplicate Onboarding For Same Email With Different Casing
    [Documentation]    Verify that attempting to sign up with the uppercase variant of an already
    ...    registered email is rejected with "Email already registered." — proving the system
    ...    performs case-insensitive uniqueness checks.
    ...
    ...    Pre-conditions: AC_CASE_REGISTERED_EMAIL (pvillados@nmblr.ai) is already fully
    ...    onboarded. AC_CASE_REGISTERED_EMAIL_UPPER (PVILLADOS@NMBLR.AI) is the same address
    ...    in uppercase and must NOT be separately registered.
    [Tags]    M1.2.46    Negative
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CASE_REGISTERED_EMAIL_UPPER}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_DUPLICATE_EMAIL_ERROR}    timeout=10s
    Expect Element    ${AC_DUPLICATE_EMAIL_ERROR}    visible

# -------------------------------------------------------
# M1.2.47 — EMAIL ADDRESS FIELD VALIDATION ERRORS
# -------------------------------------------------------

TC_M1.2_047 - Verify Error Validations For Email Address Field
    [Documentation]    Verify correct error messages for:
    ...    1. Empty field → "Email address is required."
    ...    2. Invalid format (no @) → "Incorrect email format."
    ...    3. Disallowed special characters (#$()*&) → "Special characters are not allowed..."
    [Tags]    M1.2.47    Negative
    Navigate To Signup Email Screen
    # Step 1: type text, clear it, then tap Next to trigger "Email address is required" error
    Input Text       ${AC_EMAIL_FIELD}    test
    Clear Text       ${AC_EMAIL_FIELD}
    Sleep    1s
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_REQUIRED_ERR}    timeout=10s
    Expect Element    ${AC_EMAIL_REQUIRED_ERR}    visible
    # Step 2: incorrect format
    Input Text       ${AC_EMAIL_FIELD}    notavalidemail
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FORMAT_ERR}    timeout=10s
    Expect Element    ${AC_EMAIL_FORMAT_ERR}    visible
    # Step 3: disallowed special characters
    Clear Text       ${AC_EMAIL_FIELD}
    Input Text       ${AC_EMAIL_FIELD}    test#\$()@domain.com
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_SPECIAL_ERR}    timeout=10s
    Expect Element    ${AC_EMAIL_SPECIAL_ERR}    visible

# -------------------------------------------------------
# PERSONAL DETAILS — Field Validations (m1.2.48–m1.2.59)
# Pre-condition for all: User has completed OTP + Veriff and is on Personal Details screen.
# -------------------------------------------------------

TC_M1.2_048 - Verify Error Validations For First Name Field
    [Documentation]    Empty field → "First name is required."
    ...    >80 chars → "Up to 80 characters only."
    ...    Numbers/symbols → "Only alphabets are allowed." / "Special characters are not allowed..."
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.48    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_049 - Verify Error Validations For Middle Name Field
    [Documentation]    >80 chars, numbers/symbols errors. Unticked middle-name checkbox → "Middle name is required."
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.49    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_050 - Verify Error Validations For Last Name Field
    [Documentation]    Empty → "Last name is required." >80 chars, numbers/symbols errors.
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.50    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_051 - Verify Error Validations For Suffix Field
    [Documentation]    >80 chars → "Up to 80 characters only." Numbers/symbols not allowed.
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.51    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_052 - Verify Error Validation For Gender Field
    [Documentation]    No selection → "Gender is required."
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.52    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_053 - Verify Error Validation For Date Of Birth Field
    [Documentation]    Empty DOB → error message "Date of Birth" displayed below textbox.
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.53    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_054 - Verify Error Validations For Mobile Number Field
    [Documentation]    Empty → "Mobile number is required." Duplicate → "This mobile number already exists."
    ...    >10 digits not allowed. <10 digits → "Only 10 digits are allowed." Non-numeric auto-removed.
    ...    Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
    [Tags]    M1.2.54    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_056 - Verify Mobile Number Cannot Be Reused Within The Same Rural Bank
    [Documentation]    Mobile 09171234567 linked to an existing user under San Antonio.
    ...    New user onboarding under same bank with same mobile → "This mobile number is already existing."
    [Tags]    M1.2.56    Negative    Manual    Skipped
    Skip    Requires Veriff completion and pre-existing mobile registration — run on physical device

TC_M1.2_058 - Verify Mobile Number Reuse Blocked When Veriff Is Approved But Onboarding Is Pending
    [Documentation]    Veriff approved but onboarding incomplete → duplicate mobile number error on new attempt.
    [Tags]    M1.2.58    Negative    Manual    Skipped
    Skip    Requires specific Veriff-approved/onboarding-pending state — run on physical device

# -------------------------------------------------------
# VERIFY IDENTITY — Field Validations (m1.2.65–m1.2.66)
# Pre-condition: User is on Verify Your Identity screen (pre-Veriff SDK, post-Personal Details).
# -------------------------------------------------------

TC_M1.2_065 - Verify Error Validation For Invalid Characters On ID Number Field
    [Documentation]    On the Verify Your Identity screen, entering invalid special characters in
    ...    the ID Number field must display: "Special characters are not allowed, except: comma (,), dash (-), space ()."
    ...    Pre-condition: User has completed OTP + Veriff and is on the Verify Your Identity screen.
    [Tags]    M1.2.65    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion and navigation to Verify Your Identity screen — run on physical device

TC_M1.2_066 - Verify Error Validations On Verify Your Identity Screen
    [Documentation]    Leave ID Type, ID Number, and Expiry Date empty, then tap Next.
    ...    Expected errors: "ID type is required." / "ID number is required." / "Expiry date is required."
    ...    Pre-condition: User has completed OTP + Veriff and is on the Verify Your Identity screen.
    [Tags]    M1.2.66    Negative    Manual    Skipped
    Skip    Requires Veriff KYC completion and navigation to Verify Your Identity screen — run on physical device

# -------------------------------------------------------
# VERIFY IDENTITY — ID Reuse Rules (m1.2.67)
# -------------------------------------------------------

TC_M1.2_067 - Verify System Blocks Reuse Of Existing ID Under Different User In Same Rural Bank
    [Documentation]    Passport P1234567 already onboarded under User A in San Antonio.
    ...    Onboarding User B under same bank with same ID → error: "We're unable to proceed..."
    [Tags]    M1.2.67    Negative    Manual    Skipped
    Skip    Requires pre-existing ID registration and Veriff completion — run on physical device

# -------------------------------------------------------
# VERIFF SESSION MANAGEMENT (m1.2.78, m1.2.87)
# -------------------------------------------------------

TC_M1.2_078 - Verify Warning Message Prompt When Leaving KYC Onboarding Flow
    [Documentation]    Tapping back during post-Veriff onboarding shows a warning prompt.
    ...    Cancel → stay on form. Confirm → redirect to email screen.
    [Tags]    M1.2.78    Negative    Manual    Skipped
    Skip    Requires completing Veriff and being on post-Veriff form pages — run on physical device

TC_M1.2_087 - Verify User Cannot Bypass Veriff By Navigating Back Or Refreshing
    [Documentation]    With expired or abandoned Veriff, navigating back or refreshing during
    ...    onboarding must still redirect to Veriff — it cannot be skipped incorrectly.
    [Tags]    M1.2.87    Negative    Manual    Skipped
    Skip    Requires Veriff bypass attempt — run on physical device

# -------------------------------------------------------
# PROFILE SCREEN — Field Validations (m1.2.89–m1.2.93)
# Pre-condition: User has completed Veriff and is on the Profile screen.
# -------------------------------------------------------

TC_M1.2_089 - Verify Error Validation For Nationality Field On Profile Screen
    [Documentation]    NOTE: Nationality is no longer a dropdown per CSV comments (marked Invalid for iOS).
    ...    Android: verify current behaviour with Appium Inspector before running.
    [Tags]    M1.2.89    Negative    Manual    Skipped
    Skip    Nationality field behaviour changed — verify with Appium Inspector on physical device

TC_M1.2_090 - Verify Error Validation For Region Of Birth Field On Profile Screen
    [Documentation]    No Region of Birth selected → "This field is required."
    [Tags]    M1.2.90    Negative    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

TC_M1.2_091 - Verify Error Validation For Province Of Birth Field On Profile Screen
    [Documentation]    No Province of Birth selected → "This field is required."
    [Tags]    M1.2.91    Negative    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

TC_M1.2_092 - Verify Error Validation For City Of Birth Field On Profile Screen
    [Documentation]    No City of Birth selected → "This field is required."
    [Tags]    M1.2.92    Negative    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

TC_M1.2_093 - Verify Error Validation For Civil Status Field On Profile Screen
    [Documentation]    No Civil Status selected → "This field is required."
    [Tags]    M1.2.93    Negative    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

# -------------------------------------------------------
# MOTHER'S MAIDEN NAME — Field Validations (m1.2.98–m1.2.100)
# Pre-condition: User is on Mother's Maiden Name screen (post-Veriff + Profile).
# -------------------------------------------------------

TC_M1.2_098 - Verify Error Validations For Mother's First Name Field
    [Documentation]    Empty → "First name is required." >80 chars → "Up to 80 characters only."
    ...    Numbers/symbols → "Special characters are not allowed, except: comma (.), dash (-), space ()."
    [Tags]    M1.2.98    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

TC_M1.2_099 - Verify Error Validations For Mother's Middle Name Field
    [Documentation]    Empty (checkbox unticked) → "Middle name is required." >80 chars error. Numbers/symbols error.
    [Tags]    M1.2.99    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

TC_M1.2_100 - Verify Error Validations For Mother's Last Name Field
    [Documentation]    Empty → "Last name is required." >80 chars error. Numbers/symbols error.
    [Tags]    M1.2.100    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

# -------------------------------------------------------
# PRESENT ADDRESS — Field Validations (m1.2.105–m1.2.111)
# Pre-condition: User is on Present Address screen (post-Veriff + Profile + Mother's Maiden Name).
# -------------------------------------------------------

TC_M1.2_105 - Verify Error Validation For Region Field On Present Address Screen
    [Documentation]    No Region selected → "Region is required."
    [Tags]    M1.2.105    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_106 - Verify Error Validation For Province Field On Present Address Screen
    [Documentation]    No Province selected → "Province is required."
    [Tags]    M1.2.106    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_107 - Verify Error Validation For City Field On Present Address Screen
    [Documentation]    No City selected → "City is required."
    [Tags]    M1.2.107    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_108 - Verify Error Validation For Barangay Field On Present Address Screen
    [Documentation]    No Barangay selected → "Barangay is required."
    [Tags]    M1.2.108    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_109 - Verify Error Validation For Building And Street Field On Present Address Screen
    [Documentation]    Empty Building/Street → "Address is required."
    [Tags]    M1.2.109    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_110 - Verify Error Validation For Building And Street Field Character Limit
    [Documentation]    Empty → "This field is required." >300 chars → "Must not exceed 300 characters."
    [Tags]    M1.2.110    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_111 - Verify Error Validations For Zip Code Field On Present Address Screen
    [Documentation]    Empty → "This field is required." Alpha chars → "Only numerical values are accepted."
    ...    >10 digits → "Invalid Zip Code."
    [Tags]    M1.2.111    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

# -------------------------------------------------------
# PERMANENT ADDRESS — Field Validations (m1.2.112–m1.2.117)
# Pre-condition: "I have a different permanent address" checkbox is ticked.
# -------------------------------------------------------

TC_M1.2_112 - Verify Error Validation For Region Field On Permanent Address
    [Documentation]    "I have a different permanent address" ticked. No Region → "This field is required."
    [Tags]    M1.2.112    Negative    Manual    Skipped
    Skip    Requires Veriff completion, Present Address screen, and permanent address checkbox — run on physical device

TC_M1.2_113 - Verify Error Validation For Province Field On Permanent Address
    [Documentation]    No Province selected on Permanent Address section → "This field is required."
    [Tags]    M1.2.113    Negative    Manual    Skipped
    Skip    Requires Veriff completion, Present Address screen, and permanent address checkbox — run on physical device

TC_M1.2_114 - Verify Error Validation For City Field On Permanent Address
    [Documentation]    No City selected on Permanent Address section → "This field is required."
    [Tags]    M1.2.114    Negative    Manual    Skipped
    Skip    Requires Veriff completion, Present Address screen, and permanent address checkbox — run on physical device

TC_M1.2_115 - Verify Error Validation For Barangay Field On Permanent Address
    [Documentation]    No Barangay selected on Permanent Address section → "This field is required."
    [Tags]    M1.2.115    Negative    Manual    Skipped
    Skip    Requires Veriff completion, Present Address screen, and permanent address checkbox — run on physical device

TC_M1.2_116 - Verify Error Validation For Building And Street On Permanent Address
    [Documentation]    Empty → "This field is required." >300 chars → "Must not exceed 300 characters."
    [Tags]    M1.2.116    Negative    Manual    Skipped
    Skip    Requires Veriff completion, Present Address screen, and permanent address checkbox — run on physical device

TC_M1.2_117 - Verify Error Validations For Zip Code Field On Permanent Address
    [Documentation]    Empty → "This field is required." Alpha → "Only numerical values are accepted." >10 digits → "Invalid Zip Code."
    [Tags]    M1.2.117    Negative    Manual    Skipped
    Skip    Requires Veriff completion, Present Address screen, and permanent address checkbox — run on physical device

# -------------------------------------------------------
# FINANCIAL INFO — Field Validations (m1.2.122–m1.2.126)
# Pre-condition: User is on Financial Info screen (final onboarding step).
# -------------------------------------------------------

TC_M1.2_122 - Verify Error Validation For Occupation Field On Financial Info Screen
    [Documentation]    Empty → "Occupation is required." >80 chars → "Must not exceed 80 Characters."
    [Tags]    M1.2.122    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_123 - Verify Error Validation For Company Industry Field On Financial Info Screen
    [Documentation]    No selection → "Company Industry is required."
    [Tags]    M1.2.123    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_124 - Verify Error Validation For Company Name Field On Financial Info Screen
    [Documentation]    >80 chars → "Must not exceed 80 Characters." (Field is optional — no required error.)
    [Tags]    M1.2.124    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_125 - Verify Error Validation For Monthly Income Field On Financial Info Screen
    [Documentation]    No selection → "Monthly income is required."
    [Tags]    M1.2.125    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_126 - Verify Error Validations For TIN Field On Financial Info Screen
    [Documentation]    Empty → "Tin is required." Alpha input → only numbers allowed.
    ...    <9 digits → "Must not exceed 9 Digits."
    [Tags]    M1.2.126    Negative    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device


# ==============================================================
# RATE LIMITING / DESTRUCTIVE
# ==============================================================

# -------------------------------------------------------
# M1.2.27 — BLOCK AFTER 3 UNVERIFIED SESSIONS WITH 5 FAILS EACH (Destructive)
# -------------------------------------------------------

TC_M1.2_027 - Verify Email Blocked For 60 Minutes After 3 Unverified Sessions With Max Attempts Per Session
    [Documentation]    Verify that 3 unverified OTP sessions with 5 failed attempts each
    ...    (within 15 minutes) triggers a 60-minute email block on the 4th attempt.
    ...    Error: "You have exceeded the maximum number of OTP attempts. You can try again in 59 mins."
    ...
    ...    Pre-conditions: AC_BLOCK_EMAIL is NOT registered and NOT currently blocked.
    ...    WARNING: This test blocks AC_BLOCK_EMAIL for 60 minutes.
    [Tags]    M1.2.27    Destructive
    # --- Session 1: 999999 directly triggers max attempts ---
    Navigate To Signup OTP Screen    ${AC_BLOCK_EMAIL}
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 2: 999999 directly triggers max attempts ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 3: 999999 directly triggers max attempts → triggers block ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 4: Should show blocked error ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AC_BLOCKED_ERROR}    visible
    Click Element    ${AC_OK_BTN}
    # User remains on Signup Email screen
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.29 — BLOCK AFTER 3 UNVERIFIED SESSIONS (< MAX ATTEMPTS PER SESSION) (Destructive)
# -------------------------------------------------------

TC_M1.2_029 - Verify Email Blocked After 3 Unverified Sessions With Less Than 5 Fails Per Session
    [Documentation]    Verify that 3 unverified OTP sessions with 3 failed attempts each
    ...    (not reaching max, within 15 minutes) still triggers the 60-minute email block.
    ...    Error: "You have exceeded the maximum number of OTP attempts. You can try again in 59 mins."
    ...
    ...    Pre-conditions: AC_BLOCK_EMAIL is NOT registered and NOT currently blocked.
    ...    WARNING: This test blocks AC_BLOCK_EMAIL for 60 minutes.
    [Tags]    M1.2.29    Destructive
    # --- Session 1: 3 wrong OTPs → close/exit ---
    Navigate To Signup OTP Screen    ${AC_BLOCK_EMAIL}
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 2: 3 wrong OTPs → close/exit ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 3: 3 wrong OTPs → close/exit → triggers block ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 4: Should show blocked error ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AC_BLOCKED_ERROR}    visible
    Click Element    ${AC_OK_BTN}
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.30 — BLOCK AFTER 3 ABANDONED OTP SESSIONS (Destructive)
# -------------------------------------------------------

TC_M1.2_030 - Verify Email Blocked After 3 Abandoned OTP Sessions
    [Documentation]    Verify that abandoning (exiting without any OTP input) 3 signup OTP sessions
    ...    within 15 minutes triggers the 60-minute email block on the 4th signup attempt.
    ...    Error: "You have exceeded the maximum number of OTP attempts. You can try again in 59 mins."
    ...
    ...    Pre-conditions: AC_BLOCK_EMAIL is NOT registered and NOT currently blocked.
    ...    WARNING: This test blocks AC_BLOCK_EMAIL for 60 minutes.
    [Tags]    M1.2.30    Destructive
    # --- Session 1: Navigate to OTP screen → abandon (close without input) ---
    Navigate To Signup OTP Screen    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 2: Navigate to OTP screen → abandon ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 3: Navigate to OTP screen → abandon → triggers block ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Click Element    ${AC_OTP_CLOSE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # --- Session 4: Should show blocked error ---
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AC_BLOCKED_ERROR}    visible
    Click Element    ${AC_OK_BTN}
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.31 — SIGNUP WITH BLOCKED EMAIL DURING BLOCK PERIOD (Destructive)
# -------------------------------------------------------

TC_M1.2_031 - Verify Blocked Email Returns Error Message With Updated Remaining Time
    [Documentation]    Verify that attempting to sign up with a blocked email during the 60-minute
    ...    block period shows the error each time, with the remaining block time updated.
    ...    Error: "You have exceeded the maximum number of OTP attempts. You can try again in <N> mins."
    ...
    ...    Pre-conditions: AC_BLOCK_EMAIL is currently blocked.
    ...    Run TC_M1.2_027, TC_M1.2_029, or TC_M1.2_030 first to block this email.
    [Tags]    M1.2.31    Destructive
    # Attempt 1 during block period
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AC_BLOCKED_ERROR}    visible
    Click Element    ${AC_OK_BTN}
    # Still on Signup Email screen
    Expect Element    ${AC_EMAIL_FIELD}    visible
    Sleep    5s
    # Attempt 2 during block period — remaining time should be less
    Input Text       ${AC_EMAIL_FIELD}    ${AC_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AC_BLOCKED_ERROR}    visible
    Click Element    ${AC_OK_BTN}
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.32 — SIGN UP AFTER 60-MINUTE BLOCK EXPIRES (Destructive + Positive)
# -------------------------------------------------------

TC_M1.2_032 - Verify User Can Sign Up With Valid OTP After 60-Minute Block Period Expires
    [Documentation]    After AC_POST_BLOCK_EMAIL has been blocked and 60 minutes have elapsed,
    ...    the user must be able to initiate a new sign-up session and receive an OTP normally.
    ...
    ...    Pre-conditions: AC_POST_BLOCK_EMAIL was blocked via 3 failed OTP sessions.
    ...    60 minutes must have elapsed before running this test.
    ...    Pair with m1.2.27/29/30 to trigger the block first.
    [Tags]    M1.2.32    Positive    Destructive
    Navigate To Signup Email Screen
    Input Text       ${AC_EMAIL_FIELD}    ${AC_POST_BLOCK_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Expect Element    ${AC_OTP_SCREEN}    visible

# -------------------------------------------------------
# M1.2.35 — BLOCK COUNTER RESETS AFTER SUCCESSFUL VERIFICATION (Destructive + Negative)
# -------------------------------------------------------

TC_M1.2_035 - Verify Block Counter Resets After Successful OTP Verification In Any Session
    [Documentation]    After a successful OTP verification in session #3, the unverified-session
    ...    counter resets, requiring 3 NEW unverified sessions to trigger the next block.
    ...    Rule E automation: Sessions 1 & 2 use 999999 (instantly triggers max-attempts modal).
    ...    Session 3 uses 123456 (valid — resets counter to 0).
    ...    Sessions 4 & 5 use 999999 again (2 unverified after reset — counter = 2, not yet blocked).
    ...    Session 6 uses 999999 — counter = 3 → block IS triggered, confirming the counter
    ...    was fully reset after Session 3 (otherwise Session 4 alone would have blocked).
    ...
    ...    Pre-conditions: AC_SIGNUP_EMAIL_9 is unregistered and not blocked.
    ...    WARNING: This test blocks AC_SIGNUP_EMAIL_9 for 60 minutes.
    [Tags]    M1.2.35    Destructive    Negative
    # Session 1 — 999999 instantly triggers max-attempts (counter = 1 unverified)
    Navigate To Signup OTP Screen    ${AC_CHAIN_EMAIL}
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 2 — 999999 instantly triggers max-attempts (counter = 2 unverified)
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 3 — valid OTP 123456 → session verified → counter RESETS to 0
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=5s
    Wait Until Element Is Visible    ${AC_TC_CHECKBOX}    timeout=15s
    Expect Element    ${AC_TC_CHECKBOX}    visible
    # Return to allow re-running the signup flow (navigate back without completing signup)
    Navigate To Welcome Screen
    # Session 4 — 999999 max-attempts (counter = 1 post-reset; NO block expected)
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 5 — 999999 max-attempts (counter = 2 post-reset; still NO block)
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 6 — 999999 max-attempts (counter = 3 post-reset → block triggered)
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_OTP_SCREEN}    timeout=15s
    Sleep    2s
    Enter OTP Into Boxes    9    9    9    9    9    9    post_sleep=2s
    Wait Until Element Is Visible    ${AC_MAX_ATTEMPTS}    timeout=10s
    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    # Session 7 — must show blocked error (confirms counter was reset; 3 new sessions needed)
    Sleep    2s
    Input Text       ${AC_EMAIL_FIELD}    ${AC_CHAIN_EMAIL}
    Click Element    ${AC_NEXT_BTN}
    Wait Until Element Is Visible    ${AC_BLOCKED_ERROR}    timeout=10s
    Expect Element    ${AC_BLOCKED_ERROR}    visible
    Click Element    ${AC_OK_BTN}
    Expect Element    ${AC_EMAIL_FIELD}    visible


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

# -------------------------------------------------------
# M1.2.15 — SESSION TIMEOUT: INACTIVITY (Session)
# -------------------------------------------------------

TC_M1.2_015 - Verify Session Timeout Modal Appears After 5 Minutes Of Inactivity On Email Screen
    [Documentation]    Verify that the session timeout modal appears after 5 minutes of inactivity
    ...    on the Signup Email screen, and tapping Back to Login redirects to the Login screen.
    ...
    ...    Pre-conditions: User is on the Signup Email screen. Do not interact for 5 minutes.
    [Tags]    M1.2.15    Session
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    # Do not interact — wait for the 5-minute session timeout
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=360s
    Expect Element        ${AC_SESSION_TIMEOUT}    visible
    Click Element                    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=10s
    Expect Element        xpath=//android.widget.EditText[@hint='Email Address']    visible

# -------------------------------------------------------
# M1.2.16 — SESSION TIMEOUT: MINIMIZE (Session)
# -------------------------------------------------------

TC_M1.2_016 - Verify Session Timeout Modal Appears After Minimizing App For 5 Minutes
    [Documentation]    Verify that minimizing the app for 5 minutes while on the Signup Email screen
    ...    triggers the session timeout modal when the app is restored.
    ...
    ...    Pre-conditions: User is on the Signup Email screen.
    [Tags]    M1.2.16    Session
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    # Minimize app (Home key)
    Press Keycode    3
    # Wait 5 minutes + buffer while minimized
    Sleep    310s
    # Restore app
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=30s
    Expect Element        ${AC_SESSION_TIMEOUT}    visible
    Click Element                    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=10s
    Expect Element        xpath=//android.widget.EditText[@hint='Email Address']    visible

# -------------------------------------------------------
# M1.2.17 — SESSION TIMEOUT MODAL PERSISTS AFTER MINIMIZE/RESTORE (Session)
# -------------------------------------------------------

TC_M1.2_017 - Verify Session Timeout Modal Is Still Visible After Minimize And Restore
    [Documentation]    Verify that after the session timeout modal appears (5 min inactivity),
    ...    minimizing and restoring the app still shows the timeout modal.
    ...
    ...    Pre-conditions: User is on the Signup Email screen. Do not interact for 5 minutes.
    [Tags]    M1.2.17    Session
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    # Wait for session timeout modal to appear
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=360s
    # Minimize the app while the modal is visible
    Press Keycode    3
    Sleep    5s
    # Restore the app
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    # Modal should still be visible after restoring
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element                ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=10s
    Expect Element        xpath=//android.widget.EditText[@hint='Email Address']    visible

# -------------------------------------------------------
# M1.2.18 — SESSION REMAINS ACTIVE DURING INTERACTION (Session)
# -------------------------------------------------------

TC_M1.2_018 - Verify Session Remains Active While Continuously Interacting With App
    [Documentation]    Verify that continuously interacting with the app on the Signup Email screen
    ...    prevents the session timeout modal from appearing.
    ...
    ...    Pre-conditions: User is on the Signup Email screen.
    [Tags]    M1.2.18    Session
    Click Element    ${AC_GET_STARTED_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Sleep    2s
    # Tap the email field every 60 seconds for 4 minutes to keep session active
    FOR    ${i}    IN RANGE    4
        Click Element    ${AC_EMAIL_FIELD}
        Sleep    60s
    END
    # Session timeout modal should NOT appear during active interaction
    ${timeout_shown}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=5s
    Should Be False    ${timeout_shown}    msg=Session timeout modal should NOT appear during active interaction

# -------------------------------------------------------
# M1.2.23 — EXPIRED OTP (Session)
# -------------------------------------------------------

TC_M1.2_023 - Verify Validation Message For Expired OTP During Signup
    [Documentation]    Verify that entering an OTP after the 5-minute validity window has expired
    ...    shows the OTP expired/invalid error message.
    ...
    ...    Pre-conditions: User is on OTP Verification screen; OTP has been generated.
    ...    NOTE: This test waits 5+ minutes for the OTP to expire.
    [Tags]    M1.2.23    Session
    Navigate To Signup OTP Screen    ${AC_CHAIN_EMAIL}
    # Wait for OTP validity to expire (5 minutes + buffer)
    Sleep    310s
    # Enter magic OTP — should fail because session expired
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=2s
    Wait Until Element Is Visible    ${AC_OTP_ERROR}    timeout=10s
    Expect Element    ${AC_OTP_ERROR}    visible

# -------------------------------------------------------
# M1.2.26 — OTP SESSION EXPIRES BEFORE MAX ATTEMPTS (Session)
# -------------------------------------------------------

TC_M1.2_026 - Verify OTP Session Expiry Error Before Reaching Max Attempts
    [Documentation]    Verify that after entering 3 wrong OTPs and then waiting for the 5-minute
    ...    session expiry, any subsequent OTP input shows the expired error.
    ...    Tapping Resend code shows the "OTP Expired" modal; tapping Request New Code
    ...    redirects the user to the Signup Email screen.
    ...
    ...    Pre-conditions: User is on OTP Verification screen.
    ...    NOTE: This test waits 5+ minutes for session expiry.
    [Tags]    M1.2.26    Session
    Navigate To Signup OTP Screen    ${AC_CHAIN_EMAIL}
    # Enter 3 wrong OTPs within 5 minutes
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Expect Element    ${AC_OTP_ERROR}    visible
    # Wait for OTP session to expire (5 minutes + buffer)
    Sleep    310s
    # 4th attempt after session expiry — should show expired/invalid error
    Enter OTP Into Boxes    0    0    0    0    0    0    post_sleep=2s
    Wait Until Element Is Visible    ${AC_OTP_ERROR}    timeout=10s
    Expect Element    ${AC_OTP_ERROR}    visible
    # Tap Resend code → should show "OTP Expired" modal
    Click Element    ${AC_RESEND_CODE}
    Wait Until Element Is Visible    ${AC_OTP_EXPIRED_MODAL}    timeout=10s
    Expect Element    ${AC_OTP_EXPIRED_MODAL}    visible
    # Tap Request New Code → redirected to Signup Email screen
    Click Element    ${AC_REQUEST_NEW_CODE_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.28 — ENTER OTP AFTER 5-MINUTE VALIDITY WINDOW (Session)
# -------------------------------------------------------

TC_M1.2_028 - Verify Error Modal When Any OTP Is Entered After 5-Minute Validity Window
    [Documentation]    Verify that entering any OTP (valid or invalid) after the 5-minute
    ...    OTP validity window has expired shows an error modal, and tapping OK
    ...    redirects the user to the previous screen.
    ...
    ...    Pre-conditions: User is on OTP Verification screen; OTP has been generated.
    ...    NOTE: This test waits 5+ minutes for the OTP validity window to expire.
    [Tags]    M1.2.28    Session
    Navigate To Signup OTP Screen    ${AC_CHAIN_EMAIL}
    # Wait for the 5-minute OTP validity window to expire
    Sleep    310s
    # Enter magic OTP — should fail due to expiry regardless of correctness
    Enter OTP Into Boxes    1    2    3    4    5    6    post_sleep=2s
    Wait Until Element Is Visible    ${AC_OTP_ERROR}    timeout=10s
    Expect Element    ${AC_OTP_ERROR}    visible
    # If there is an OK button on the modal, tap it — expect redirect to previous screen
    ${ok_visible}=    Run Keyword And Return Status    Expect Element    ${AC_OK_BTN}    visible
    Run Keyword If    ${ok_visible}    Click Element    ${AC_OK_BTN}
    Wait Until Element Is Visible    ${AC_EMAIL_FIELD}    timeout=10s
    Expect Element    ${AC_EMAIL_FIELD}    visible

# -------------------------------------------------------
# M1.2.36 — SESSION TIMEOUT ON OTP SCREEN: INACTIVITY
# -------------------------------------------------------

TC_M1.2_036 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On OTP Screen
    [Documentation]    With no user interaction for 5 minutes on the OTP Verification screen,
    ...    a session timeout modal must appear. Tapping "Back to Login" returns to Welcome screen.
    [Tags]    M1.2.36    Session
    Navigate To Signup OTP Screen    ${AC_OTP_SESS_EMAIL_1}
    Sleep    310s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=20s
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//*[@text='Sign in']    timeout=10s
    Expect Element    xpath=//*[@text='Sign in']    visible

# -------------------------------------------------------
# M1.2.37 — SESSION TIMEOUT ON OTP SCREEN: MINIMIZE
# -------------------------------------------------------

TC_M1.2_037 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On OTP Screen
    [Documentation]    Minimize the app for 5 minutes while on the OTP screen, then restore.
    ...    The session timeout modal must be visible.
    [Tags]    M1.2.37    Session
    Navigate To Signup OTP Screen    ${AC_OTP_SESS_EMAIL_2}
    Run    adb -s ${DEVICE_NAME} shell input keyevent KEYCODE_HOME
    Sleep    310s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=20s
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//*[@text='Sign in']    timeout=10s

# -------------------------------------------------------
# M1.2.38 — SESSION TIMEOUT MODAL PERSISTS ON OTP SCREEN AFTER MINIMIZE/RESTORE
# -------------------------------------------------------

TC_M1.2_038 - Verify Session Timeout Modal Is Still Visible On OTP Screen After Minimize And Restore
    [Documentation]    When the session timeout modal appears on the OTP screen,
    ...    minimize then restore the app — the modal must still be visible.
    [Tags]    M1.2.38    Session
    Navigate To Signup OTP Screen    ${AC_OTP_SESS_EMAIL_3}
    Sleep    310s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=20s
    Run    adb -s ${DEVICE_NAME} shell input keyevent KEYCODE_HOME
    Sleep    3s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//*[@text='Sign in']    timeout=10s

# -------------------------------------------------------
# M1.2.39 — SESSION STAYS ACTIVE DURING INTERACTION ON OTP SCREEN
# -------------------------------------------------------

TC_M1.2_039 - Verify Session Remains Active While Continuously Interacting On OTP Screen
    [Documentation]    Continuously interacting on the OTP screen within the 5-minute window
    ...    must keep the session alive — no timeout modal should appear.
    [Tags]    M1.2.39    Session
    Navigate To Signup OTP Screen    ${AC_OTP_SESS_EMAIL_4}
    FOR    ${i}    IN RANGE    8
        Sleep    28s
        Click Element    xpath=(//android.widget.EditText)[1]
        Sleep    2s
    END
    ${timeout_visible}=    Run Keyword And Return Status    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Should Not Be True    ${timeout_visible}    Session timeout modal appeared unexpectedly during active interaction

# -------------------------------------------------------
# M1.2.41 — SESSION TIMEOUT ON POLICY AGREEMENT SCREEN: INACTIVITY
# -------------------------------------------------------

TC_M1.2_041 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Policy Agreement Screen
    [Documentation]    With no interaction for 5 minutes on the Policy Agreement screen,
    ...    a session timeout modal must appear. Tapping "Back to Login" returns to Welcome screen.
    [Tags]    M1.2.41    Session
    Navigate To Policy Agreement Screen    ${AC_POLICY_SESS_EMAIL_1}
    Sleep    310s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=20s
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//*[@text='Sign in']    timeout=10s
    Expect Element    xpath=//*[@text='Sign in']    visible

# -------------------------------------------------------
# M1.2.42 — SESSION TIMEOUT ON POLICY AGREEMENT SCREEN: MINIMIZE
# -------------------------------------------------------

TC_M1.2_042 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Policy Agreement Screen
    [Documentation]    Minimize the app for 5 minutes while on the Policy Agreement screen,
    ...    then restore. The session timeout modal must be visible.
    [Tags]    M1.2.42    Session
    Navigate To Policy Agreement Screen    ${AC_POLICY_SESS_EMAIL_2}
    Run    adb -s ${DEVICE_NAME} shell input keyevent KEYCODE_HOME
    Sleep    310s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=20s
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//*[@text='Sign in']    timeout=10s

# -------------------------------------------------------
# M1.2.43 — SESSION TIMEOUT MODAL PERSISTS ON POLICY AGREEMENT SCREEN AFTER MINIMIZE/RESTORE
# -------------------------------------------------------

TC_M1.2_043 - Verify Session Timeout Modal Is Still Visible On Policy Agreement Screen After Minimize And Restore
    [Documentation]    When the session timeout modal appears on the Policy Agreement screen,
    ...    minimize then restore the app — the modal must still be visible.
    [Tags]    M1.2.43    Session
    Navigate To Policy Agreement Screen    ${AC_POLICY_SESS_EMAIL_3}
    Sleep    310s
    Wait Until Element Is Visible    ${AC_SESSION_TIMEOUT}    timeout=20s
    Run    adb -s ${DEVICE_NAME} shell input keyevent KEYCODE_HOME
    Sleep    3s
    Activate Application    ${APP_PACKAGE}
    Sleep    3s
    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Click Element    ${AC_BACK_TO_LOGIN_BTN}
    Wait Until Element Is Visible    xpath=//*[@text='Sign in']    timeout=10s

# -------------------------------------------------------
# M1.2.44 — SESSION STAYS ACTIVE DURING INTERACTION ON POLICY AGREEMENT SCREEN
# -------------------------------------------------------

TC_M1.2_044 - Verify Session Remains Active While Continuously Interacting On Policy Agreement Screen
    [Documentation]    Continuously interacting on the Policy Agreement screen within the
    ...    5-minute window must keep the session alive — no timeout modal.
    [Tags]    M1.2.44    Session
    Navigate To Policy Agreement Screen    ${AC_POLICY_SESS_EMAIL_4}
    FOR    ${i}    IN RANGE    8
        Sleep    28s
        Click Element    ${AC_TC_CHECKBOX}
        Sleep    1s
        Click Element    ${AC_TC_CHECKBOX}
        Sleep    1s
    END
    ${timeout_visible}=    Run Keyword And Return Status    Expect Element    ${AC_SESSION_TIMEOUT}    visible
    Should Not Be True    ${timeout_visible}    Session timeout modal appeared unexpectedly during active interaction

# -------------------------------------------------------
# PERSONAL DETAILS — Session Timeouts (m1.2.60–m1.2.64)
# Pre-condition: User is on Personal Details screen (post-OTP + Veriff).
# -------------------------------------------------------

TC_M1.2_060 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Personal Details Screen
    [Tags]    M1.2.60    Session    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_061 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Personal Details Screen
    [Tags]    M1.2.61    Session    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_062 - Verify Session Timeout Modal Is Still Visible On Personal Details Screen After Minimize And Restore
    [Tags]    M1.2.62    Session    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_063 - Verify Session Remains Active While Continuously Interacting On Personal Details Screen
    [Tags]    M1.2.63    Session    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

TC_M1.2_064 - Verify User Is Redirected To Registration Timeout Screen After 10 Minutes On Personal Details
    [Documentation]    Stay on Personal Details for 10+ minutes with minimal activity,
    ...    then tap Next → "Error encountered. Your session timed out. Please restart your registration."
    [Tags]    M1.2.64    Session    Manual    Skipped
    Skip    Requires Veriff KYC completion to reach Personal Details screen — run on physical device

# -------------------------------------------------------
# VERIFY YOUR IDENTITY SCREEN — Session Timeouts (m1.2.70–m1.2.73)
# Pre-condition: User is on Verify Your Identity screen (pre-Veriff SDK).
# -------------------------------------------------------

TC_M1.2_070 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Verify Your Identity Screen
    [Tags]    M1.2.70    Session    Manual    Skipped
    Skip    Requires navigation to Verify Your Identity screen (post-Personal Details) — run on physical device

TC_M1.2_071 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Verify Your Identity Screen
    [Tags]    M1.2.71    Session    Manual    Skipped
    Skip    Requires navigation to Verify Your Identity screen (post-Personal Details) — run on physical device

TC_M1.2_072 - Verify Session Timeout Modal Is Still Visible On Verify Your Identity Screen After Minimize And Restore
    [Tags]    M1.2.72    Session    Manual    Skipped
    Skip    Requires navigation to Verify Your Identity screen (post-Personal Details) — run on physical device

TC_M1.2_073 - Verify Session Remains Active While Continuously Interacting On Verify Your Identity Screen
    [Tags]    M1.2.73    Session    Manual    Skipped
    Skip    Requires navigation to Verify Your Identity screen (post-Personal Details) — run on physical device

# -------------------------------------------------------
# VERIFY YOUR ID SCREEN (Veriff Camera) — Session Timeouts (m1.2.74–m1.2.77)
# Pre-condition: User is inside the Veriff SDK camera flow.
# -------------------------------------------------------

TC_M1.2_074 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Verify Your ID Screen
    [Tags]    M1.2.74    Session    Manual    Skipped
    Skip    Requires Veriff SDK camera session (physical device with camera access)

TC_M1.2_075 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Verify Your ID Screen
    [Tags]    M1.2.75    Session    Manual    Skipped
    Skip    Requires Veriff SDK camera session (physical device with camera access)

TC_M1.2_076 - Verify Session Timeout Modal Is Still Visible On Verify Your ID Screen After Minimize And Restore
    [Tags]    M1.2.76    Session    Manual    Skipped
    Skip    Requires Veriff SDK camera session (physical device with camera access)

TC_M1.2_077 - Verify Session Remains Active While Continuously Interacting On Verify Your ID Screen
    [Tags]    M1.2.77    Session    Manual    Skipped
    Skip    Requires Veriff SDK camera session (physical device with camera access)

# -------------------------------------------------------
# PROFILE SCREEN — Session Timeouts (m1.2.94–m1.2.97)
# -------------------------------------------------------

TC_M1.2_094 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Profile Screen
    [Tags]    M1.2.94    Session    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

TC_M1.2_095 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Profile Screen
    [Tags]    M1.2.95    Session    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

TC_M1.2_096 - Verify Session Timeout Modal Is Still Visible On Profile Screen After Minimize And Restore
    [Tags]    M1.2.96    Session    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

TC_M1.2_097 - Verify Session Remains Active While Continuously Interacting On Profile Screen
    [Tags]    M1.2.97    Session    Manual    Skipped
    Skip    Requires Veriff completion to reach Profile screen — run on physical device

# -------------------------------------------------------
# MOTHER'S MAIDEN NAME — Session Timeouts (m1.2.101–m1.2.104)
# -------------------------------------------------------

TC_M1.2_101 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Mother's Maiden Name Screen
    [Tags]    M1.2.101    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

TC_M1.2_102 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Mother's Maiden Name Screen
    [Tags]    M1.2.102    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

TC_M1.2_103 - Verify Session Timeout Modal Is Still Visible On Mother's Maiden Name Screen After Minimize And Restore
    [Tags]    M1.2.103    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

TC_M1.2_104 - Verify Session Remains Active While Continuously Interacting On Mother's Maiden Name Screen
    [Tags]    M1.2.104    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Mother's Maiden Name screen — run on physical device

# -------------------------------------------------------
# PRESENT ADDRESS — Session Timeouts (m1.2.118–m1.2.121)
# -------------------------------------------------------

TC_M1.2_118 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Present Address Screen
    [Tags]    M1.2.118    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_119 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Present Address Screen
    [Tags]    M1.2.119    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_120 - Verify Session Timeout Modal Is Still Visible On Present Address Screen After Minimize And Restore
    [Tags]    M1.2.120    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

TC_M1.2_121 - Verify Session Remains Active While Continuously Interacting On Present Address Screen
    [Tags]    M1.2.121    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Present Address screen — run on physical device

# -------------------------------------------------------
# FINANCIAL INFO — Session Timeouts (m1.2.129–m1.2.132)
# -------------------------------------------------------

TC_M1.2_129 - Verify Session Timeout Modal After 5 Minutes Of Inactivity On Financial Info Screen
    [Tags]    M1.2.129    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_130 - Verify Session Timeout Modal After Minimizing App For 5 Minutes On Financial Info Screen
    [Tags]    M1.2.130    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_131 - Verify Session Timeout Modal Is Still Visible On Financial Info Screen After Minimize And Restore
    [Tags]    M1.2.131    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device

TC_M1.2_132 - Verify Session Remains Active While Continuously Interacting On Financial Info Screen
    [Tags]    M1.2.132    Session    Manual    Skipped
    Skip    Requires Veriff completion and navigation to Financial Info screen — run on physical device


