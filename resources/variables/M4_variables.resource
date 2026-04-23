*** Variables ***
# -------------------------------------------------------
# TEST ACCOUNTS — Account Details (M4)
#
# AD_VALID_EMAIL:  jjavier+84@nmblr.ai — savings account with existing transactions.
#                  Used for: m4.1.1, m4.1.2, m4.2.1, m4.2.3, m4.2.4, m4.2.8–14, m4.4.1–2
# AD_MULTI_EMAIL:  jjavier+1@nmblr.ai  — 3 savings products + 1 loan product.
#                  Used for: m4.1.11, m4.1.12, m4.1.13, m4.1.18, m4.1.19, m4.1.20, m4.2.23
# AD_EMPTY_EMAIL:  jjavier+100@nmblr.ai — no transaction history.
#                  Used for: m4.2.5
# NOTE: Loan-specific TCs (m4.1.14, m4.1.15–17, m4.2.24) are Manual/Skipped —
#       loan payment state changes over time and requires manual verification.
# -------------------------------------------------------
${AD_VALID_EMAIL}           jjavier+84@nmblr.ai
${AD_VALID_PASSWORD}        Password!1
${AD_MULTI_EMAIL}           jjavier+1@nmblr.ai
${AD_MULTI_PASSWORD}        Password!1
${AD_EMPTY_EMAIL}           jjavier+100@nmblr.ai
${AD_EMPTY_PASSWORD}        Password!1
# Known search values — update to match actual transactions in AD_VALID_EMAIL account
${AD_KNOWN_NAME}            Joy amban
${AD_KNOWN_ACCT_NO}         4572
${AD_KNOWN_REF_ID}          884797
${AD_KNOWN_AMOUNT}          1
${AD_NO_MATCH_TERM}         XYZ123NOMATCH

# -------------------------------------------------------
# LOCATORS — Bottom Navigation Bar
# Confirmed from screenshots: Home | My QR | History | Profile
# -------------------------------------------------------
${AD_HOME_TAB}              xpath=//android.widget.TextView[@text='Home']
${AD_MY_QR_TAB}             xpath=//android.widget.TextView[@text='My QR']
${AD_HISTORY_TAB}           xpath=//android.widget.TextView[@text='History']
${AD_PROFILE_TAB}           xpath=//android.widget.TextView[@text='Profile']

# -------------------------------------------------------
# LOCATORS — Home Screen
# Confirmed from screenshot:
# - "Acct no: XXXXXXXX" with copy icon
# - "View Account Details" button (outlined)
# - "Your available balance is:" label + amount + eye icon
# - "Send Money" and "Switch Acct" buttons
# - "Recent Transactions" section header + transaction cards
# -------------------------------------------------------
${AD_HOME_SCREEN}           xpath=//android.widget.TextView[contains(@text,'available balance')]
${AD_ACCT_NO_TEXT}          xpath=//android.widget.TextView[contains(@text,'Acct no:')]
${AD_COPY_ACCT_BTN}         xpath=//*[contains(@content-desc,'Copy') or contains(@content-desc,'copy') or @text='Copy' or contains(@resource-id,'copy') or contains(@resource-id,'Copy')]
${AD_VIEW_ACCT_DETAILS_BTN}     xpath=//*[@text='View Account Details']
${AD_HIDE_BALANCE_BTN}      xpath=//android.view.ViewGroup[@clickable='true' and @content-desc='']
${AD_SEND_MONEY_BTN}        xpath=//*[@text='Send Money']
${AD_SWITCH_ACCT_BTN}       xpath=//*[@text='Switch Acct']
${AD_RECENT_TX_HEADER}      xpath=//android.widget.TextView[@text='Recent Transactions']
# My Accounts modal (appears when Switch Acct is tapped)
${AD_MY_ACCOUNTS_MODAL}     xpath=//android.widget.TextView[@text='My Accounts' or contains(@text,'My Accounts')]
# No Transactions placeholder on home
${AD_NO_TX_HOME}            xpath=//android.widget.TextView[contains(@text,'No Transactions Yet')]

# -------------------------------------------------------
# LOCATORS — View Account Details Screen (savings product)
# Confirmed sections: Account Details, Interest Configuration
# -------------------------------------------------------
${AD_ACCT_DETAILS_SCREEN}   xpath=//android.widget.TextView[contains(@text,'Account Details') or contains(@text,'Interest Configuration')]
${AD_PRODUCT_NAME_LABEL}    xpath=//android.widget.TextView[contains(@text,'Product name') or contains(@text,'Product Name')]
${AD_ACCT_TYPE_LABEL}       xpath=//android.widget.TextView[contains(@text,'Account type') or contains(@text,'Account Type')]
${AD_INTEREST_RATE_LABEL}   xpath=//android.widget.TextView[contains(@text,'Interest rate')]
${AD_INTEREST_CONFIG_HDR}   xpath=//android.widget.TextView[contains(@text,'Interest Configuration')]
# Loan-specific labels
${AD_LOAN_NAME_LABEL}       xpath=//android.widget.TextView[@text='Loan Name' or contains(@text,'Loan Name')]
${AD_PAYMENT_DETAILS_HDR}   xpath=//android.widget.TextView[@text='Payment Details']
${AD_LOAN_DETAILS_HDR}      xpath=//android.widget.TextView[@text='Loan Details']
${AD_AMOUNT_DUE_LABEL}      xpath=//android.widget.TextView[contains(@text,'Amount Due')]

