# Higala Mobile App - Automated Test Suite

This repository contains the automated test suite for the **Higala Mobile App**. The tests are written using the [Robot Framework](https://robotframework.org/) and are designed to validate various modules of the mobile application.

## Apps Under Test

### ITG Environment — Regression & Functional Tests

| Field | Value |
|---|---|
| App | Rural Bank of San Antonio (ITG) |
| Version | v0.1.34 |
| Package | `com.higala.ruralbanksanantonioitg` |
| Platform | Android |

### SBX Environment — DFSP Sanity Tests

| Field | San Narciso RB | Abucay RB | Alegre |
|---|---|---|---|
| Checklist | DFSP Toggle Testing Checklist | DFSP Toggle Testing Checklist | DFSP Toggle Testing Checklist |
| Coverage | Mobile_001 – Mobile_024 | Mobile_001 – Mobile_024 | Mobile_001 – Mobile_024 |
| Automated (active) | **11 tests** (all incl. 012, 014, 016) | 9 tests (incl. Mobile_016) | 8 tests |
| Excluded | None (external via Chinabank) | Mobile_012, 014 (`ExternalRCBC`) | Mobile_012, 014, 016 (`ExternalRCBC`) |
| Platform | Android | Android | Android |
| App Package | `com.higala.ruralbankofsannarcisosandbox` | `com.higala.bancoabucay` | `com.higala.alegresandbox` |
| Sender | jjavier+3@nmblr.ai / Password!1 | jjavier+1@nmblr.ai / Password!1 | jjavier+4@nmblr.ai / Password!1 |
| Same-Bank Recipient | Jocelyn Amban — 7710935377438751 | Peach Marie Villados — 7710589946921181 | Kacey Chui — 7710398891916835 |
| RB-to-RB Recipient | Paulo Navarro — 7710737754140432 (via RCBC) | Paulo Navarro — 7710737754140432 (via RCBC) | Paulo Navarro — 7710737754140432 (via RCBC) |
| External Bank | China Banking Corporation (Chinabank) | _(excluded)_ | _(excluded)_ |
| External Recipient | John Doe — 101400001643 | _(excluded)_ | _(excluded)_ |
| Run Script | `run_sanity_sannarciso.sh` | `run_sanity_abucay.sh` | `run_sanity_alegre.sh` |
| OTP | Magic OTP (123456) | Magic OTP (123456) | Magic OTP (123456) |
| Module | `Modules/Sanity/Sanity_SBX.robot` (shared) | `Modules/Sanity/Sanity_SBX.robot` (shared) | `Modules/Sanity/Sanity_SBX.robot` (shared) |

## Codebase Structure

```
Mobile App/
│
├── Modules/                         # Robot Framework test suites, one folder per feature module
│   ├── AccountActivation/
│   │   └── M1.1_Account_Activation.robot
│   ├── AccountCreation/
│   │   └── M1.2_Account_Creation.robot
│   ├── Login/
│   │   ├── M2.1_Login_Email_OTP.robot
│   │   └── M2.2_Forgot_Password.robot
│   ├── AccountManagement/
│   │   └── M3_Account_Management.robot
│   ├── AccountDetails/
│   │   └── M4_Account_Details.robot
│   ├── SendMoney/
│   │   ├── M5_Send_Money.robot          # M5.1, M5.2, M5.6, M5.7, M5.8
│   │   ├── M5.3_QR_Generation.robot
│   │   ├── M5.4_QR_Scan.robot
│   │   └── M5.5_QR_Receive.robot
│   ├── Loans/
│   │   └── M7_Loan_Module.robot         # M7.1, M7.4, M7.5, M7.6
│   └── Sanity/                      # SBX environment sanity tests (shared suite)
│       └── Sanity_SBX.robot
│
├── resources/                       # Shared keywords, libraries, and variables
│   ├── common.robot                 # App setup/teardown, navigation helpers, OTP helpers
│   ├── RecordingLibrary.py          # Custom Python library for screen recording
│   └── variables/                   # Per-module variable files (locators + test accounts)
│       ├── M1.1_variables.resource
│       ├── M1.2_variables.resource
│       ├── M2.2_variables.resource
│       ├── M3_variables.resource
│       ├── M4_variables.resource
│       ├── M5_variables.resource
│       ├── M7_variables.resource    # Loan module test accounts, locators
│       └── SBX_variables.resource   # Alegre SBX test accounts, app config, locators
│
├── APKs/                            # App builds used for testing
│   └── *.apk                        # Rural Bank San Antonio builds
│
├── Automation Doc Reference/        # Source test case spreadsheets (Excel/CSV)
│   └── *.csv / *.xlsx
│
├── results/                         # Robot Framework output (committed for GitHub Pages)
│   ├── <run_folder>/                # Base dir — always contains the latest run (for index.html links)
│   │   ├── log.html
│   │   ├── report.html
│   │   └── output.xml
│   ├── <run_folder>/YYYYMMDD_HHMMSS/  # Timestamped subdir — every run preserved, never overwritten
│   │   ├── log.html
│   │   ├── report.html
│   │   └── output.xml
│   └── ...
│
├── run_all_modules.sh               # Run full test suite sequentially
├── run_m12_happy.sh                 # M1.2 Account Creation — happy path
├── run_m12_negative.sh              # M1.2 Account Creation — negative path
├── run_m21_happy.sh                 # M2.1 Login — happy path
├── run_m21_negative.sh              # M2.1 Login — negative path
├── run_m22_happy.sh                 # M2.2 Forgot Password — happy path
├── run_m22_negative.sh              # M2.2 Forgot Password — negative path
├── run_m3_happy.sh                  # M3 Account Management — happy path
├── run_m5_happy.sh                  # M5 Send Money — happy path
├── run_m5_negative.sh               # M5 Send Money — negative path
├── run_m7_happy.sh                  # M7 Loan Module — happy path
├── run_m7_negative.sh               # M7 Loan Module — negative path
├── run_m21_all.sh                   # M2.1 Login — full run (happy + negative, excludes Session)
├── run_sanity_sannarciso.sh         # SBX sanity — San Narciso Rural Bank (all 11 tests incl. external)
├── run_sanity_abucay.sh             # SBX sanity — Abucay Rural Bank
├── run_sanity_alegre.sh             # SBX sanity — Alegre Rural Bank
├── run_sanity_sbx.sh                # SBX sanity — generic (uses SBX_variables.resource defaults)
├── publish_reports.sh               # Publishes results to GitHub Pages (index.html)
│
├── dump_screen.py                   # Utility: dumps current screen XML via adb
├── parse_xml.py                     # Utility: parses screen XML for element inspection
├── fix_m12_dynamic.py               # One-off script: fixes dynamic email values in M1.2
├── randomize_emails.py              # One-off script: randomizes test email addresses
│
└── README.md
```

## Test Modules

### ITG — Functional / Regression Modules

| Module | File | Description |
|---|---|---|
| M1.2 | `Modules/AccountCreation/M1.2_Account_Creation.robot` | Account Creation (Signup) |
| M1.1 | `Modules/AccountActivation/M1.1_Account_Activation.robot` | Account Activation |
| M2.1 | `Modules/Login/M2.1_Login_Email_OTP.robot` | Login via Email + OTP |
| M2.2 | `Modules/Login/M2.2_Forgot_Password.robot` | Forgot Password |
| M3 | `Modules/AccountManagement/M3_Account_Management.robot` | Account Management |
| M4 | `Modules/AccountDetails/M4_Account_Details.robot` | Account Details |
| M5.1–M5.2, M5.6–M5.8 | `Modules/SendMoney/M5_Send_Money.robot` | Send Money (Internal, External, RB-to-RB) |
| M5.3 | `Modules/SendMoney/M5.3_QR_Generation.robot` | QR Code Generation |
| M5.4 | `Modules/SendMoney/M5.4_QR_Scan.robot` | QR Code Scan |
| M5.5 | `Modules/SendMoney/M5.5_QR_Receive.robot` | QR Receive |

### SBX — Sanity Module

| Module | File | Description |
|---|---|---|
| Sanity | `Modules/Sanity/Sanity_SBX.robot` | End-to-end DFSP sanity tests (shared across all RBs) |

The SBX sanity suite covers 24 test cases from the **DFSP Toggle Testing Checklist**. The same `.robot` file is shared across all RBs — the target bank, credentials, and recipient accounts are passed as `--variable` overrides in each bank's run script. All OTP steps use **Magic OTP (123456)**. No real email access is required for automated tests.

| # | Test Case | Automated | San Narciso | Abucay / Alegre | Notes |
|---|---|---|---|---|---|
| Mobile_001 | Account Creation | Manual | — | — | Requires fresh unregistered email per run |
| Mobile_002 | Onboarding OTP Email Notification | Manual | — | — | Verify inbox after Mobile_001 |
| Mobile_003 | Temp Creds Email Notification | Manual | — | — | Verify inbox after account creation |
| Mobile_004 | Reset Password | Yes | Excluded (`ResetPassword`) | Excluded (`ResetPassword`) | Excluded by default to protect account state |
| Mobile_005 | Reset Password Email Notification | Manual | — | — | Verify inbox after Mobile_004 |
| Mobile_006 | Login | Yes | ✅ PASS | ✅ PASS | Uses Magic OTP |
| Mobile_007 | Login OTP Email Notification | Manual | — | — | Verify inbox during Mobile_006 |
| Mobile_008 | Internal Transfer — New Recipient | Yes | ✅ PASS | ✅ PASS | Uses Magic OTP |
| Mobile_009 | Internal Transfer New Recipient Email Notification | Manual | — | — | Verify inbox after Mobile_008 |
| Mobile_010 | Internal Transfer — Recent Recipient | Yes | ✅ PASS | ✅ PASS | Depends on Mobile_008 |
| Mobile_011 | Internal Transfer Recent Recipient Email Notification | Manual | — | — | Verify inbox after Mobile_010 |
| Mobile_012 | External Transfer — New Recipient | Yes | ✅ PASS | Excluded (`ExternalRCBC`) | San Narciso uses Chinabank; Abucay/Alegre exclude due to RCBC issue |
| Mobile_013 | External Transfer New Recipient Email Notification | Manual | — | — | Verify inbox after Mobile_012 |
| Mobile_014 | External Transfer — Recent Recipient | Yes | ✅ PASS | Excluded (`ExternalRCBC`) | San Narciso uses Chinabank; Abucay/Alegre exclude due to RCBC issue |
| Mobile_015 | External Transfer Recent Recipient Email Notification | Manual | — | — | Verify inbox after Mobile_014 |
| Mobile_016 | External Transfer (RB-to-RB) | Yes | ✅ PASS | ✅ PASS (Abucay) / Excluded (Alegre) | Instapay via RCBC as intermediary |
| Mobile_017 | RB-to-RB Email Notification | Manual | — | — | Verify inbox after Mobile_016 |
| Mobile_018 | Transaction History | Yes | ✅ PASS | ✅ PASS | |
| Mobile_019 | Transaction Details | Yes | ✅ PASS | ✅ PASS | |
| Mobile_020 | View and Edit Profile Details | Yes | ✅ PASS | ✅ PASS | |
| Mobile_021 | Change Password | Yes | ✅ PASS | ✅ PASS | Self-restoring — uses Magic OTP |
| Mobile_022 | Change Password Email Notification | Manual | — | — | Verify inbox after Mobile_021 |
| Mobile_023 | Forgot Password | Yes | ✅ PASS | ✅ PASS | Self-restoring — uses Magic OTP |
| Mobile_024 | Forgot Password Email Notification | Manual | — | — | Verify inbox after Mobile_023 |

> **Mobile_004, 021, 023** are self-restoring — they change the password and immediately restore it, so no manual cleanup is needed between runs.
>
> **Mobile_012, 014** use `ExternalRCBC` tag. San Narciso runs these against **China Banking Corporation** (Chinabank, account: John Doe / 101400001643) — the tag is NOT excluded in `run_sanity_sannarciso.sh`. Abucay and Alegre exclude them due to an ongoing RCBC issue.
>
> **Mobile_016** (RB-to-RB) routes via RCBC as the Instapay intermediary on all banks. Recipient: Paulo Navarro — 7710737754140432. Alegre excludes it; Abucay and San Narciso run it.
>
> **External transfers (012, 014)** include automatic Pending → Success polling (up to 10 × 5s refreshes) and a transaction-level retry (up to 2 attempts) before failing.

## ITG Test Case Traceability

All robot test cases are aligned to the **ITG Full Regression Testing** master document (510 test cases, m1.0–m5.8). Each TC carries its ITG ID as a tag for direct traceability.

### Automation Coverage Summary

| Module | Total TCs | ✅ Automatable | 🔧 Manual | 🔴 Not Automatable |
|---|---|---|---|---|
| M1.0 Splash Page | 2 | 0 | 2 | 0 |
| M1.1 Account Activation | 28 | 25 | 0 | 3 |
| M1.2 Account Creation | 132 | 63 | 69 | 0 |
| M2.1 Login | 46 | 34 | 6 | 6 |
| M2.2 Forgot Password | 37 | 32 | 4 | 0 |
| M3.1–M3.4 Account Management | 53 | 23 | 30 | 0 |
| M4.1–M4.2 Account Details | 44 | 18 | 26 | 0 |
| M5.1–M5.2 Send Money | 115 | 34 | 81 | 0 |
| M5.3–M5.5 QR | 21 | 2 | 19 | 0 |
| M5.6 Scheduled Transfer | 7 | 0 | 7 | 0 |
| M5.7 Favourite Recipients | 4 | 4 | 0 | 0 |
| M5.8 RB-to-RB (multi-device) | 12 | 0 | 0 | 12 |
| **Total** | **510** | **235** | **238** | **21** |

> **Manual** = test exists in robot with `Skip` (requires human interaction, timing, hardware, or email access).
> **Not Automatable** = tagged `NotAutomatable` — structurally impossible to automate on emulator.

### Tag-to-ITG Mapping

Tags follow the format `M<module>.<submodule>.<number>` matching the ITG document exactly:

```bash
# Run a single ITG test case
robot -i M5.1.7 Modules/SendMoney/M5_Send_Money.robot

# Run all automatable tests for a sub-module
robot -i m5.3 -e Manual -e Skipped Modules/SendMoney/M5.3_QR_Generation.robot

# Run all automatable M1.1 tests
robot -e Manual -e Skipped -e NotAutomatable Modules/AccountActivation/M1.1_Account_Activation.robot
```

---

## Appium Inspector Capabilities

Use these JSON capabilities when connecting Appium Inspector to inspect UI elements.

### ITG — Rural Bank of San Antonio

```json
{
  "platformName": "Android",
  "appium:deviceName": "emulator-5554",
  "appium:appPackage": "com.higala.ruralbanksanantonioitg",
  "appium:appActivity": ".MainActivity",
  "appium:automationName": "UiAutomator2",
  "appium:noReset": true,
  "appium:skipDeviceInitialization": true,
  "appium:enforceXPath1": true,
  "appium:newCommandTimeout": 300
}
```

### SBX — Abucay Rural Bank (Sandbox)

```json
{
  "platformName": "Android",
  "appium:deviceName": "emulator-5554",
  "appium:appPackage": "com.higala.bancoabucay",
  "appium:appActivity": ".MainActivity",
  "appium:automationName": "UiAutomator2",
  "appium:noReset": true,
  "appium:skipDeviceInitialization": true,
  "appium:enforceXPath1": true,
  "appium:newCommandTimeout": 300
}
```

### SBX — Alegre (Sandbox)

```json
{
  "platformName": "Android",
  "appium:deviceName": "emulator-5554",
  "appium:appPackage": "com.higala.alegresandbox",
  "appium:appActivity": ".MainActivity",
  "appium:automationName": "UiAutomator2",
  "appium:noReset": true,
  "appium:skipDeviceInitialization": true,
  "appium:enforceXPath1": true,
  "appium:newCommandTimeout": 300
}
```

### SBX — San Narciso (Sandbox)

```json
{
  "platformName": "Android",
  "appium:deviceName": "emulator-5554",
  "appium:appPackage": "com.higala.ruralbankofsannarcisosandbox",
  "appium:appActivity": ".MainActivity",
  "appium:automationName": "UiAutomator2",
  "appium:noReset": true,
  "appium:skipDeviceInitialization": true,
  "appium:enforceXPath1": true,
  "appium:newCommandTimeout": 300
}
```

> Make sure the target app is already open on the emulator before starting a session in Appium Inspector.

---

## Prerequisites

- **Robot Framework** with Python 3.14+
- **AppiumLibrary** for Robot Framework
- **Android SDK** at `~/Library/Android/sdk` (sets `ANDROID_HOME` automatically via run scripts)
- **Appium** server running at `http://127.0.0.1:4723`
- **Android Emulator** or physical device connected (`emulator-5554` by default)

---

## Tag Reference

Tests are tagged for precise execution filtering. Tags fall into two categories: **execution-control** (used in run scripts) and **feature/type** (used for ad-hoc filtering).

### Execution-Control Tags

| Tag | Used In | Meaning |
|---|---|---|
| `Positive` | All modules | Happy path / successful flow tests |
| `Negative` | M2.1, M2.2 | Negative / error-case tests |
| `validation` | M5 | Field validation and negative tests (M5 equivalent of `Negative`) |
| `Destructive` | M1.2, M2.1 | Tests that lock or permanently alter account state (e.g. max OTP attempts) |
| `destructive` | M5 | Lowercase variant used in M5 for the same purpose |
| `Session` | M2.1 | Session timeout tests (long-running, 5+ min waits) |
| `Security` | M2.1, M2.2 | Security-specific scenarios |
| `Manual` | All modules | Tests that require manual steps or cannot run headlessly |
| `Skipped` | All modules | Tests excluded from all automated runs |
| `NotAutomatable` | All modules | Tests that are inherently not automatable (visual checks, hardware dependencies, multi-device) |
| `multi-device` | M5.8 | Tests requiring two simultaneous physical devices |

### Feature / Type Tags

| Tag | Meaning |
|---|---|
| `smoke` | Core smoke-test subset (M5) |
| `otp` | OTP-entry and OTP-related validation tests |
| `block` | Account blocking / rate-limit scenarios |
| `e-statement` | E-statement feature tests (M4) |
| `transaction-history` | Transaction history tests (M4) |
| `account-switching` | Account switching tests (M4) |
| `search` | Search functionality tests (M4) |
| `Navigation` | Navigation flow tests |
| `UI` | UI rendering / display tests |
| `mvp` | MVP-scoped tests |

### Module-Level Tags (auto-applied to every test in a file)

| Tag(s) | Module |
|---|---|
| `Login`, `M2.1`, `OTP`, `Email` | M2.1 Login Email OTP |
| `ForgotPassword`, `M2.2` | M2.2 Forgot Password |
| `AccountCreation`, `M1.2` | M1.2 Account Creation |
| `AccountManagement`, `M3` | M3 Account Management |
| `M4` | M4 Account Details |
| `send-money` | M5 Send Money |

### Individual Test-Case Tags

Each test case carries its own ITG test-case ID tag (e.g. `M1.2.5`, `M2.1.34`, `M5.1.3`) aligned to the **ITG Full Regression Testing** document. This allows pinpoint execution of a single test and direct traceability from robot result to ITG test case:

```bash
robot -i M1.2.5 Modules/AccountCreation/M1.2_Account_Creation.robot
robot -i M5.1.3 Modules/SendMoney/M5_Send_Money.robot
robot -i M2.1.32 Modules/Login/M2.1_Login_Email_OTP.robot
```

> **Note:** M5 tests carry both a specific ID tag (e.g. `M5.1.7`) and a module-level tag (e.g. `m5.1`). Use the specific ID tag for single-test runs; use the module-level tag to run all tests in a sub-module.

---

## Shell Scripts

All run scripts automatically set `ANDROID_HOME`, create the output directory, and invoke `robot` with the appropriate tag filters. Every script saves to a timestamped subfolder (`YYYYMMDD_HHMMSS/`) inside the base dir — previous runs are never overwritten.

### Happy Path Scripts

| Script | Module | Includes | Excludes | Base Output Dir |
|---|---|---|---|---|
| `run_m12_happy.sh` | M1.2 Account Creation | `Positive` | `Manual`, `Skipped` | `results/AccountCreation_HappyPath/` |
| `run_m21_happy.sh` | M2.1 Login | `Positive` | `Manual`, `Skipped` | `results/Login_HappyPath/` |
| `run_m22_happy.sh` | M2.2 Forgot Password | `Positive` | `Negative`, `Session`, `Security`, `Destructive`, `Manual`, `Skipped` | `results/ForgotPassword_HappyPath/` |
| `run_m3_happy.sh` | M3 Account Management | `Positive` | `Destructive` | `results/m3_happy_debug/` |
| `run_m5_happy.sh` | M5 Send Money | `Positive` | `Manual`, `Skipped`, `multi-device` | `results/SendMoney_HappyPath/` |

### Negative Path Scripts

| Script | Module | Includes | Excludes | Base Output Dir |
|---|---|---|---|---|
| `run_m12_negative.sh` | M1.2 Account Creation | `Negative` | `Session`, `Destructive`, `M1.2.19`, `M1.2.25` | `results/AccountCreation_NegativePath/` |
| `run_m21_negative.sh` | M2.1 Login | `Negative` | `Destructive`, `Session`, `Skipped` | `results/Login_NegativePath/` |
| `run_m22_negative.sh` | M2.2 Forgot Password | `Negative` | `Positive`, `Session`, `Security`, `Destructive`, `Manual`, `Skipped` | `results/ForgotPassword_NegativePath/` |
| `run_m5_negative.sh` | M5 Send Money | _(all non-excluded)_ | `Positive`, `destructive`, `multi-device`, `Manual`, `Skipped` | `results/SendMoney_NegativePath/` |

> **Note:** M5 negative tests use `validation` and `otp` tags instead of `Negative`. The negative script filters by exclusion rather than inclusion.

### SBX Sanity Scripts

Each run script saves results to a timestamped subfolder (`results/<NAME>/YYYYMMDD_HHMMSS/`) to preserve history. The base folder is kept in sync with the latest run so `index.html` links remain stable.

| Script | Target RB | Tests Run | Excludes | Base Output Dir |
|---|---|---|---|---|
| `run_sanity_sannarciso.sh` | San Narciso Rural Bank | 11 (all incl. 012, 014, 016) | `Manual`, `Skipped`, `ResetPassword` | `results/Sanity_SanNarciso/` |
| `run_sanity_abucay.sh` | Abucay Rural Bank | 9 (incl. 016) | `Manual`, `Skipped`, `ResetPassword`, `ExternalRCBC` | `results/Sanity_Abucay/` |
| `run_sanity_alegre.sh` | Alegre (Sandbox) | 8 | `Manual`, `Skipped`, `ResetPassword`, `ExternalRCBC` | `results/Sanity_Alegre/` |
| `run_sanity_sbx.sh` | Generic SBX | varies | `Manual`, `Skipped` | `results/Sanity_SBX/` |

**Tag exclusion reference:**

| Excluded Tag | Tests | Reason |
|---|---|---|
| `Manual` | Mobile_001–003, 007, 009, 011, 013, 015, 017, 022, 024 | Email notifications / KYC — verify inbox manually |
| `Skipped` | — | Permanently excluded tests |
| `ResetPassword` | Mobile_004 | Excluded by default to protect account state; run separately when needed |
| `ExternalRCBC` | Mobile_012, 014 (and 016 for Alegre) | Abucay/Alegre exclude external transfers; San Narciso runs all via Chinabank |

**Quick start — San Narciso:**

```bash
./run_sanity_sannarciso.sh
```

Runs all 11 automatable sanity tests against **San Narciso RB** (`com.higala.ruralbankofsannarcisosandbox`) on `emulator-5554`.

> Before running any sanity script, confirm the app is installed and open on the emulator, and that Appium is running at `http://127.0.0.1:4723`.

### Full Suite

```bash
./run_all_modules.sh
```

Runs all modules sequentially. Results are saved to a timestamped folder under `results/`.

---

## Running Tests Manually

### Run a specific module

```bash
robot --outputdir results/ Modules/SendMoney/M5_Send_Money.robot
```

### Filter by tag

```bash
# Happy path only
robot -i Positive -e Manual -e Skipped --outputdir results/ Modules/

# Negative/validation only (skip happy path and destructive)
robot -e Positive -e Destructive -e Manual -e Skipped --outputdir results/ Modules/

# Skip slow session-timeout tests
robot -e Session --outputdir results/ Modules/

# Skip destructive account-blocking tests
robot -e Destructive --outputdir results/ Modules/

# Run a single test case by ID
robot -i M5.1 Modules/SendMoney/M5_Send_Money.robot
```

---

## Account Creation — Veriff Bypass Email Setup

Because Veriff's camera-based KYC cannot be automated on an emulator, the Account Creation tests require specific **Veriff pre-completed emails** before running. Without these emails set up correctly, both the happy path and negative path will stall or fail at the Veriff step.

There are **three separate email variables** in `resources/variables/M1.2_variables.resource` that must be prepared:

| Variable | Used By | Consumed Per Run? |
|---|---|---|
| `${AC_CHAIN_EMAIL}` | Happy path chain TC_M1.2_002–010 | Yes — update after every run |
| `${AC_HAPPY_PV_EMAIL}` | Happy path TC_M1.2_007–010 (post-Veriff screens) | Yes — update after every full happy path run |
| `${AC_POST_VERIFF_EMAIL}` | Negative path post-Veriff validations (Profile, MMN, Address, Financial Info) | No — reused across negative tests (state cascades) |

---

### What is a Veriff pre-completed email?

An email that has gone through the onboarding flow up to and including Veriff KYC (completed on a **physical device**), but stopped **before** the Profile screen. When the automated tests resume this email on the emulator, Veriff auto-completes and the flow proceeds directly to the Profile screen — no camera interaction needed.

---

### How to prepare a Veriff pre-completed email

> Do this on a **physical Android device**, not the emulator.

1. Launch the Higala app and tap **Get Started**.
2. Enter a fresh email (e.g. `yourname+NNN@nmblr.ai`).
3. Enter the magic OTP `123456` to verify.
4. Agree to Policy terms and tap **Next**.
5. Fill in Personal Details and tap **Next**.
6. On the **Verify Identity** screen, fill in ID type and ID number, tick **My ID has no expiry date**, then tap **Next**.
7. On the **"Verify your ID"** screen, tap **Proceed with Veriff** and complete the full Veriff KYC flow (photo of ID + selfie).
8. **Stop immediately after Veriff completes — do NOT proceed to the Profile screen.**

---

### Before each Happy Path run (`run_m12_happy.sh`)

You need **two fresh Veriff pre-completed emails** — one for the chain and one for the post-Veriff happy path screens.

Update both variables in `resources/variables/M1.2_variables.resource`:

```robot
# Chain email — used for the full TC_M1.2_002 → TC_M1.2_010 E2E chain
${AC_CHAIN_EMAIL}        yourname+NNN@nmblr.ai

# Post-Veriff happy path email — used for TC_M1.2_007–010 independent navigation tests
${AC_HAPPY_PV_EMAIL}     yourname+MMM@nmblr.ai
```

> **Warning:** Both emails are fully consumed when the happy path run completes (account creation finishes at TC_M1.2_010). Prepare fresh ones before the next run.

---

### Before each Negative Path run (`run_m12_negative.sh`)

The negative path requires **one Veriff pre-completed email** (`${AC_POST_VERIFF_EMAIL}`) for the post-Veriff validation tests (Profile, MMN, Address, Financial Info screens).

```robot
# Post-Veriff negative path email — reused across all negative post-Veriff tests
# State cascades: Profile tests leave email at Profile → 1st MMN test submits Profile → email at MMN, etc.
# After all negative tests complete, email lands at Financial Info (not yet registered).
${AC_POST_VERIFF_EMAIL}  yourname+PPP@nmblr.ai
```

> **Note:** Unlike the happy path emails, `${AC_POST_VERIFF_EMAIL}` is **not consumed** in a single run — the test state cascades through the negative screens without completing registration. However, once it reaches Financial Info, it will need to be replaced or reset before the next full negative path run.

---

### Quick Checklist Before Running Account Creation Tests

**Happy Path (`run_m12_happy.sh`):**
- [ ] `${AC_CHAIN_EMAIL}` — fresh Veriff pre-completed email (never reached Profile)
- [ ] `${AC_HAPPY_PV_EMAIL}` — fresh Veriff pre-completed email (never reached Profile)
- [ ] `${AC_SIGNUP_EMAIL_1}` through `${AC_SIGNUP_EMAIL_6}` — not blocked (no more than 2 OTP requests in last 15 min)
- [ ] Appium server running (`appium`)
- [ ] Android emulator booted (`emulator-5554`)

**Negative Path (`run_m12_negative.sh`):**
- [ ] `${AC_POST_VERIFF_EMAIL}` — Veriff pre-completed email, currently at the correct state for where the negative tests resume
- [ ] `${AC_SIGNUP_EMAIL_1}` through `${AC_SIGNUP_EMAIL_6}` — not blocked
- [ ] `${AC_BLOCK_EMAIL}` — not currently blocked (unless intentionally running Destructive tests)
- [ ] Appium server running (`appium`)
- [ ] Android emulator booted (`emulator-5554`)

---

## Magic OTPs & Test Data Conventions

The staging/test backend accepts specific "magic" OTP values to facilitate automation:

| OTP | Behavior |
|---|---|
| `000000` | Invalid or expired OTP |
| `999999` | Triggers maximum OTP attempts lockout |
| Any other 6 digits (e.g. `123456`) | Valid OTP — proceeds normally |

---

## Reports

After execution, open `report.html` or `log.html` from the output directory in any browser to see detailed test steps and pass/fail status.
