*** Settings ***
Library             RPA.JSON
Library             SeleniumLibrary
Library             lib/fantasyUI/FantasyUIutils.py
Library             lib/fantasyAPI/FantasyUtils.py
Library             String
Resource            resource/UI/Pages/CreateLeaguePage.resource

*** Variables ***
${user}                    test_user_account2@test.com
${encrypted_password}      U3MzVF9HKnhmLy0/UlRpOHUyOHUyOGVyanNqY2pjYjkydTkyOTIx
@{user_emails}        test_api_user1@test.com    test_api_user2@test.com    test_api_user3@test.com

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

Create a league
    Sleep    5
    Wait Until Element Is Enabled    ${CREATE_A_LEAGUE_BUTTON}  timeout=10s
    Click Button    ${CREATE_A_LEAGUE_BUTTON}
    ${random_string}=    Generate Random String    4    0123456789
    ${league_name}=   Convert To String     My-Fantasy-League-${random_string}
    Set Global Variable    ${league_name}
    Wait Until Element Is Visible    ${LEAGUE_NAME_INPUT_FIELD}   timeout=10s
    Input Text    ${LEAGUE_NAME_INPUT_FIELD}     ${league_name}
    Click Element    ${LEAGUE_SIZE_4}
    Click Element    ${SCORING_H2H_POINTS}
    Click Element    ${CREATE_LEAGUE_BUTTON}
    Wait Until Element Is Visible     ${CLOSE_ICON}
    Click Element    ${CLOSE_ICON}
    Wait Until Element Is Visible    ${INVITE_MANAGERS}
    Click Element    ${INVITE_MANAGERS}
    sleep  3
    ${invite_link}=    Get Element Attribute    ${INVITE_LINK_TEXT}    value
    Log    "Invite Link ::::"${invite_link}
    Set Global Variable    ${invite_link}

Send invitations, Accept Invitation send by the inviter and create teams
    FOR    ${index}    IN RANGE    0    3
        Execute Javascript   window.open('${invite_link}')
        ${handles}=  Get Window Handles
        Switch Window   ${handles}[1]
        log in to the site    ${user_emails}[${index}]
        Wait Until Element Is Enabled    ${JOIN_THIS_LEAGUE_BUTTON}
        sleep     2
        Click Button    ${JOIN_THIS_LEAGUE_BUTTON}
        Wait Until Element Is Visible    ${TEAM_LOCATION}
        Input Text    ${TEAM_LOCATION}    FL${index}
        Input Text    ${TEAM_NICKNAME}   FN${index}
        Input Text    ${TEAM_ABBREVIATION}    FB${index}
        Click Element    ${FINISH_BUTTON}
        Close Window
        Switch Window    ${handles}[0]
    END

Delete the league
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    ${DISNEY_ID_IFRAME}
    Run Keyword If    ${present}    
    ...    Re-login to the fantasy application as a root user
    ...  ELSE    Run Keywords
    ...    Logout from Fantasy Application
    ...    Re-login to the fantasy application as a root user
    Sleep    3
    Wait Until Element Is Visible    ${MY_TEAMS_ICON}
    Mouse Over       ${MY_TEAMS_ICON}
    click element    xpath://span[text()='${league_name}']
    Wait Until Element Is Visible     ${LM_TOOLS}
    Click Element   ${LM_TOOLS}
    Wait Until Element Is Visible    ${DELETE_LEAGUE_TEXT}
    click element    ${DELETE_LEAGUE_TEXT}
    Wait Until Element Is Visible    ${DELETE_LEAGUE_BUTTON}
    Click Button    ${DELETE_LEAGUE_BUTTON}
    Wait Until Element Is Visible    ${CONFIRM_TEXT}
    Click Element   ${CONFIRM_TEXT}
    Wait Until Element Is Visible    ${SUCCESS_HEADING}
    ${success_text}=    Get Text    ${SUCCESS_HEADING}
    Should Be Equal As Strings    ${success_text}    Success!    msg=The expected and actual strings are not Equal