# -------------------------------------------------------
# LOCATORS — History Screen
# Confirmed from screenshot:
# - Search bar at top: "Search" placeholder text
# - Month group headers: "Apr 2026", "Mar 2026" (grey text)
# - Transaction cards: Name | -₱amount | Bank | **account | date/time
# -------------------------------------------------------
${AD_HISTORY_SCREEN}        xpath=//android.widget.EditText[@hint='Search']
${AD_SEARCH_BAR}            xpath=//android.widget.EditText[@hint='Search']
${AD_TX_CARD}               xpath=(//android.widget.TextView[contains(@text,'-')])[1]
# Month group header: contains 4-digit year
${AD_MONTH_HEADER}          xpath=//android.widget.TextView[contains(@text,'2026') or contains(@text,'2025') or contains(@text,'2024')]
# Filter option (date range) — verify locator with Appium Inspector
${AD_FILTER_BTN}            xpath=//*[@content-desc='Filter' or @text='Filter' or contains(@resource-id,'filter') or contains(@content-desc,'filter') or contains(@content-desc,'date') or contains(@content-desc,'Date')]
${AD_DATE_FROM_FIELD}       xpath=(//android.widget.EditText)[1]
${AD_DATE_TO_FIELD}         xpath=(//android.widget.EditText)[2]
${AD_APPLY_FILTER_BTN}      xpath=//*[@text='Apply' or @text='Apply Filter' or @text='Done']
# No transactions state on History
${AD_NO_TX_HISTORY}         xpath=//android.widget.TextView[contains(@text,'No transaction') or contains(@text,'no transaction') or contains(@text,'No Transaction') or contains(@text,'empty') or contains(@text,'No history')]
${AD_VIEW_MORE_BTN}         xpath=//*[@text='View More' or @text='View All' or contains(@text,'View More')]

# -------------------------------------------------------
# LOCATORS — Transaction Details Screen
# Confirmed from screenshot:
# - Screen title: "Transaction Details"
# - Amount: ₱115.00 (large text)
# - Card with: "Send Money" header, To, Bank, On, Transaction ID [copy], Instapay Ref No
# - Notes section
# - "Back" button (full-width, dark navy)
# -------------------------------------------------------
${AD_TX_DETAILS_SCREEN}     xpath=//android.widget.TextView[@text='Transaction Details']
${AD_TX_AMOUNT}             xpath=//android.widget.TextView[contains(@text,'₱') and string-length(@text) > 2]
${AD_TX_TYPE_LABEL}         xpath=//android.widget.TextView[@text='Send Money' or @text='Receive Money']
${AD_TX_TO_LABEL}           xpath=//android.widget.TextView[@text='To']
${AD_TX_FROM_LABEL}         xpath=//android.widget.TextView[@text='From']
${AD_TX_BANK_LABEL}         xpath=//android.widget.TextView[@text='Bank']
${AD_TX_ON_LABEL}           xpath=//android.widget.TextView[@text='On']
${AD_TX_ID_LABEL}           xpath=//android.widget.TextView[@text='Transaction ID']
${AD_TX_INSTAPAY_LABEL}     xpath=//android.widget.TextView[@text='Instapay Reference Number']
${AD_TX_NOTES_LABEL}        xpath=//android.widget.TextView[@text='Notes']
${AD_TX_BACK_BTN}           xpath=//*[@text='Back']

# -------------------------------------------------------
# LOCATORS — E-Statement Screen (m4.3)
# Path: Profile → Bank Documents → E-Statement
# -------------------------------------------------------
${AD_BANK_DOCUMENTS_BTN}    xpath=//*[contains(@text,'Bank Document') or contains(@text,'bank document') or contains(@text,'Documents') and contains(@text,'Bank')]
${AD_ESTATEMENT_BTN}        xpath=//*[@text='E-Statement' or contains(@text,'E-Statement')]
${AD_ESTATEMENT_SCREEN}     xpath=//android.widget.TextView[contains(@text,'E-Statement') or contains(@text,'Statement')]
${AD_ESTATEMENT_ITEM}       xpath=(//android.widget.TextView[contains(@text,'2026') or contains(@text,'2025')])[1]
${AD_DOWNLOAD_BTN}          xpath=//*[@text='Download' or @text='download']
${AD_DATE_RANGE_FILTER}     xpath=//*[@text='Date Range' or contains(@text,'Date Range') or contains(@resource-id,'date_range')]

# -------------------------------------------------------
# LOCATORS — Send Money Screen (for m4.2.25, m4.2.26)
# -------------------------------------------------------
${AD_SEND_MONEY_SCREEN}     xpath=//android.widget.TextView[@text='Send Money']
${AD_RECIPIENT_FIELD}       xpath=//android.widget.EditText[contains(@hint,'account') or contains(@hint,'Account') or contains(@hint,'recipient')]
${AD_SEND_SUBMIT_BTN}       xpath=//*[@text='Next' or @text='Continue' or @text='Send']
${AD_SELF_TRANSFER_ERROR}   xpath=//android.widget.TextView[contains(@text,'yourself') or contains(@text,'cannot send')]
${AD_RECENT_ACCTS_SECTION}  xpath=//android.widget.TextView[@text='Recent' or @text='recent' or contains(@text,'Recent Recipient') or contains(@text,'recent recipient')]

# -------------------------------------------------------
# SHARED
# -------------------------------------------------------
${AD_OK_BTN}                xpath=//*[@text='OK' or @text='Ok']
${AD_BACK_ARROW}            xpath=//android.widget.ImageButton[@content-desc='Navigate up' or @content-desc='Back']
${AD_SESSION_TIMEOUT}       xpath=//android.widget.TextView[contains(@text,'session') or contains(@text,'Session') or contains(@text,'timed out')]
${AD_MASKED_BALANCE}        xpath=//android.widget.TextView[contains(@text,'••••')]
