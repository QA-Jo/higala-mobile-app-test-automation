*** Variables ***
# -------------------------------------------------------
# TEST ACCOUNTS — Account Creation (Signup) flow
# -------------------------------------------------------
# Registered email — used for duplicate email test (TC_M1.2_013)
# Must already be a fully onboarded account under the current bank
${AC_REGISTERED_EMAIL}      jjavier+157@nmblr.ai
${AC_VALID_PASSWORD}        Password!1

# Chain email — Veriff pre-completed; used for continuous 002→010 run
# WARNING: Each run fully registers this email. Update to a fresh Veriff pre-completed email after each run.
${AC_CHAIN_EMAIL}           jjavier+r3530_157@nmblr.ai

# Fresh signup emails — used for OTP flow tests
# These should NOT be fully registered accounts (partial or never-started signup is fine)
# NOTE: Each test that triggers an OTP consumes one unverified session on that email.
#       After 3 unverified sessions within 15 minutes, the email is blocked for 60 minutes.
${AC_SIGNUP_EMAIL_1}        jjavier+r3530_200@nmblr.ai
${AC_SIGNUP_EMAIL_2}        jjavier+r3530_201@nmblr.ai
${AC_SIGNUP_EMAIL_3}        jjavier+r3530_202@nmblr.ai
${AC_SIGNUP_EMAIL_4}        jjavier+r3530_203@nmblr.ai
${AC_SIGNUP_EMAIL_5}        jjavier+r3530_204@nmblr.ai
${AC_SIGNUP_EMAIL_6}        jjavier+r3530_205@nmblr.ai

# Block test email — dedicated for Destructive block tests (TC_M1.2_027, 029, 030, 031)
# WARNING: Running Destructive tests will block this email for 60 minutes.
# Do NOT use this email for any other tests.
${AC_BLOCK_EMAIL}           jjavier+r3530_block@nmblr.ai

# -------------------------------------------------------
# OTP MAGIC VALUES
# -------------------------------------------------------
${AC_VALID_OTP}             123456
${AC_INVALID_OTP}           000000
${AC_MAX_OTP}               999999

# -------------------------------------------------------
# LOCATORS — Signup flow
# NOTE: Verify all locators with Appium Inspector before first run.
#       The app is built in React Native — locators may change between releases.
# -------------------------------------------------------

# Welcome / Start screen (shown on first launch or after force-stop)
# This screen has both "Sign in" and "Get Started" buttons
${AC_GET_STARTED_BTN}       xpath=//*[@text='Get started' or @text='Get Started']

# Signup Email screen ("What's your email address?")
# Only 1 EditText on this screen — no hint attr; verify with Appium Inspector
${AC_EMAIL_FIELD}           xpath=//android.widget.EditText
# Next/Continue button text may vary — wildcard to match either
${AC_NEXT_BTN}              xpath=//*[@text='Next' or @text='Continue']

# OTP Verification screen (same screen structure as Login/FP OTP)
${AC_OTP_SCREEN}            xpath=//android.widget.TextView[@text='OTP Verification']
${AC_RESEND_CODE}           xpath=//android.widget.TextView[@text='Resend code']
# Close / X button on OTP screen
# If '×' fails, try: xpath=//android.widget.TextView[@text='✕']  |  accessibility_id=Close
${AC_OTP_CLOSE_BTN}         xpath=//android.widget.TextView[@text='×']

