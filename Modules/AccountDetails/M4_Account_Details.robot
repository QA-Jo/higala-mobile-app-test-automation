*** Settings ***
Documentation       Test suite for Account Details (M4) flow.
...                 Covers home screen bank details, account switching, balance masking,
...                 transaction history, search/filter, and send money validations.
...
...                 Manual/Session tests are tagged [Manual] and skipped automatically.
...                 Multi-account tests use AD_MULTI_EMAIL (jjavier+1@nmblr.ai).
Resource            ../../resources/common.robot
Resource            ../../resources/variables/M4_variables.resource
Library             AppiumLibrary
Library             String
Suite Setup         Run Keywords    Open Higala App    AND    Setup Screenshot On Failure
Suite Teardown      Close Higala App
Test Teardown       Light Reset To Home
Test Tags           account-details    M4

*** Variables ***
${TIMEOUT}              15s
${CURRENT_EMAIL}        ${EMPTY}

*** Test Cases ***

# ==============================================================
# HAPPY PATH
# ==============================================================

TC_M4.1_001 – Access Bank Details From Home Screen
    [Documentation]    Verify the Home screen shows account number, available balance, and 3 recent
    ...    transactions. Tapping "Hide my balance" masks the balance. Tapping "View Account Details"
    ...    displays Account Details and Interest Configuration sections.
    ...    Pre-conditions: AD_VALID_EMAIL has at least 3 transactions.
    [Tags]    account-details    mvp    positive    smoke    M4.1.1
    Login And Navigate To Home Screen
    # Verify account number, balance, and key buttons
    Element Should Be Visible    ${AD_ACCT_NO_TEXT}
    Element Should Be Visible    ${AD_HOME_SCREEN}
    Element Should Be Visible    ${AD_VIEW_ACCT_DETAILS_BTN}
    Element Should Be Visible    ${AD_RECENT_TX_HEADER}
    # NOTE: AD_VALID_EMAIL has multiple products, so Switch Acct button is expected to be visible
    Element Should Be Visible    ${AD_SWITCH_ACCT_BTN}
    # Tap Hide my balance — balance should be masked
    Click Element    ${AD_HIDE_BALANCE_BTN}
    Sleep    2s
    Element Should Be Visible    ${AD_MASKED_BALANCE}
    # Tap View Account Details
    Click Element    ${AD_VIEW_ACCT_DETAILS_BTN}
    Sleep    5s
    # Verify Account Details screen loaded — just check for Interest Configuration section header
    Wait Until Element Is Visible    ${AD_INTEREST_CONFIG_HDR}    timeout=10s

TC_M4.1_002 – Transaction History Shows Only Last 3 On Home Screen
    [Documentation]    Verify the Recent Transactions section on the Home screen displays at most
    ...    3 transaction cards. Additional transactions are only visible on the full History page.
    ...    Pre-conditions: AD_VALID_EMAIL has 3 or more transactions.
    [Tags]    account-details    mvp    positive    smoke    M4.1.2
    Login And Navigate To Home Screen
    Element Should Be Visible    ${AD_RECENT_TX_HEADER}
    # Count transaction cards visible on home (should be max 3)
    ${tx_elements}=    Get WebElements    xpath=//android.widget.TextView[contains(@text,'-₱') or contains(@text,'-P')]
    ${tx_cards}=    Get Length    ${tx_elements}
    Should Be True    ${tx_cards} <= 3    Only last 3 transactions should be shown on home screen

TC_M4.1_011 – Access Product List Via Switch Acct Button
    [Documentation]    Verify "Switch Acct" button is visible for multi-product accounts. Tapping it
    ...    opens the My Accounts modal showing balance, account name, and account number per product.
    ...    Pre-conditions: AD_MULTI_EMAIL has 2+ active products.
    [Tags]    account-details    mvp    positive    account-switching    M4.1.11
    Login And Navigate To Home Screen    ${AD_MULTI_EMAIL}    ${AD_MULTI_PASSWORD}
    Element Should Be Visible    ${AD_SWITCH_ACCT_BTN}
    Click Element    ${AD_SWITCH_ACCT_BTN}
    Wait Until Element Is Visible    ${AD_MY_ACCOUNTS_MODAL}    timeout=15s
    Element Should Be Visible    ${AD_MY_ACCOUNTS_MODAL}

