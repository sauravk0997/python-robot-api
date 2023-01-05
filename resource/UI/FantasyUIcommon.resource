*** Settings ***
Library             RPA.JSON
Library             SeleniumLibrary
Library             lib/fantasyUI/FantasyUIutils.py
Library             lib/fantasyAPI/FantasyUtils.py
Library             String
Resource            resource/UI/Pages/CreateLeaguePage.resource

*** Variables ***
${FANTASY_URL}                        https://fantasy.espn.com/
${user}                               test_user_account2@test.com
${encrypted_password}                 U3MzVF9HKnhmLy0/UlRpOHUyOHUyOGVyanNqY2pjYjkydTkyOTIx
@{user_emails}                        test_api_user1@test.com    test_api_user2@test.com    test_api_user3@test.com
${ROSTER_MOVES_DROPDOWN1}             (//select[@class="dropdown__select"])[1]
${LM_TOOLS_CONTINUE_BUTTON}           //button[normalize-space()='Continue']
${ROSTER_MOVES_DROPDOWN2}             (//select[@class="dropdown__select"])[2]
${ROSTER_MOVES_OPTION}                //a[normalize-space()='Roster Moves']
${LM_TOOLS_OPTION}                    //span[contains(text(),'LM Tools')]
${RESET_DRAFT_OPTION}                 (//a[contains(text(),'Reset Draft')])
${RESET_DRAFT_BUTTON1}                //button[normalize-space()='Reset Draft']
${RESET_DRAFT_BUTTON2}                (//button[@aria-label='Reset Draft'])
${CONTINUE_LEAGUE_OFFICE_BUTTON}      //a[normalize-space()='Continue to League Office']
${PROFILE_LOGIN_BUTTON}               xpath://button[text()='Log In']

*** Keywords ***
Initialize Variables
    ${xpath_json}=        Load JSON from file    resource/UI/xpaths.json
    ${profile_icon}=      Get value from JSON    ${xpath_json}    $.login.XPATH_USER_PROFILE_ICON
    ${login_link}=        Get value from JSON    ${xpath_json}    $.login.XPATH_USER_LOGIN_LINK
    ${oneid_wrapper}=     Get value from JSON    ${xpath_json}    $.login.XPATH_USER_LOGIN_MODAL_WRAPPER
    ${oneid_frame}=       Get value from JSON    ${xpath_json}    $.login.XPATH_USER_LOGIN_MODAL_IFRAME
    ${username_field}=    Get value from JSON    ${xpath_json}    $.login.XPATH_USER_LOGIN_MODAL_IFRAME_USERNAME_FIELD
    ${password_field}=    Get value from JSON    ${xpath_json}    $.login.XPATH_USER_LOGIN_MODAL_IFRAME_PASSWORD_FIELD
    ${login_button}=      Get value from JSON    ${xpath_json}    $.login.XPATH_USER_LOGIN_MODAL_IFRAME_LOGIN_BUTTON
    ${profile_name}=      Get value from JSON    ${xpath_json}    $.login.XPATH_USER_PROFILE_NAME
    Set Global Variable    ${profile_icon}
    Set Global Variable    ${login_link}
    Set Global Variable    ${oneid_wrapper}
    Set Global Variable    ${oneid_frame}
    Set Global Variable    ${username_field}
    Set Global Variable    ${password_field}
    Set Global Variable    ${login_button}
    Set Global Variable    ${profile_name}

Launch the Browser and Navigate to the ${url} site
    Initialize Variables
    ${chrome_driver_path}    Get Chromedriver Path
    create webdriver         Chrome    executable_path=${chrome_driver_path}
    Go To                    ${url}
    Maximize Browser Window

Select my fantasy ${MY_LEAGUE}
    wait until element is visible   ${profile_icon}
    mouse over        ${profile_icon}
    wait until element is visible   xpath:(//span[contains(text(),'${MY_LEAGUE}')])[1]
    click element      xpath:(//span[contains(text(),'${MY_LEAGUE}')])[1]

Click on roster moves
    wait until element is visible    ${ROSTER_MOVES_OPTION}
    Execute JavaScript    window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Click element    ${ROSTER_MOVES_OPTION}
    Sleep    5s

Close the current Browser
    close browser

Log in to the Fantasy Application
    Mouse Over    ${FANTASY_PROFILE_ICON}
    Wait Until Element Is Visible    ${FANTASY_LOGIN_LINK}
    Click Element    ${FANTASY_LOGIN_LINK}
    Select Frame      ${DISNEY_ID_IFRAME}
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${user}
    ${decrypted_password}=     Get decrypted password ${encrypted_password}
    wait until element is visible    ${password_field}
    input password    ${password_field}    ${decrypted_password}
    click button      ${login_button}
    Unselect Frame

Re-login to the fantasy application as a root user
    Select Frame      ${DISNEY_ID_IFRAME}
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${user}
    ${decrypted_password}=     Get decrypted password ${encrypted_password}
    wait until element is visible    ${password_field}
    input password    ${password_field}    ${decrypted_password}
    click button      ${login_button}
    Unselect Frame

Logout from Fantasy Application
    Mouse Over    css:[role='button']
    Wait Until Element Is Visible    ${LOGOUT_LINK}
    Click Element    ${LOGOUT_LINK}

log in to the site
    [Arguments]    ${username}
    Logout from Fantasy Application 
    Mouse Over    ${FANTASY_PROFILE_ICON}
    Sleep    1
    Wait Until Element Is Visible    ${FANTASY_LOGIN_LINK}
    Click Element    ${FANTASY_LOGIN_LINK}
    Select Frame      ${DISNEY_ID_IFRAME} 
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${username}
    wait until element is visible    ${password_field}
    input password    ${password_field}    APIuser@ESPN
    click button      ${login_button}
    Unselect Frame

Login into the espn site with user credentials ${username} and ${encrypted_password}
    ${decrypted_password}=     Get decrypted password ${encrypted_password}
    mouse over        ${profile_icon}
    click button      ${PROFILE_LOGIN_BUTTON}
    Select Frame      ${oneid_frame}
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${username}
    wait until element is visible    ${password_field}
    input password    ${password_field}    ${decrypted_password}
    click button      ${login_button}
Click on LM tools
    Wait Until Element Is Visible    ${LM_TOOLS_OPTION}
    click element       ${LM_TOOLS_OPTION}
    Sleep    5s

Select options from dropdown
    wait until element is visible    ${ROSTER_MOVES_DROPDOWN1}
    Select From List By Value       ${ROSTER_MOVES_DROPDOWN1}        dropPlayers
    wait until element is visible    ${ROSTER_MOVES_DROPDOWN2}
    Select From List By Value       ${ROSTER_MOVES_DROPDOWN2}        2
    Wait Until Element Is Visible    ${LM_TOOLS_CONTINUE_BUTTON}
    click element       ${LM_TOOLS_CONTINUE_BUTTON}
    Sleep    3s

Reset draft
    Click on LM tools
    wait until element is visible    ${RESET_DRAFT_OPTION}
    click element    ${RESET_DRAFT_OPTION}
    wait until element is visible    ${RESET_DRAFT_BUTTON1}
    click element    ${RESET_DRAFT_BUTTON1}
    wait until element is visible    ${RESET_DRAFT_BUTTON2}
    Sleep    5s
    click element    ${RESET_DRAFT_BUTTON2}
    Sleep    5s
    click element    ${CONTINUE_LEAGUE_OFFICE_BUTTON}
    Logout from Fantasy Application
    Log To Console    ***** User logged out *****
    FantasyUIcommon.Close the current Browser
    Log To Console    ***** All browsers closed *****

Scroll up 
    execute javascript             window.scrollTo(document.body.scrollHeight, 100)