# Policy Agreement screen (reached after successful OTP verification)
# NOTE: Verify exact link text labels with Appium Inspector
${AC_TC_LINK}               xpath=//android.widget.TextView[contains(@text, 'Customer Declaration')]
${AC_PRIVACY_LINK}          xpath=//android.widget.TextView[contains(@text, \"Bank's Data Privacy\")]
${AC_TC_CHECKBOX}           xpath=(//android.widget.CheckBox)[1]
${AC_PRIVACY_CHECKBOX}      xpath=(//android.widget.CheckBox)[2]
${AC_POLICY_NEXT_BTN}       accessibility_id=Next

# -------------------------------------------------------
# ERROR / VALIDATION MESSAGES
# -------------------------------------------------------

# Wrong OTP: "OTP is either Invalid or has expired. Please try again or request a new OTP."
${AC_OTP_ERROR}             xpath=//android.widget.TextView[contains(@text,'Invalid or has expired') or contains(@text,'OTP is either')]
# 5th wrong OTP: "Verification Failed: You have reached the maximum number of attempts..."
${AC_MAX_ATTEMPTS}          xpath=//android.widget.TextView[contains(@text,'maximum number of attempts') or contains(@text,'Verification Failed') or contains(@text,'Verification failed')]
# OTP Expired modal (shown when tapping Resend after the 5-minute session window expires)
${AC_OTP_EXPIRED_MODAL}     xpath=//android.widget.TextView[contains(@text,'OTP Expired') or contains(@text,'one-time password has expired')]
# "Request New Code" button inside the OTP Expired modal
${AC_REQUEST_NEW_CODE_BTN}  xpath=//*[@text='Request New Code' or @text='Request new code']
# Email blocked: "You have exceeded the maximum number of OTP attempts. You can try again in N mins."
${AC_BLOCKED_ERROR}         xpath=//android.widget.TextView[contains(@text,'exceeded') or contains(@text,'try again in') or contains(@text,'blocked')]
# Duplicate email (TC_M1.2_013): "Email already registered."
${AC_DUPLICATE_EMAIL_ERROR}     xpath=//android.widget.TextView[contains(@text,'already registered') or contains(@text,'Email already') or contains(@text,'already exists')]

# -------------------------------------------------------
# SHARED — Session timeout / navigation
# -------------------------------------------------------
${AC_SESSION_TIMEOUT}       xpath=//android.widget.TextView[@text='Session Timeout']
${AC_BACK_TO_LOGIN_BTN}     xpath=//android.widget.TextView[@text='Back to Login' or @text='Back to login']
${AC_OK_BTN}                xpath=//*[@text='OK' or @text='Ok']

# -------------------------------------------------------
# TEST ACCOUNTS — Full-flow tests (Policy through Personal Details)
# -------------------------------------------------------
# NOTE: Each run consumes one OTP session per email.
#       After 3 unverified sessions within 15 minutes the email is blocked for 60 minutes.
${AC_POLICY_EMAIL}          jjavier+r3530_210@nmblr.ai
${AC_PERSONAL_EMAIL}        jjavier+r3530_211@nmblr.ai

# -------------------------------------------------------
# TEST ACCOUNTS — Email case-insensitivity tests (m1.2.45 / m1.2.46)
# -------------------------------------------------------
# AC_CASE_SIGNUP_EMAIL: fresh mixed-case email for TC_M1.2_045 onboarding
# NOTE: Must NOT be a registered account. Update before each test run if email gets blocked.
${AC_CASE_SIGNUP_EMAIL}         jjavier+r3530_CaseTest@nmblr.ai
# AC_CASE_REGISTERED_EMAIL: already fully onboarded account used to test case-insensitive duplicate check
# AC_CASE_REGISTERED_EMAIL_UPPER: uppercase version of the same email — must be blocked by the system
${AC_CASE_REGISTERED_EMAIL}     pvillados@nmblr.ai
${AC_CASE_REGISTERED_EMAIL_UPPER}    PVILLADOS@NMBLR.AI

# -------------------------------------------------------
# LOCATORS — Policy Agreement modal close button
# NOTE: Tapping the T&C or Privacy links opens a WebView/bottom sheet.
#       Verify close button with Appium Inspector — may be 'X', '✕', or a back arrow.
# -------------------------------------------------------
${AC_MODAL_CLOSE_BTN}       accessibility_id=Back

# -------------------------------------------------------
# LOCATORS — Personal Details screen
# NOTE: React Native renders empty hint="" on EditText fields; labels are separate TextViews.
#       Using positional selectors — confirmed via XML dump.
# -------------------------------------------------------
${AC_PD_SCREEN}             xpath=//android.widget.TextView[@text='Personal Details']
${AC_PD_FIRST_NAME}         xpath=(//android.widget.EditText)[1]
${AC_PD_MIDDLE_NAME}        xpath=(//android.widget.EditText)[2]
${AC_PD_LAST_NAME}          xpath=(//android.widget.EditText)[3]
${AC_PD_SUFFIX_SELECT}      xpath=(//android.widget.EditText)[4]
# Gender — tapping opens a modal with Male / Female options
${AC_PD_GENDER_SELECT}      accessibility_id=Select Gender
${AC_PD_GENDER_MALE}        xpath=//*[@text='Male']
${AC_PD_GENDER_FEMALE}      xpath=//*[@text='Female']
# Date of Birth — tapping opens a NumberPicker dialog (Month / Day / Year columns)
${AC_PD_DOB_FIELD}          xpath=//android.widget.EditText[@hint='mm/dd/yyyy']
${AC_PD_DOB_MONTH}          xpath=(//android.widget.NumberPicker)[1]//android.widget.EditText
${AC_PD_DOB_DAY}            xpath=(//android.widget.NumberPicker)[2]//android.widget.EditText
${AC_PD_DOB_YEAR}           xpath=(//android.widget.NumberPicker)[3]//android.widget.EditText
# OK button in DatePicker dialog — resource-id is more reliable than text when enforceXPath1=True
${AC_PD_DOB_OK}             xpath=//android.widget.Button[@resource-id='android:id/button1']
# Mobile number — sibling of the +63 country code button (scroll needed before interaction)
${AC_PD_MOBILE}             xpath=//android.widget.Button[@content-desc='+63']/following-sibling::android.widget.EditText[1]
# Mobile number value — change this if the number becomes registered in the test environment
${AC_PD_MOBILE_NUM}         9987654321
${AC_PD_NEXT_BTN}           accessibility_id=Next

# -------------------------------------------------------
# LOCATORS — ID Verified screen (shown when Veriff already completed for the email)
# -------------------------------------------------------
${AC_ID_VERIFIED_SCREEN}    xpath=//android.widget.TextView[@text='ID Verified']
${AC_ID_VERIFIED_CONTINUE}  accessibility_id=Continue

# -------------------------------------------------------
# LOCATORS — Verify Identity screen (pre-Veriff SDK launch)
# NOTE: ID type and Next buttons use content-desc (confirmed via XML dump).
#       ID number EditText has hint="" — use positional selector (only enabled EditText on screen).
# -------------------------------------------------------
${AC_VI_SCREEN}             xpath=//android.widget.TextView[@text='Verify your identity']
${AC_VI_ID_TYPE}            accessibility_id=Select ID type
${AC_VI_ID_NUMBER}          xpath=(//android.widget.EditText)[1]
${AC_VI_EXPIRY_DATE}        xpath=//android.widget.EditText[@hint='mm/dd/yyyy']
# "My ID has no expiry date" checkbox — single CheckBox on screen
${AC_VI_NO_EXPIRY_CB}       xpath=//android.widget.CheckBox
${AC_VI_PROCEED_BTN}        accessibility_id=Next
# "Verify your ID" instructions screen (shown after submitting ID form, before Veriff SDK)
${AC_VI_PRE_SCREEN}         xpath=//android.widget.TextView[@text='Verify your ID']
${AC_VI_PROCEED_VERIFF}     xpath=//*[@text='Proceed with Veriff']
# ID type options
${AC_VI_ID_PASSPORT}        xpath=//*[@text='Philippine Passport']

# -------------------------------------------------------
# LOCATORS — Profile screen (post-Veriff)
# NOTE: This screen appears after Veriff KYC is completed.
#       Nationality is typically pre-filled to "Filipino".
#       Dropdowns cascade: Region → Province → City.
# -------------------------------------------------------
${AC_PR_SCREEN}             xpath=//android.widget.TextView[@text='Profile']
${AC_PR_NATIONALITY}        xpath=//*[@text='Filipino' or @text='Select Nationality']
# Use index [1] for birth-region dropdowns to distinguish from address-screen dropdowns
${AC_PR_REGION_BIRTH}       xpath=(//android.widget.TextView[contains(@text,'Select Region')])[1]
${AC_PR_PROVINCE_BIRTH}     xpath=(//android.widget.TextView[contains(@text,'Select Province') or contains(@text,'Select region first')])[1]
${AC_PR_CITY_BIRTH}         xpath=(//android.widget.TextView[contains(@text,'Select City') or contains(@text,'Select province first')])[1]
${AC_PR_CIVIL_STATUS}       accessibility_id=Select Civil Status
${AC_PR_NEXT_BTN}           accessibility_id=Next
# Dropdown option values — update based on actual app data
${AC_NATIONALITY_FILIPINO}  xpath=//*[@text='Filipino']
${AC_CIVIL_STATUS_SINGLE}   xpath=//*[@text='Single']
# Birth location dropdowns — Region III → Bulacan → Baliuag
${AC_REGION_OPTION}         xpath=//*[@text='Region III (Central Luzon)']
${AC_PROVINCE_OPTION}       xpath=//*[@text='Bulacan']
${AC_CITY_OPTION}           xpath=//*[@text='Baliuag']
# Address barangay — Baliuag, Bulacan (first alphabetical option in dropdown)
${AC_BARANGAY_OPTION}       xpath=//*[@text='Bagong Nayon']

# -------------------------------------------------------
# LOCATORS — Mother's Maiden Name screen
# -------------------------------------------------------
${AC_MM_SCREEN}             xpath=//android.widget.TextView[contains(@text,'Mother')]
# NOTE: All EditTexts on MMN screen have hint="" — confirmed via XML dump. Using positional selectors.
#       Order: [1]=First Name, [2]=Middle Name, [3]=Last Name (CheckBox[1] for no-middle sits between)
${AC_MM_FIRST_NAME}         xpath=(//android.widget.EditText)[1]
${AC_MM_MIDDLE_NAME}        xpath=(//android.widget.EditText)[2]
# CheckBox[1] = "My mother has no middle name"; CheckBox[2] = "I certify I am not a US Citizen"
${AC_MM_NO_MIDDLE_CB}       xpath=(//android.widget.CheckBox)[1]
${AC_MM_LAST_NAME}          xpath=(//android.widget.EditText)[3]
${AC_MM_NOT_US_CB}          xpath=(//android.widget.CheckBox)[2]
${AC_MM_NEXT_BTN}           xpath=//*[@text='Next']

# -------------------------------------------------------
# LOCATORS — Present Address screen
# NOTE: Province/City/Barangay dropdowns are disabled until the parent is selected first.
#       Placeholder text changes as upstream selections are made.
# -------------------------------------------------------
${AC_ADDR_SCREEN}           xpath=//android.widget.TextView[contains(@text,'Present Address') or contains(@text,'Address')]
${AC_ADDR_COUNTRY}          xpath=//*[@text='Philippines' or @text='Select Country']
${AC_ADDR_REGION}           xpath=//*[@text='Select Region']
${AC_ADDR_PROVINCE}         xpath=//*[@text='Select region first' or @text='Select Province']
${AC_ADDR_CITY}             xpath=//*[@text='Select province first' or @text='Select City']
${AC_ADDR_BARANGAY}         xpath=//*[@text='Select Barangay' or @text='Select city first']
# Hints confirmed via XML dump on emulator
${AC_ADDR_STREET}           xpath=//android.widget.EditText[@hint='Building / Unit / House or Blk No. and Street']
${AC_ADDR_ZIP}              xpath=//android.widget.EditText[@hint='Zip Code']
# "I have a different permanent address" checkbox — last CheckBox on screen
${AC_ADDR_DIFF_PERM_CB}     xpath=(//android.widget.CheckBox)[last()]
${AC_ADDR_NEXT_BTN}         xpath=//*[@text='Next']

# -------------------------------------------------------
# LOCATORS — Financial Information screen
# NOTE: All EditTexts on this screen have hint="" — using positional selectors.
#       EditText[1]=Occupation, EditText[2]=Company Name (optional), EditText[3]=TIN
#       Dropdowns use content-desc (confirmed via XML dump).
# -------------------------------------------------------
${AC_FI_SCREEN}             xpath=//android.widget.TextView[@text='Financial Info']
${AC_FI_OCCUPATION}         xpath=(//android.widget.EditText)[1]
${AC_FI_COMPANY_INDUSTRY}   accessibility_id=Select
${AC_FI_COMPANY_NAME}       xpath=(//android.widget.EditText)[2]
${AC_FI_MONTHLY_INCOME}     accessibility_id=Select Range
${AC_FI_TIN}                xpath=(//android.widget.EditText)[3]
${AC_FI_SUBMIT_BTN}         accessibility_id=Submit
# Financial Info dropdown option values (confirmed via emulator run)
${AC_FI_INDUSTRY_OPTION}    xpath=//*[@text='Information and Communication']
${AC_FI_INCOME_OPTION}      xpath=//*[@text='Less than ₱20,000']

# -------------------------------------------------------
# LOCATORS — Account Creation Success screen
# -------------------------------------------------------
# Success screen text is split across two TextViews: "You have successfully" + "created your account!"
${AC_SUCCESS_SCREEN}        xpath=//android.widget.TextView[contains(@text,'You have successfully')]

# -------------------------------------------------------
# TEST ACCOUNTS — OTP screen session timeout tests (m1.2.36-39)
# NOTE: Each test navigates to OTP screen (consuming one unverified session).
#       Use dedicated emails to avoid hitting the 3-session block limit.
# -------------------------------------------------------
${AC_OTP_SESS_EMAIL_1}      jjavier+r3530_212@nmblr.ai
${AC_OTP_SESS_EMAIL_2}      jjavier+r3530_213@nmblr.ai
${AC_OTP_SESS_EMAIL_3}      jjavier+r3530_214@nmblr.ai
${AC_OTP_SESS_EMAIL_4}      jjavier+r3530_215@nmblr.ai

# -------------------------------------------------------
# TEST ACCOUNTS — Policy Agreement session timeout tests (m1.2.40-44)
# NOTE: Each test verifies OTP (magic 123456) to reach the Policy screen.
#       Use dedicated emails per test run.
# -------------------------------------------------------
${AC_NO_TC_EMAIL}           jjavier+r3530_220@nmblr.ai
${AC_POLICY_SESS_EMAIL_1}   jjavier+r3530_216@nmblr.ai
${AC_POLICY_SESS_EMAIL_2}   jjavier+r3530_217@nmblr.ai
${AC_POLICY_SESS_EMAIL_3}   jjavier+r3530_218@nmblr.ai
${AC_POLICY_SESS_EMAIL_4}   jjavier+r3530_219@nmblr.ai

# -------------------------------------------------------
# TEST ACCOUNTS — Post-block expiry test (m1.2.32)
# WARNING: Block this email first (run m1.2.27/29/30), then wait 60 min before running m1.2.32.
# -------------------------------------------------------
${AC_POST_BLOCK_EMAIL}      jjavier+r3530_unblock@nmblr.ai

# -------------------------------------------------------
# TEST ACCOUNTS — 3rd-session valid OTP test (m1.2.33)
# -------------------------------------------------------
${AC_SIGNUP_EMAIL_7}        jjavier+r3530_223@nmblr.ai

# -------------------------------------------------------
# TEST ACCOUNTS — No-block span >15min test (m1.2.34)
# Must NOT be registered or currently blocked.
# -------------------------------------------------------
${AC_SIGNUP_EMAIL_8}        jjavier+r3530_207@nmblr.ai

# -------------------------------------------------------
# TEST ACCOUNTS — Block counter reset test (m1.2.35)
# Must NOT be registered or currently blocked.
# WARNING: Running TC_M1.2_035 blocks this email for 60 minutes.
# -------------------------------------------------------
${AC_SIGNUP_EMAIL_9}        jjavier+r3530_208@nmblr.ai

# -------------------------------------------------------
# LOCATORS — Email address field validation errors (m1.2.47)
# -------------------------------------------------------
${AC_EMAIL_REQUIRED_ERR}    xpath=//android.widget.TextView[contains(@text,'Email address is required') or contains(@text,'email is required')]
${AC_EMAIL_FORMAT_ERR}      xpath=//android.widget.TextView[contains(@text,'Incorrect email format') or contains(@text,'invalid email') or contains(@text,'Invalid email')]
${AC_EMAIL_SPECIAL_ERR}     xpath=//android.widget.TextView[contains(@text,'Special characters are not allowed') or contains(@text,'special characters')]

# -------------------------------------------------------
# LOCATORS — Policy Agreement screen
# -------------------------------------------------------
${AC_POLICY_AGREE_BTN}      xpath=//*[@text='Agree' or @text='Next']

# -------------------------------------------------------
# LOCATORS — Verify Identity screen validation errors (m1.2.66)
# -------------------------------------------------------
${AC_VI_ID_TYPE_ERR}        xpath=//android.widget.TextView[contains(@text,'ID type is required') or contains(@text,'ID Type is required')]
${AC_VI_ID_NUM_ERR}         xpath=//android.widget.TextView[contains(@text,'ID number is required') or contains(@text,'ID Number is required')]
${AC_VI_EXPIRY_ERR}         xpath=//android.widget.TextView[contains(@text,'Expiry date is required') or contains(@text,'expiry') or contains(@text,'Expiry')]
