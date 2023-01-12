*** Settings ***
Library             RPA.JSON
Library             SeleniumLibrary    timeout=10s    implicit_wait=10s
Library             lib/fantasyUI/FantasyUIutils.py
Library             lib/fantasyAPI/FantasyUtils.py
Library             String
Resource            resource/UI/Pages/CreateLeaguePage.resource

*** Variables ***
${FANTASY_URL}                        https://fantasy.espn.com/
${user}                               test_user_account3@test.com
${encrypted_password}                 U3MzVF9HKnhmLy0/UlRpOHUyOHUyOGVyanNqY2pjYjkydTkyOTIx
${ENCRYPTED_PASSWORD1}                VUl1c2VyQEVTUE4=
@{user_emails}                        ui_test_user1@test.com    ui_test_user2@test.com    ui_test_user3@test.com
${ROSTER_MOVES_DROPDOWN1}             (//select[@class="dropdown__select"])[1]
${LM_TOOLS_CONTINUE_BUTTON}           //button[normalize-space()='Continue']
${SIGNUP_BUTTON}                           xpath://button[text()='Sign Up']
${ROSTER_MOVES_DROPDOWN2}             (//select[@class="dropdown__select"])[2]
${ROSTER_MOVES_OPTION}                //a[normalize-space()='Roster Moves']
${LM_TOOLS_OPTION}                    //span[contains(text(),'LM Tools')]
${RESET_DRAFT_OPTION}                 (//a[contains(text(),'Reset Draft')])
${RESET_DRAFT_BUTTON1}                //button[normalize-space()='Reset Draft']
${RESET_DRAFT_BUTTON2}                (//button[@aria-label='Reset Draft'])
${CONTINUE_LEAGUE_OFFICE_BUTTON}      //a[normalize-space()='Continue to League Office']
${PROFILE_LOGIN_BUTTON}               xpath://button[text()='Log In']
${FIRST_NAME_FIELD}                        id:InputFirstName
${LAST_NAME_FIELD}                         id:InputLastName
${NEW_EMAIL_FIELD}                         id:InputEmail
${NEW_PASSWORD_FIELD}                      id:password-new
${LEAGUE_CREATE_URL}                       https://fantasy.espn.com/basketball/league/create?ex_cid=FBA2018_RightRailCreate
${LEAGUE_NAME_FIELD}                       xpath://input[@class='form__control LeagueNameInput']
${NO_OF_TEAMS}                             xpath://div[text()=4]//parent::div
${LEAGUE_CREATE_BUTTON}                    xpath://button[text()='Create League']
${DISMISS_INVITE}                          css:button[aria-label='Close dialog'] div
${SCHEDULE_DRAFT_BUTTON}                   xpath://a[text()="Schedule Your Draft"]
${OFFLINE_DRAFT_TYPE}                      xpath://label[text()="Offline"]
${SAVE_DRAFT_TYPE}                         xpath://button[text()='Save Changes']
${SAVE_ROSTER_TEAM1}                       xpath://button[text()='Save Roster'and @data-team-id='1']
${SAVE_ROSTER_TEAM2}                       xpath://button[text()='Save Roster'and @data-team-id='2']
${RELEASE_ROSTER_BUTTON}                   xpath://span[text()='Release Rosters']
${INPUT_OFFLINE_RESULTS_LINK}              xpath://a[text()='Input Offline Draft Results']
${BEGIN_OFFLINE_DRAFT}                     xpath://button[text()='Begin Offline Draft']
${PLAYER_NAMES}                            xpath://input[@placeholder='Player Name']
${FINISH_ENTERING_BUTTON}                  //button[text()='I Am Finished Entering Results']

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

Select my fantasy team
    wait until element is visible   //span[text()='My Team']
    click element      //span[text()='My Team']

Click on roster moves
    wait until element is visible    ${ROSTER_MOVES_OPTION}
    Execute JavaScript    window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Click element    ${ROSTER_MOVES_OPTION}
    Sleep    5s

Close the current Browser
    close browser

Create a League to drop players
    Sleep    4s
    go to                            ${LEAGUE_CREATE_URL}
    wait until element is visible    ${LEAGUE_NAME_FIELD}    timeout=10s
    click element                    ${NO_OF_TEAMS}
    input text                       ${LEAGUE_NAME_FIELD}    TestLeague
    click button                     ${LEAGUE_CREATE_BUTTON}
    wait until element is visible    ${DISMISS_INVITE}       timeout=10s
    click element                    ${DISMISS_INVITE}
    Begin Draft and start inputing players for the team 
    Scroll Element Into View         ${FINISH_ENTERING_BUTTON}
    wait until element is visible    ${FINISH_ENTERING_BUTTON}
    click element                    ${FINISH_ENTERING_BUTTON}
    Sleep    2s
    wait until element is visible    ${RELEASE_ROSTER_BUTTON}    timeout=10s
    click element                    ${RELEASE_ROSTER_BUTTON}

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

Re-login to the fantasy application as a ${team_no} user
    Select Frame      ${DISNEY_ID_IFRAME}
    ${int_value}=    Convert To Integer    ${team_no}
    ${user_email_index}=    Evaluate    ${int_value}-2
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${user_emails}[${user_email_index}]
    ${decrypted_password}=     Get decrypted password ${ENCRYPTED_PASSWORD1}
    wait until element is visible    ${password_field}
    input password    ${password_field}    ${decrypted_password}
    click button      ${login_button}
    Unselect Frame

Logout from Fantasy Application
    Reload Page
    Wait Until Element Is Enabled    ${FANTASY_PROFILE_ICON}
    Scroll Element Into View    ${FANTASY_PROFILE_ICON}
    Wait Until Element Is Visible    ${LOGOUT_LINK}
    Click Element    ${LOGOUT_LINK}

log in to the site
    [Arguments]    ${username}
    Logout from Fantasy Application 
    Mouse Over    ${FANTASY_PROFILE_ICON}
    Wait Until Element Is Visible    ${FANTASY_LOGIN_LINK}
    Click Element    ${FANTASY_LOGIN_LINK}
    Select Frame      ${DISNEY_ID_IFRAME} 
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${username}
    wait until element is visible    ${password_field}
    ${decrypted_password}=     Get decrypted password ${ENCRYPTED_PASSWORD1}
    input password    ${password_field}    ${decrypted_password}
    click button      ${login_button}
    Unselect Frame

Login into the espn site with user credentials ${username} and ${password}
    ${decrypted_password}=     Get decrypted password ${password}
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

Begin Draft and start inputing players for the team
    wait until element is visible    ${SCHEDULE_DRAFT_BUTTON}
    click element    ${SCHEDULE_DRAFT_BUTTON}
    wait until element is visible    ${OFFLINE_DRAFT_TYPE}
    click element    ${OFFLINE_DRAFT_TYPE}
    click button     ${SAVE_DRAFT_TYPE}
    sleep       3s
    Click on LM tools
    wait until element is visible     ${INPUT_OFFLINE_RESULTS_LINK}
    click element    ${INPUT_OFFLINE_RESULTS_LINK}
    wait until element is visible    ${BEGIN_OFFLINE_DRAFT}
    click element    ${BEGIN_OFFLINE_DRAFT}
    Add players for team 1 to drop
    click element                    ${SAVE_ROSTER_TEAM1}
    Sleep    3s
    Add players for team 2 to drop
    click element                    ${SAVE_ROSTER_TEAM2}
    Sleep    3s

Launch the site and create a test account and a fantasy league
    Launch the Browser and Navigate to the ${FANTASY_URL} site
    mouse over                       ${profile_icon}
    click button                     ${PROFILE_LOGIN_BUTTON}
    Select Frame                     ${ONEID_FRAME}
    click button                     ${SIGNUP_BUTTON}
    wait until element is visible    ${FIRST_NAME_FIELD}
    input text                       ${FIRST_NAME_FIELD}       Test
    input text                       ${LAST_NAME_FIELD}        Ui
    ${random_email}                  generate a random email
    input text                       ${NEW_EMAIL_FIELD}        ${random_email}
    ${random_password}               generate a random password
    input password                   ${NEW_PASSWORD_FIELD}     ${random_password}
    sleep     4s
    wait until element is visible    ${SIGNUP_BUTTON}
    click button                     ${SIGNUP_BUTTON}
    sleep     4s
    set global variable              ${random_email}
    Create a League to drop players
    Reload Page
    Sleep    2s

Add players for ${team} to drop
    wait until element is visible             ${PLAYER_NAMES}
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    Convert To String    ${team}
    IF    '${team}' == 'team 1'
        ${json}     load json from file           resource/UI/team1_players.json
    ELSE
        ${json}     load json from file           resource/UI/team2_players.json
    END 
    FOR    ${index}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${index}
      input text    ${players_elements}[${index}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END
  