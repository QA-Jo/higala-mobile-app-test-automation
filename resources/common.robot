*** Settings ***
Library    AppiumLibrary
Library    OperatingSystem
Library    String
Library    ${CURDIR}/RecordingLibrary.py

*** Variables ***
${PLATFORM}         Android
${DEVICE_NAME}      emulator-5554
${APP_PACKAGE}      com.higala.ruralbanksanantonioitg
${APP_ACTIVITY}     .MainActivity
${APPIUM_SERVER}    http://127.0.0.1:4723

*** Keywords ***
Open Higala App
    # Close any dead/previous session before opening a new one
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
    # Start Screen Recording    # disabled — saves storage
    Navigate To Login Page

Navigate To Login Page
    # pm clear wipes auth tokens so the app always cold-starts to Welcome screen (no auto-login)
    Run    adb -s ${DEVICE_NAME} shell pm clear ${APP_PACKAGE}
    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Sleep    3s
    Activate Application    ${APP_PACKAGE}
    Sleep    15s
    Wait Until Element Is Visible    xpath=//*[@content-desc='Sign in']    timeout=30s
    Click Element                    xpath=//*[@content-desc='Sign in']
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=15s

Reset To Login Page
    # Navigate To Login Page handles pm clear + activate + navigate — no need to terminate first
    Navigate To Login Page

Close Higala App
    # Stop And Save Recording    # disabled — saves storage
    Close Application

# -------------------------------------------------------
# SCREENSHOT & RECORDING HELPERS
# -------------------------------------------------------

Capture Screenshot On Failure
    # Safe screenshot on failure — silently skips if no active Appium session
    ${status}=    Run Keyword And Return Status    Capture Page Screenshot
    Run Keyword If    not ${status}    Log    Could not capture screenshot — no active Appium session    WARN

Setup Screenshot On Failure
    # Call this in Suite Setup of each robot file to enable auto-screenshot on failure
    Register Keyword To Run On Failure    Capture Screenshot On Failure

Start Screen Recording
    # Start video recording — silently skips if device doesn't support it
    # AppiumLibrary 3.x: uses full keyword name to avoid recursion with this wrapper
    Run Keyword And Ignore Error    AppiumLibrary.Start Screen Recording
    ...    timeLimit=1800s

Stop And Save Recording
    # Stop recording — AppiumLibrary 3.x saves the file and auto-embeds it in log.html
    # Filename is set to <PASS|FAIL>_<TestName>.mp4 for easy identification
    ${status_label}=    Set Variable If    '${PREV_TEST_STATUS}' == 'PASS'    PASS    FAIL
    ${r}=    Run Keyword And Ignore Error    Sanitize Filename    ${TEST NAME}
    ${safe_name}=    Set Variable If    '${r[0]}' == 'PASS'    ${r[1]}    recording
    Run Keyword And Ignore Error    AppiumLibrary.Stop Screen Recording
    ...    filename=${status_label}_${safe_name}

# -------------------------------------------------------
# OTP HELPERS
# -------------------------------------------------------

