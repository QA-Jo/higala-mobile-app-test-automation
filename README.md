# Higala Mobile App - Automated Test Suite

This repository contains the automated test suite for the **Higala Mobile App**. The tests are written using the [Robot Framework](https://robotframework.org/) and are designed to validate various modules of the mobile application.

## Project Structure

- **APKs/**: Directory containing the mobile application installer(s) (e.g., `application-*.apk`).
- **Modules/**: Contains the Robot Framework test scripts, organized by feature module.
- **resources/**: Reusable resources, keywords, or variables used across different test modules.
- **results/**: Directory where test execution reports and logs are generated.
- **run_all_modules.sh**: A bash script to execute the entire test suite sequentially.
- **\*.xlsx / \*.csv**: Test data files (e.g., for Account Creation, Account Details, Account Management, Send Money, and Login modules) used to feed data into the automation scripts.

## Test Modules

The test suite covers the following modules, executed in this order during a full run:

1. **Account Creation** (M1.2)
2. **Account Activation** (M1.1)
3. **Login** - Includes Email OTP (M2.1) and Forgot Password (M2.2)
4. **Account Management** (M3)
5. **Account Details** (M4)
6. **Send Money** (M5)

## Prerequisites

To run these tests, ensure you have the following installed and configured:

- **Robot Framework**: Installed using Python (e.g., Python 3.14+).
- **Android SDK**: Set the `ANDROID_HOME` or `ANDROID_SDK_ROOT` environment variables. The run script expects this at `~/Library/Android/sdk` by default.
- **Appium**: Required for mobile automation natively via Robot Framework.

## Test Categorization & Structure

Each test module is strictly organized into four distinct architectural blocks to ensure readability and execution logic:

1. **HAPPY PATH**: Standard positive scenarios and successful flows.
2. **NEGATIVE**: Validations around missing inputs, wrong passwords, formatted errors, etc.
3. **RATE LIMITING / DESTRUCTIVE**: Scenarios that deliberately lock or block test accounts (e.g., maximum OTP attempts, account freezing).
4. **SESSION TIMEOUT**: Time-intensive tests (e.g., 5+ minutes of inactivity limits). These are grouped at the very end of the modules so they do not block the faster testing feedback loops.

## E2E Onboarding Tests — Veriff Pre-Completed Email Requirement

The happy path tests **TC_M1.2_002 through TC_M1.2_010** run as a continuous end-to-end chain in a single app session. Because Veriff's camera-based KYC cannot be automated on an emulator, these tests require a **Veriff pre-completed email** to be set up beforehand.

### What is a Veriff pre-completed email?

An email account that has gone through the onboarding flow up to and including Veriff identity verification (completed on a **physical device**), but stopped **before** the Profile screen. When the automated tests resume this email on the emulator, Veriff auto-completes and the flow proceeds to Profile without needing camera interaction.

### How to set one up

1. On a **physical Android device**, launch the Higala app.
2. Tap **Get Started** and enter the new email (e.g. `jjavier+NNN@nmblr.ai`).
3. Enter the magic OTP (`123456`) to verify.
4. Agree to Policy terms and tap **Next**.
5. Fill in Personal Details and tap **Next**.
6. On the Verify Identity screen, fill in ID type, ID number, and tick **My ID has no expiry date**, then tap **Next**.
7. On the **"Verify your ID"** screen, tap **Proceed with Veriff** and complete the Veriff KYC flow (photo of ID + selfie).
8. **Stop here** — do NOT proceed to the Profile screen.

### How to use it

Update `${AC_CHAIN_EMAIL}` in `resources/variables/M1.2_variables.resource` to the freshly prepared email before running:

```robot
${AC_CHAIN_EMAIL}    jjavier+NNN@nmblr.ai
```

> **Important:** Each run of TC_M1.2_002–010 **fully registers and consumes** the chain email (account creation completes at TC_M1.2_010). You must prepare a new Veriff pre-completed email before the next run.

---

## Magic OTPs & Test Data Conventions

When executing these tests in the staging or testing environments, the backend is configured to accept specific "magic" OTP values to facilitate automation without requiring real SMS/Email integrations:
- `000000` = Invalid or expired OTP
- `999999` = Triggers the maximum attempts limit for OTP verification
- *(Any other 6 digits, e.g. `123456`)* = Valid OTP

## Execution

### Running the Full Test Suite

You can execute all the modules sequentially using the provided shell script:

```bash
./run_all_modules.sh
```

This script will:
- Set up necessary environment variables (like `ANDROID_HOME`).
- Create an output directory with a timestamp in the `results/` folder.
- Execute the Robot Framework tests for all modules.
- Generate HTML reports (`log.html`, `report.html`) and XML outputs (`output.xml`) in the timestamped results folder.

### Running Specific Categories (via Tags)

Because the tests are robustly tagged, you can filter executions to skip time-consuming or destructive tests.

Run **only Happy Path** tests:
```bash
robot --include Positive --outputdir results/ Modules/
```

Run tests but **skip Session Timeout** tests (saves multiple 5-minute cooldown waits):
```bash
robot --exclude Session --outputdir results/ Modules/
```

Skip **Destructive/Account Blocking** tests:
```bash
robot --exclude Destructive --outputdir results/ Modules/
```

### Running Individual Tests

To run an individual test module, you can use the `robot` command directly. For example:

```bash
robot --outputdir results/ Modules/AccountCreation/M1.2_Account_Creation.robot
```

## Reports

After test execution, navigate to the newly created `results/full_run_YYYYMMDD_HHMMSS/` directory to view the test reports. Open `report.html` or `log.html` in any web browser to see detailed test steps and their pass/fail status.