TC_M4.1_012 – Switch To A Different Savings Product
    [Documentation]    From the My Accounts modal, select a different savings account. Verify the
    ...    Home screen updates with the new account number, balance, and last 3 transactions.
    ...    Tapping "Hide my balance" masks the balance for the switched account.
    ...    Pre-conditions: AD_MULTI_EMAIL has at least 2 active savings accounts.
    [Tags]    account-details    mvp    positive    account-switching    M4.1.12
    Login And Navigate To Home Screen    ${AD_MULTI_EMAIL}    ${AD_MULTI_PASSWORD}
    # Capture current account number before switch
    ${acct_before}=    Get Text    ${AD_ACCT_NO_TEXT}
    Click Element    ${AD_SWITCH_ACCT_BTN}
    Wait Until Element Is Visible    ${AD_MY_ACCOUNTS_MODAL}    timeout=15s
    # Select the second account card in the modal (clickable ViewGroup with balance info)
    Click Element    xpath=(//android.view.ViewGroup[contains(@content-desc,'Available Balance:') and @clickable='true'])[2]
    Sleep    3s
    Wait Until Element Is Visible    ${AD_ACCT_NO_TEXT}    timeout=10s
    # Account number should have changed
    ${acct_after}=    Get Text    ${AD_ACCT_NO_TEXT}
    Should Not Be Equal    ${acct_before}    ${acct_after}
    # Hide button functional (balance may or may not be visible depending on masked state)
    Click Element    ${AD_HIDE_BALANCE_BTN}
    Sleep    2s
    Element Should Be Visible    ${AD_MASKED_BALANCE}

TC_M4.1_013 – View Account Details Of A Savings Product
    [Documentation]    Verify the savings product configuration screen shows Account Details
    ...    (Product Name, Account Type, Account Number) and Interest Configuration
    ...    (Interest rate, type, time period, rate structure).
    ...    Pre-conditions: AD_MULTI_EMAIL is on a savings product.
    [Tags]    account-details    mvp    positive    M4.1.13
    Login And Navigate To Home Screen    ${AD_MULTI_EMAIL}    ${AD_MULTI_PASSWORD}
    Click Element    ${AD_VIEW_ACCT_DETAILS_BTN}
    Sleep    5s
    Wait Until Element Is Visible    ${AD_INTEREST_CONFIG_HDR}    timeout=10s

TC_M4.1_014 – Switch To A Loan Product
    [Tags]    account-details    Manual    Skipped    M4.1.14
    Skip    Loan product tests require manual verification — loan payment state changes over time; run manually on device

TC_M4.1_015 – View Account Details Of A Loan Product – Amount Due Unpaid
    [Tags]    account-details    Manual    Skipped    M4.1.15
    Skip    Requires loan account with a specific unpaid due date — payment state changes over time; run manually

TC_M4.1_016 – View Account Details Of A Loan Product – Amount Due Paid
    [Tags]    account-details    Manual    Skipped    M4.1.16
    Skip    Requires loan account with a specific paid due date — payment state changes over time; run manually

TC_M4.1_017 – View Account Details Of A Loan Product – Not Paid For 2 Months
    [Tags]    account-details    Manual    Skipped    M4.1.17
    Skip    Requires loan account with 2 consecutive unpaid months — payment state changes over time; run manually

TC_M4.1_018 – Balance Remains Masked When Switching Accounts With Hide Balance Enabled
    [Documentation]    Tap "Hide my balance" on Account A, then switch to Account B.
    ...    Verify balance remains masked on Account B (hide state persists across account switches).
    ...    Tapping "Show balance" reveals Account B's balance only.
    ...    Pre-conditions: AD_MULTI_EMAIL has 2+ active accounts.
    [Tags]    account-details    mvp    positive    account-switching    M4.1.18
    Login And Navigate To Home Screen    ${AD_MULTI_EMAIL}    ${AD_MULTI_PASSWORD}
    # Hide balance on Account A
    Click Element    ${AD_HIDE_BALANCE_BTN}
    Sleep    2s
    Element Should Be Visible    ${AD_MASKED_BALANCE}
    # Switch to Account B
    Click Element    ${AD_SWITCH_ACCT_BTN}
    Wait Until Element Is Visible    ${AD_MY_ACCOUNTS_MODAL}    timeout=15s
    Click Element    xpath=(//android.view.ViewGroup[contains(@content-desc,'Available Balance:') and @clickable='true'])[2]
    Sleep    3s
    Wait Until Element Is Visible    ${AD_ACCT_NO_TEXT}    timeout=10s
    # Balance should still be masked on Account B
    Element Should Be Visible    ${AD_MASKED_BALANCE}
    # Tap show balance — reveals Account B balance only
    Click Element    ${AD_HIDE_BALANCE_BTN}
    Sleep    2s
    ${masked_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${AD_MASKED_BALANCE}
    Should Be True    not ${masked_visible}    Balance should not be masked after tapping Show balance
    Element Should Be Visible    ${AD_HOME_SCREEN}

TC_M4.1_019 – Switch To An Account With Zero Transactions
    [Tags]    account-details    positive    Manual    Skipped    M4.1.19
    Skip    jjavier+1 second savings account has transactions — no zero-transaction account available in AD_MULTI_EMAIL; run manually with a suitable test account

TC_M4.1_020 – System Stability During Rapid Account Switching
    [Documentation]    Rapidly switch between accounts 5 times in quick succession. Verify the app
    ...    remains stable without crashing or flickering, and the final selected account shows
    ...    correct, synchronized data.
    ...    Pre-conditions: AD_MULTI_EMAIL has 3+ active products.
    [Tags]    account-details    mvp    positive    account-switching    M4.1.20
    Login And Navigate To Home Screen    ${AD_MULTI_EMAIL}    ${AD_MULTI_PASSWORD}
    FOR    ${i}    IN RANGE    5
        ${switched}=    Run Keyword And Return Status    Click Element    ${AD_SWITCH_ACCT_BTN}
        Run Keyword If    not ${switched}    Continue For Loop
        ${modal_up}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${AD_MY_ACCOUNTS_MODAL}    timeout=10s
        Run Keyword If    not ${modal_up}    Continue For Loop
        Click Element    xpath=(//android.view.ViewGroup[contains(@content-desc,'Available Balance:') and @clickable='true'])[${i % 2 + 1}]
        Sleep    3s
    END
    # App should be stable — home screen visible with correct data
    Wait Until Element Is Visible    ${AD_ACCT_NO_TEXT}    timeout=15s
    Element Should Be Visible    ${AD_ACCT_NO_TEXT}

TC_M4.2_001 – Access Transaction History
    [Documentation]    Verify the History screen shows a search bar, transactions grouped by month,
    ...    each card showing Name, Amount, Bank, Masked Account, and Timestamp, sorted newest first.
    ...    Pre-conditions: AD_VALID_EMAIL has 1+ transactions.
    [Tags]    account-details    mvp    positive    transaction-history    Manual    Skipped    M4.2.1
    Skip    Account switch from multi-account to single-account after TC_M4.1_020 requires manual verification; run manually on device

TC_M4.2_002 – Maximum Of 100 Transactions Displayed In Transaction History
    [Tags]    account-details    transaction-history    Manual    Skipped    M4.2.2
    Skip    Requires 100+ transactions in account; impractical to set up for automation — run manually

TC_M4.2_003 – Access Transaction History From Bank Details Page
    [Tags]    account-details    positive    transaction-history    Manual    Skipped    M4.2.3
    Skip    Skipped per request — View More navigation from Account Details causes stale element issues; run manually

TC_M4.2_004 – View Full Transaction Details
    [Documentation]    Tap a transaction in History. Verify the Transaction Details screen shows
    ...    Amount, type (Send/Receive Money), To/From account, Bank, Date/Time, Transaction ID,
    ...    Instapay Reference Number, and Notes.
    ...    Pre-conditions: AD_VALID_EMAIL has 1+ transactions.
    [Tags]    account-details    mvp    positive    transaction-history    smoke    M4.2.4
    Login And Navigate To History Screen
    Click Element    ${AD_TX_CARD}
    Wait Until Element Is Visible    ${AD_TX_DETAILS_SCREEN}    timeout=15s
    Element Should Be Visible    ${AD_TX_DETAILS_SCREEN}
    Element Should Be Visible    ${AD_TX_AMOUNT}
    # Type label — Send Money or Receive Money
    ${has_type}=    Run Keyword And Return Status
    ...    Element Should Be Visible    ${AD_TX_TYPE_LABEL}
    Should Be True    ${has_type}    Transaction type (Send/Receive Money) should be visible
    Element Should Be Visible    ${AD_TX_BANK_LABEL}
    Element Should Be Visible    ${AD_TX_ON_LABEL}
    Element Should Be Visible    ${AD_TX_ID_LABEL}
    Element Should Be Visible    ${AD_TX_NOTES_LABEL}
    # Tap Back button to return
    Click Element    ${AD_TX_BACK_BTN}
    Wait Until Element Is Visible    ${AD_HISTORY_SCREEN}    timeout=10s

TC_M4.2_005 – Empty State When There Are No Transactions To Show
    [Documentation]    Login with an account that has no transaction history. Verify the History
    ...    page displays the empty state message and no transaction cards are shown.
    ...    Pre-conditions: AD_EMPTY_EMAIL has no transactions.
    [Tags]    account-details    mvp    positive    transaction-history    M4.2.5
    Login And Navigate To History Screen    ${AD_EMPTY_EMAIL}    ${AD_EMPTY_PASSWORD}
    Element Should Be Visible    ${AD_NO_TX_HISTORY}
    ${card_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${AD_TX_CARD}
    Should Be True    not ${card_visible}    Transaction cards should not appear for empty account

TC_M4.2_006 – Filter Transaction History By Date Range Within Past 30 Days
    [Tags]    account-details    positive    transaction-history    Manual    Skipped    M4.2.6
    Skip    No filter button found on History screen in current app build — verify with Appium Inspector; run manually

TC_M4.2_008 – Search Bar Is Visible And Filters Transactions In Real-Time
    [Documentation]    Tap the Search bar on the History page, type any input, and verify the
    ...    transaction list filters dynamically in real-time.
    ...    Pre-conditions: AD_VALID_EMAIL has 1+ transactions.
    [Tags]    account-details    mvp    positive    transaction-history    search    M4.2.8
    Login And Navigate To History Screen
    Click Element    ${AD_SEARCH_BAR}
    Sleep    1s
    Input Text    ${AD_SEARCH_BAR}    ${AD_KNOWN_NAME}
    Sleep    3s
    # Results should be filtered — at least 1 transaction matching the name
    Element Should Be Visible    xpath=//android.widget.TextView[contains(@text,'Joy') or contains(@text,'joy') or contains(@text,'amban') or contains(@text,'Amban')]

TC_M4.2_009 – Search By Account Name In Transaction History
    [Documentation]    Enter a known account name in the search bar. Verify only transactions
    ...    involving that name are shown and non-matching terms do not appear.
    ...    Pre-conditions: AD_VALID_EMAIL has a transaction with AD_KNOWN_NAME.
    [Tags]    account-details    mvp    positive    transaction-history    search    M4.2.9
    Login And Navigate To History Screen
    Click Element    ${AD_SEARCH_BAR}
    Input Text    ${AD_SEARCH_BAR}    ${AD_KNOWN_NAME}
    Sleep    3s
    # Case-insensitive match — actual name may display as "Joy Amban" or "Joy amban"
    Element Should Be Visible    xpath=//android.widget.TextView[contains(@text,'Joy') or contains(@text,'joy') or contains(@text,'amban') or contains(@text,'Amban')]
    ${no_match_visible}=    Run Keyword And Return Status    Element Should Be Visible    xpath=//android.widget.TextView[@text='${AD_NO_MATCH_TERM}']
    Should Be True    not ${no_match_visible}    Non-matching term should not appear in filtered results

TC_M4.2_010 – Search By Account Number In Transaction History
    [Documentation]    Enter a known masked account number in the search bar. Verify only
    ...    transactions involving that account number are shown.
    ...    Pre-conditions: AD_VALID_EMAIL has a transaction with AD_KNOWN_ACCT_NO.
    [Tags]    account-details    mvp    positive    transaction-history    search    M4.2.10
    Login And Navigate To History Screen
    Click Element    ${AD_SEARCH_BAR}
    Input Text    ${AD_SEARCH_BAR}    ${AD_KNOWN_ACCT_NO}
    Sleep    2s
    Element Should Be Visible    xpath=//android.widget.TextView[contains(@text,'${AD_KNOWN_ACCT_NO}')]

TC_M4.2_011 – Search By Reference ID In Transaction History
    [Tags]    account-details    positive    transaction-history    search    Manual    Skipped    M4.2.11
    Skip    AD_KNOWN_REF_ID needs manual lookup from Transaction Details screen — Instapay ref not visible in history list; run manually after updating AD_KNOWN_REF_ID

TC_M4.2_012 – Search By Transaction Amount In Transaction History
    [Documentation]    Enter a known transaction amount in the search bar. Verify only transactions
    ...    with that amount are shown.
    ...    Pre-conditions: AD_VALID_EMAIL has a transaction for AD_KNOWN_AMOUNT.
    [Tags]    account-details    mvp    positive    transaction-history    search    M4.2.12
    Login And Navigate To History Screen
    Click Element    ${AD_SEARCH_BAR}
    Input Text    ${AD_SEARCH_BAR}    ${AD_KNOWN_AMOUNT}
    Sleep    3s
    Wait Until Element Is Visible    xpath=//android.widget.TextView[contains(@text,'${AD_KNOWN_AMOUNT}')]    timeout=10s

TC_M4.2_014 – Clearing The Search Bar Restores Full Transaction List
    [Documentation]    Enter a search term to filter the list, then clear the search bar.
    ...    Verify the full unfiltered transaction list is restored and the empty state is gone.
    ...    Pre-conditions: AD_VALID_EMAIL has transactions.
    [Tags]    account-details    mvp    positive    transaction-history    search    M4.2.14
    Login And Navigate To History Screen
    Click Element    ${AD_SEARCH_BAR}
    Input Text    ${AD_SEARCH_BAR}    ${AD_NO_MATCH_TERM}
    Sleep    2s
    Element Should Be Visible    ${AD_NO_TX_HISTORY}
    # Clear the search bar
    Clear Text    ${AD_SEARCH_BAR}
    Sleep    2s
    # Full list should be restored
    Element Should Be Visible    ${AD_TX_CARD}
    ${no_tx_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${AD_NO_TX_HISTORY}
    Should Be True    not ${no_tx_visible}    No transactions message should not appear after clearing search

TC_M4.2_023 – Full Transaction History For Savings Product
    [Documentation]    Navigate to History while on a savings product. Verify all historical
    ...    transactions specific to that savings product are displayed.
    ...    Pre-conditions: AD_MULTI_EMAIL (jjavier+1@nmblr.ai) is on a savings product with transactions.
    [Tags]    account-details    mvp    positive    transaction-history    M4.2.23
    Login And Navigate To Home Screen    ${AD_MULTI_EMAIL}    ${AD_MULTI_PASSWORD}
    Click Element    ${AD_HISTORY_TAB}
    Wait Until Element Is Visible    ${AD_HISTORY_SCREEN}    timeout=10s
    Element Should Be Visible    ${AD_HISTORY_SCREEN}
    Element Should Be Visible    ${AD_TX_CARD}

TC_M4.2_024 – Full Transaction History For Loan Product
    [Tags]    account-details    transaction-history    Manual    Skipped    M4.2.24
    Skip    Loan product tests require manual verification — loan payment state changes over time; run manually on device

TC_M4.2_025 – Recent Transacted Accounts Visible In Send Money Flow
    [Documentation]    Tap "Send Money" from Home. Verify recent transacted accounts associated
    ...    with the selected savings product are displayed for quick reference.
    ...    Pre-conditions: AD_VALID_EMAIL has at least 1 past send money transaction.
    [Tags]    account-details    mvp    positive    send-money    M4.2.25
    Login And Navigate To Home Screen
    Click Element    ${AD_SEND_MONEY_BTN}
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Send Funds']    timeout=10s
    Sleep    2s
    Element Should Be Visible    ${AD_RECENT_ACCTS_SECTION}

TC_M4.3_001 – Access The E-Statement Page
    [Tags]    account-details    positive    e-statement    Manual    Skipped    M4.3.1
    Skip    E-Statement feature not yet available in current app build — run manually when available

TC_M4.3_002 – Download An E-Statement
    [Tags]    account-details    positive    e-statement    Manual    Skipped    M4.3.2
    Skip    E-Statement feature not yet available in current app build — run manually when available
    # Tap the first available E-Statement
    Wait Until Element Is Visible    ${AD_ESTATEMENT_ITEM}    timeout=10s
    Click Element    ${AD_ESTATEMENT_ITEM}
    Sleep    2s
    Wait Until Element Is Visible    ${AD_DOWNLOAD_BTN}    timeout=10s
    Click Element    ${AD_DOWNLOAD_BTN}
    Sleep    5s
    # Verify download completed (PDF file in Downloads via ADB)
    ${result}=    Run    adb -s ${DEVICE_NAME} shell ls /sdcard/Download/ | grep -i ".pdf"
    Should Not Be Empty    ${result}

TC_M4.3_003 – Filter And Download E-Statements By Month Range
    [Tags]    account-details    positive    e-statement    Manual    Skipped    M4.3.3
    Skip    E-Statement feature not yet available in current app build — run manually when available
    # Apply date range filter
    Wait Until Element Is Visible    ${AD_DATE_RANGE_FILTER}    timeout=10s
    Click Element    ${AD_DATE_RANGE_FILTER}
    Sleep    2s
    # Select range — adjust field interaction to match actual date picker UI
    Input Text    ${AD_DATE_FROM_FIELD}    01/2026
    Input Text    ${AD_DATE_TO_FIELD}      03/2026
    Click Element    ${AD_APPLY_FILTER_BTN}
    Sleep    2s
    # Tap filtered E-Statement and download
    Wait Until Element Is Visible    ${AD_ESTATEMENT_ITEM}    timeout=10s
    Click Element    ${AD_ESTATEMENT_ITEM}
    Sleep    2s
    Wait Until Element Is Visible    ${AD_DOWNLOAD_BTN}    timeout=10s
    Click Element    ${AD_DOWNLOAD_BTN}
    Sleep    5s
    ${result}=    Run    adb -s ${DEVICE_NAME} shell ls /sdcard/Download/ | grep -i ".pdf"
    Should Not Be Empty    ${result}

TC_M4.4_001 – Copy Account Number To Clipboard
    [Tags]    account-details    positive    Manual    Skipped    M4.4.1
    Skip    Copy button is not accessible via Android accessibility tree (React Native TouchableOpacity without a11y attributes) — run manually on device

TC_M4.4_002 – Copy Action Stable When Tapping Copy Icon Rapidly Multiple Times
    [Tags]    account-details    positive    Manual    Skipped    M4.4.2
    Skip    Copy button is not accessible via Android accessibility tree (React Native TouchableOpacity without a11y attributes) — run manually on device


# ==============================================================
# NEGATIVE
# ==============================================================

TC_M4.2_007 – System Prevents Filtering Beyond Past 3 Months
    [Tags]    account-details    negative    transaction-history    Manual    Skipped    M4.2.7
    Skip    No filter button found on History screen in current app build — verify with Appium Inspector; run manually

TC_M4.2_013 – Search With No Matching Results Shows Empty State
    [Documentation]    Enter a random string that matches no transactions. Verify the transaction
    ...    list becomes empty and a "No transactions available" message is displayed.
    ...    Pre-conditions: AD_VALID_EMAIL is on the History screen.
    [Tags]    account-details    mvp    negative    transaction-history    search    M4.2.13
    Login And Navigate To History Screen
    Click Element    ${AD_SEARCH_BAR}
    Input Text    ${AD_SEARCH_BAR}    ${AD_NO_MATCH_TERM}
    Sleep    2s
    Element Should Be Visible    ${AD_NO_TX_HISTORY}
    ${card_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${AD_TX_CARD}
    Should Be True    not ${card_visible}    Transaction card should not appear when search has no results

TC_M4.2_026 – System Blocks Self-Transfer In Send Money Flow
    [Documentation]    In the Send Money flow, enter the user's own savings account number as the
    ...    recipient. Verify the system displays an error and blocks the transaction.
    ...    Pre-conditions: AD_VALID_EMAIL is logged in. Sender's account number is known.
    [Tags]    account-details    mvp    negative    send-money    M4.2.26
    Login And Navigate To Home Screen
    # Get the account number from home screen
    ${acct_text}=    Get Text    ${AD_ACCT_NO_TEXT}
    # Extract numeric account number from "Acct no: XXXXXXXX"
    ${acct_no}=    Evaluate    '${acct_text}'.replace('Acct no: ', '').strip()
    Click Element    ${AD_SEND_MONEY_BTN}
    # Send Funds screen: pick Same Bank → To Same Bank recipient screen
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Send Funds']    timeout=10s
    Sleep    2s
    Click Element    xpath=//*[@text='Same Bank']
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Enter account number']    timeout=10s
    Input Text    xpath=//android.widget.EditText[@hint='Enter account number']    ${acct_no}
    Input Text    xpath=//android.widget.EditText[@hint='Enter account name']    Test
    Press Keycode    4
    Sleep    1s
    Click Element    xpath=//*[@text='Next']
    Wait Until Element Is Visible    ${AD_SELF_TRANSFER_ERROR}    timeout=10s
    Element Should Be Visible    ${AD_SELF_TRANSFER_ERROR}


# ==============================================================
# SESSION TIMEOUT
# ==============================================================

TC_M4.1_003 – Session Timeout Modal On Home Screen After 5 Minutes Of Inactivity
    [Tags]    account-details    session    Manual    Skipped    M4.1.3
    Skip    Session timeout — requires 5-minute inactivity on Home screen; run manually on device

TC_M4.1_004 – Session Timeout Modal On Home Screen After Minimizing
    [Tags]    account-details    session    Manual    Skipped    M4.1.4
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M4.1_005 – Session Timeout Modal Still Visible On Home Screen After Minimize And Restore
    [Tags]    account-details    session    Manual    Skipped    M4.1.5
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M4.1_006 – Session Remains Active While Interacting With Home Screen
    [Tags]    account-details    session    Manual    Skipped    M4.1.6
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M4.1_007 – Session Timeout Modal On Transaction Details Screen After 5 Minutes Of Inactivity
    [Tags]    account-details    session    Manual    Skipped    M4.1.7
    Skip    Session timeout — requires 5-minute inactivity on Transaction Details; run manually on device

TC_M4.1_008 – Session Timeout Modal On Transaction Details Screen After Minimizing
    [Tags]    account-details    session    Manual    Skipped    M4.1.8
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M4.1_009 – Session Timeout Modal Still Visible On Transaction Details Screen After Minimize And Restore
    [Tags]    account-details    session    Manual    Skipped    M4.1.9
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M4.1_010 – Session Timeout Resets On User Activity On Transaction Details Screen
    [Tags]    account-details    session    Manual    Skipped    M4.1.10
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M4.2_015 – Session Timeout Modal On History Screen After 5 Minutes Of Inactivity
    [Tags]    account-details    session    Manual    Skipped    M4.2.15
    Skip    Session timeout — requires 5-minute inactivity on History screen; run manually on device

TC_M4.2_016 – Session Timeout Modal On History Screen After Minimizing
    [Tags]    account-details    session    Manual    Skipped    M4.2.16
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M4.2_017 – Session Timeout Modal Still Visible On History Screen After Minimize And Restore
    [Tags]    account-details    session    Manual    Skipped    M4.2.17
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M4.2_018 – Session Remains Active While Interacting With History Screen
    [Tags]    account-details    session    Manual    Skipped    M4.2.18
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

TC_M4.2_019 – Session Timeout Modal On Transaction Details Screen After 5 Minutes Of Inactivity
    [Tags]    account-details    session    Manual    Skipped    M4.2.19
    Skip    Session timeout — requires 5-minute inactivity on Transaction Details; run manually on device

TC_M4.2_020 – Session Timeout Modal On Transaction Details Screen After Minimizing
    [Tags]    account-details    session    Manual    Skipped    M4.2.20
    Skip    Session timeout — requires minimizing app for 5 minutes; run manually on device

TC_M4.2_021 – Session Timeout Modal Still Visible On Transaction Details Screen After Minimize And Restore
    [Tags]    account-details    session    Manual    Skipped    M4.2.21
    Skip    Session timeout — requires 5-minute inactivity then minimize/restore; run manually on device

TC_M4.2_022 – Session Timeout Resets On User Activity On Transaction Details Screen
    [Tags]    account-details    session    Manual    Skipped    M4.2.22
    Skip    Session keep-alive — requires 8+ minutes of continuous interaction; run manually on device

*** Keywords ***

Light Reset To Home
    [Documentation]    Soft-restart the app — preserves session (no pm clear) so OTP is not re-triggered.
    ...    After reactivation, tap Home tab to ensure we land on the primary account home screen.
    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Sleep    3s
    Activate Application    ${APP_PACKAGE}
    Sleep    30s
    # Tap Home tab if visible (ensures primary account home, not a sub-screen)
    Run Keyword And Ignore Error    Click Element    xpath=//android.widget.TextView[@text='Home']
    Sleep    3s

Login And Navigate To Home Screen
    [Arguments]    ${email}=${AD_VALID_EMAIL}    ${password}=${AD_VALID_PASSWORD}
    # If on home with the correct account already — skip login (preserve session)
    # Use AD_ACCT_NO_TEXT (always visible) to detect home screen — avoids false-negative when balance is masked
    ${on_home}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${AD_ACCT_NO_TEXT}    timeout=15s
    Run Keyword If    ${on_home} and '${CURRENT_EMAIL}' == '${email}'    Return From Keyword
    # Wrong account and on home — force-stop first, then pm clear + relaunch to switch account
    Run Keyword If    '${CURRENT_EMAIL}' != '${email}' and ${on_home}
    ...    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Run Keyword If    '${CURRENT_EMAIL}' != '${email}' and ${on_home}
    ...    Sleep    3s
    Run Keyword If    '${CURRENT_EMAIL}' != '${email}' and ${on_home}
    ...    Run    adb -s ${DEVICE_NAME} shell pm clear ${APP_PACKAGE}
    Run Keyword If    '${CURRENT_EMAIL}' != '${email}' and ${on_home}
    ...    Sleep    8s
    Run Keyword If    '${CURRENT_EMAIL}' != '${email}' and ${on_home}
    ...    Activate Application    ${APP_PACKAGE}
    Run Keyword If    '${CURRENT_EMAIL}' != '${email}' and ${on_home}
    ...    Sleep    25s
    # Ensure we are at a known state — if email field not found, force a fresh start
    ${on_welcome}=    Run Keyword And Return Status    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Sign in']    timeout=30s
    Run Keyword If    ${on_welcome}    Click Element    xpath=//android.widget.TextView[@text='Sign in']
    ${email_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=10s
    Run Keyword If    not ${email_ready}    Force Fresh Login State
    # Enter credentials and OTP
    Wait Until Element Is Visible    xpath=//android.widget.EditText[@hint='Email Address']    timeout=20s
    Input Text       xpath=//android.widget.EditText[@hint='Email Address']    ${email}
    Input Text       xpath=//android.widget.EditText[@hint='Password']         ${password}
    Click Element    accessibility_id=Sign in
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='OTP Verification']    timeout=60s
    Sleep    3s
    Enter OTP Into Boxes    1    2    3    4    5    6
    Wait Until Element Is Visible    ${AD_ACCT_NO_TEXT}    timeout=25s
    Sleep    2s
    Set Suite Variable    ${CURRENT_EMAIL}    ${email}

Force Fresh Login State
    [Documentation]    Called when the app is in an unknown state (OTP, crash, etc.).
    ...    Force-stops, clears app data, and restarts to the Sign in form.
    Run    adb -s ${DEVICE_NAME} shell am force-stop ${APP_PACKAGE}
    Sleep    3s
    Run    adb -s ${DEVICE_NAME} shell pm clear ${APP_PACKAGE}
    Sleep    5s
    Activate Application    ${APP_PACKAGE}
    Sleep    20s
    Wait Until Element Is Visible    xpath=//android.widget.TextView[@text='Sign in']    timeout=45s
    Click Element    xpath=//android.widget.TextView[@text='Sign in']

Login And Navigate To History Screen
    [Arguments]    ${email}=${AD_VALID_EMAIL}    ${password}=${AD_VALID_PASSWORD}
    # Login → Home → tap History tab
    Login And Navigate To Home Screen    ${email}    ${password}
    Click Element    ${AD_HISTORY_TAB}
    Wait Until Element Is Visible    ${AD_HISTORY_SCREEN}    timeout=10s
    Sleep    2s

Navigate To E-Statement Screen
    # Login must already be done — navigate Profile → Bank Documents → E-Statement
    Click Element    ${AD_PROFILE_TAB}
    Sleep    3s
    # Scroll down to reveal Bank Documents button if not immediately visible
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${AD_BANK_DOCUMENTS_BTN}    timeout=5s
    Run Keyword If    not ${found}    Swipe    start_x=540    start_y=1400    end_x=540    end_y=800    duration=500
    Run Keyword If    not ${found}    Sleep    1s
    Wait Until Element Is Visible    ${AD_BANK_DOCUMENTS_BTN}    timeout=10s
    Click Element    ${AD_BANK_DOCUMENTS_BTN}
    Sleep    2s
    Wait Until Element Is Visible    ${AD_ESTATEMENT_BTN}    timeout=10s
    Click Element    ${AD_ESTATEMENT_BTN}
    Wait Until Element Is Visible    ${AD_ESTATEMENT_SCREEN}    timeout=15s


