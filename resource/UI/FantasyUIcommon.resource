*** Settings ***
Library             RPA.JSON
Library             SeleniumLibrary
Library             lib/fantasyUI/FantasyUIutils.py
Library             lib/fantasyAPI/FantasyUtils.py

*** Variables ***
${ESPN_URL}        https://www.espn.com/
# ${FANTASY_URL}     https://fantasy.espn.com/
# ${BASKETBALL_CREATE_LEAGUE_SLUG}    basketball/welcome?addata=fantasy_dropdown_fba2-22
${user}                    test_user_account@test.com
${encrypted_password}      U3MzVF9HKnhmLy0/UlRpOHUyOHUyOGVyanNqY2pjYjkydTkyOTIx

*** Keywords ***
Initialize Variables
    ${xpath_json}=        Load JSON from file    resource/UI/xpaths.json
    ${profile_icon}=      Get value from JSON    ${xpath_json}    $.login.XPATH_USER_PROFILE_ICON
    #${profile_icon}=      Get value from JSON    ${xpath_json}    $.login.XPATH_USER_PROFILE_ICON
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
    Mouse Over    css:[role='button']
    Wait Until Element Is Visible    xpath://li//span[text()='Log In']
    Click Element    xpath://li//span[text()='Log In']
    Select Frame      id:disneyid-iframe
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${user}
    ${decrypted_password}=     Get decrypted password ${encrypted_password}
    wait until element is visible    ${password_field}
    input password    ${password_field}    ${decrypted_password}
    click button      ${login_button}
    Unselect Frame

Create a league
    Wait Until Element Is Visible    xpath://button[text()='Create a League']
    Click Button    xpath://button[text()='Create a League']
    Input Text    css:.form__control.LeagueNameInput    abc