Enter OTP Into Boxes
    [Arguments]    ${d1}    ${d2}    ${d3}    ${d4}    ${d5}    ${d6}    ${post_sleep}=8s
    # Enters 6 digits into the individual OTP boxes on the OTP Verification screen
    # Auto-submits on 6th digit — default Sleep 8s allows navigation transition for magic OTP
    # For wrong OTP tests, pass post_sleep=2s to check the error before toast disappears
    Click Element    xpath=(//android.widget.EditText)[1]
    Input Text       xpath=(//android.widget.EditText)[1]    ${d1}
    Wait Until Element Is Visible    xpath=(//android.widget.EditText)[2]    timeout=10s
    Input Text       xpath=(//android.widget.EditText)[2]    ${d2}
    Wait Until Element Is Visible    xpath=(//android.widget.EditText)[3]    timeout=10s
    Input Text       xpath=(//android.widget.EditText)[3]    ${d3}
    Wait Until Element Is Visible    xpath=(//android.widget.EditText)[4]    timeout=10s
    Input Text       xpath=(//android.widget.EditText)[4]    ${d4}
    Wait Until Element Is Visible    xpath=(//android.widget.EditText)[5]    timeout=10s
    Input Text       xpath=(//android.widget.EditText)[5]    ${d5}
    Wait Until Element Is Visible    xpath=(//android.widget.EditText)[6]    timeout=10s
    Input Text       xpath=(//android.widget.EditText)[6]    ${d6}
    Sleep    ${post_sleep}

Navigate To OTP Screen
    [Arguments]    ${email}    ${password}
    # From the Login page, enter credentials and reach the OTP Verification screen
    Input Text       xpath=//android.widget.EditText[@hint='Email Address']    ${email}
    Input Text       xpath=//android.widget.EditText[@hint='Password']         ${password}
    Click Element    accessibility_id=Sign in
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=15s

Keep Session Active
    [Arguments]    ${duration_seconds}    ${interval_seconds}=60
    # Taps the first OTP box every interval to prevent session timeout
    ${iterations}=    Evaluate    int(${duration_seconds}) // int(${interval_seconds})
    FOR    ${i}    IN RANGE    ${iterations}
        Click Element    xpath=(//android.widget.EditText)[1]
        Sleep    ${interval_seconds}s
    END

# -------------------------------------------------------
# FORGOT PASSWORD NAVIGATION HELPERS
# -------------------------------------------------------

Navigate To FP Email Screen
    # From the Login page, tap "Forgot your password?" to reach the FP email entry screen
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Forgot your password?']    timeout=10s
    Click Element                    xpath=//android.widget.TextView[@text='Forgot your password?']
    # NOTE: Verify hint with Appium Inspector — FP email field may share same hint as login
    Wait Until Element Is Visible    xpath=//android.widget.EditText    timeout=10s
    # Sleep to let React Native finish rendering — prevents StaleElementReferenceException
    Sleep    3s

Navigate To FP OTP Screen
    [Arguments]    ${email}
    # From Login page → FP email screen → enter email → Submit → OTP Verification screen
    Navigate To FP Email Screen
    Wait Until Keyword Succeeds    5x    2s    Input Text    xpath=//android.widget.EditText    ${email}
    Click Element    xpath=//android.widget.TextView[@text='Submit']
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=20s
    Sleep    2s

# -------------------------------------------------------
# ACCOUNT CREATION (SIGNUP) NAVIGATION HELPERS
# -------------------------------------------------------

Navigate To Welcome Screen
    # From any state, force-stop → launch → wait for Welcome screen (with Sign in + Get Started)
    # Does NOT click any button — the caller decides whether to tap Sign in or Get Started
    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Sleep    2s
    Activate Application    ${APP_PACKAGE}
    Sleep    8s
    Wait Until Element Is Visible    xpath=//*[@content-desc='Sign in']    timeout=30s

Open Higala App For Signup
    # Like Open Higala App but stops at the Welcome screen instead of navigating to Login form
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
    ...    uiautomator2ServerInstallTimeout=120000
    ...    newCommandTimeout=300
    Sleep    3s
    # Start Screen Recording    # disabled — saves storage
    Navigate To Welcome Screen

Navigate To Signup Email Screen
    # From the Welcome screen, tap Get Started to reach the Signup Email entry screen
    Wait Until Element Is Visible    xpath=//*[@text='Get started' or @text='Get Started']    timeout=10s
    Click Element                    xpath=//*[@text='Get started' or @text='Get Started']
    Wait Until Element Is Visible    xpath=//android.widget.EditText    timeout=10s
    # Sleep to let React Native finish rendering — prevents StaleElementReferenceException
    Sleep    2s

Navigate To Signup OTP Screen
    [Arguments]    ${email}
    # From Welcome screen → tap Get Started → enter email → tap Next/Continue → OTP screen
    Navigate To Signup Email Screen
    Input Text       xpath=//android.widget.EditText    ${email}
    Click Element    xpath=//*[@text='Next' or @text='Continue']
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=15s
    Sleep    2s

Navigate To Policy Agreement Screen
    [Arguments]    ${email}
    # Full path: Welcome → Get Started → enter email → OTP → enter magic OTP → Policy Agreement
    Navigate To Signup OTP Screen    ${email}
    Enter OTP Into Boxes    1    2    3    4    5    6
    # After magic OTP auto-submits, wait for the Policy Agreement screen (T&C link visible)
    Wait Until Element Is Visible    xpath=//android.widget.TextView[contains(@text,'Terms and Conditions') or contains(@text,'Terms & Conditions')]    timeout=15s
    Sleep    2s

Navigate To Personal Details Screen
    [Arguments]    ${email}
    # Full path: Welcome → OTP → Policy Agreement → tick both checkboxes → Next → Personal Details
    Navigate To Policy Agreement Screen    ${email}
    # Tick T&C and Privacy checkboxes (must both be checked before Next is enabled)
    Click Element    xpath=(//android.widget.CheckBox)[1]
    Sleep    1s
    Click Element    xpath=(//android.widget.CheckBox)[2]
    Sleep    1s
    Click Element    xpath=//*[@text='Next']
    # Personal Details screen — wait for First Name field
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Personal Details']    timeout=15s
    Sleep    2s

Navigate To FP New Password Screen
    [Arguments]    ${email}
    # Full path to the New Password screen via magic OTP
    Navigate To FP OTP Screen    ${email}
    Enter OTP Into Boxes    1    2    3    4    5    6
    Sleep    3s
    # NOTE: Verify new password screen title/element with Appium Inspector after OTP auto-submits
