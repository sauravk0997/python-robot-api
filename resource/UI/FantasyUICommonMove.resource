*** Settings ***
Documentation    All the Common objects and keywords
Library          SeleniumLibrary
Library          lib/fantasyAPI/FantasyUtils.py
Library          lib/fantasyUI/FantasyUIutils.py
Library          RPA.JSON

*** Variables ***
${HOMEPAGE_URL}                            https://www.espn.com/
${LEAGUE_CREATE_URL}                       https://fantasy.espn.com/basketball/league/create?ex_cid=FBA2018_RightRailCreate
${PROFILE_LOCATOR}                         id:global-user-trigger
${LOGIN_BUTTON}                            xpath://button[text()='Log In']
${ONEID_FRAME}                             id:oneid-iframe
${EMAIL_FIELD}                             id:InputLoginValue
${PASSWORD_FIELD}                          id:InputPassword
${FIRST_NAME_FIELD}                        id:InputFirstName
${LAST_NAME_FIELD}                         id:InputLastName
${NEW_EMAIL_FIELD}                         id:InputEmail
${NEW_PASSWORD_FIELD}                      id:password-new
${SIGNUP_BUTTON}                           xpath://button[text()='Sign Up']
${LEAGUE_NAME_FIELD}                       xpath://input[@class='form__control LeagueNameInput']
${NO_OF_TEAMS}                             xpath://div[text()=4]//parent::div
${LEAGUE_CREATE_BUTTON}                    xpath://button[text()='Create League']
${DISMISS_INVITE}                          xpath://div[@class='lightbox__closebtn__wrap flex items-center justify-center']
${SCHEDULE_DRAFT_BUTTON}                   xpath://a[text()="Schedule Your Draft"]
${OFFLINE_DRAFT_TYPE}                      xpath://label[text()="Offline"]
${SAVE_DRAFT_TYPE}                         xpath://button[text()='Save Changes']
${LM_TOOL_OPTION}                          xpath://span[text()='LM Tools']//ancestor::a
${INPUT_OFFLINE_RESULTS_LINK}              xpath://a[text()='Input Offline Draft Results']
${BEGIN_OFFLINE_DRAFT}                     xpath://button[text()='Begin Offline Draft']
${PLAYER_NAMES}                            xpath://input[@placeholder='Player Name']
${SAVE_ROSTER}                             xpath://button[@class='Button Button--default rosterButton']
${FINISH_ROSTER_BUTTON}                    xpath://button[text()="I Am Finished Entering Results"]
${RELEASE_ROSTER}                          xpath://span[text()='Release Rosters']
${ESPN_PROFILE}                            xpath://div[@style="left: auto; float: left; right: 0px;"]//a[text()="ESPN Profile"]
${DELETE_ACCOUNT}                          xpath://a[text()='Delete Account']
${CONFIRM_DELETE_ACCOUNT}                  xpath://button[text()='Yes, delete this account']
${DELETE_ACCOUNT_INFO}                     xpath://button[text()='OK']
${INVITE_MANAGERS}                         xpath://a[text()='Invite Managers']
${INVITE_LINK_TEXT}                        xpath://input[@id='invite_link_input_text']
${LOGOUT_BUTTON}                           xpath://span[text()='Log Out']//parent::button
${JOIN_LEAGUE_BUTTON}                      xpath://button[text()='Join This League']
${USER_EMAIL_FIELD}                        xpath://input[@type='email']
${USER_PASSWORD_FIELD}                     xpath://input[@type='password']
${PROFILE_ICON_AFTER_LOGIN}                xpath://li[contains(@class, 'authed')]
${TEAM_LOCATION}                           xpath://input[@id='input_teamLocation']
${TEAM_NICKNAME}                           xpath://input[@id='input_teamNickName']
${TEAM_ABBREVIATION}                       xpath://input[@id='input_teamAbbrev']
${FINISH_BUTTON}                           xpath://button[text()='Finish']
${ROSTER_MOVES}                            xpath://a[text()='Roster Moves']
${DELETE_LEAGUE_LINK}                      xpath://a[text()='Delete League']
${DELETE_LEAGUE_BUTTON}                    xpath://button[text()='Delete League']
${CONFIRM_DELETE_LEAGUE_BUTTON}            xpath://span[text()='Confirm']//parent::button
@{USER_EMAILS}                             test_ui_user1@test.com        test_ui_user2@test.com      test_ui_user3@test.com

*** Keywords ***
Launch the Browser and Navigate to Espn site
    ${Browser_path}          get chromedriver path
    create webdriver         Chrome  executable_path=${Browser_path}
    Go To                    ${HOMEPAGE_URL}
    MAXIMIZE BROWSER WINDOW

Create test account and a fantasy League
    create a test account
    Create a Fantasy League
    Send invitations, Accept Invitation send by the inviter and create teams
    Login to the site using the created test account
    Begin Draft
    Navigate to LM Tools
    select input offline results and start inputing players for the teams

Delete the league, test account and close browser
    Delete the fantasy League
    Delete the ESPN Account
    close browser

create a test account
    Launch the Browser and Navigate to Espn site
    mouse over                       ${PROFILE_LOCATOR}
    click button                     ${LOGIN_BUTTON}
    Select Frame                     ${ONEID_FRAME}
    click button                     ${SIGNUP_BUTTON}
    wait until element is visible    ${FIRST_NAME_FIELD}
    input text                       ${FIRST_NAME_FIELD}       Test
    input text                       ${LAST_NAME_FIELD}        Ui
    ${random_email}                  generate a random email
    input text                       ${NEW_EMAIL_FIELD}        ${random_email}
    input password                   ${NEW_PASSWORD_FIELD}     test_ui
    sleep     4s
    wait until element is visible    ${SIGNUP_BUTTON}          timeout=10s
    click button                     ${SIGNUP_BUTTON}
    sleep     8s
    set global variable              ${random_email}

Create a Fantasy League
    go to                            ${LEAGUE_CREATE_URL}
    set selenium implicit wait       10s
    wait until element is visible    ${LEAGUE_NAME_FIELD}     timeout=10s
    input text                       ${LEAGUE_NAME_FIELD}     TestLeague
    click element                    ${NO_OF_TEAMS}
    click button                     ${LEAGUE_CREATE_BUTTON}
    wait until element is visible    ${DISMISS_INVITE}        timeout=10s
    click element                    ${DISMISS_INVITE}
    wait until element is visible    ${INVITE_MANAGERS}       timeout=10s
    click element                    ${INVITE_MANAGERS}
    sleep  3s
    ${invite_link}=    Get Element Attribute    ${INVITE_LINK_TEXT}    value
    Log    "Invite Link ::::"${invite_link}
    Set Global Variable    ${invite_link}
    mouse over             ${PROFILE_ICON_AFTER_LOGIN}
    wait until element is visible    ${LOGOUT_BUTTON}
    click button           ${LOGOUT_BUTTON}
    sleep    2s

Send invitations, Accept Invitation send by the inviter and create teams
    FOR    ${index}    IN RANGE    0    3
        Execute Javascript   window.open('${invite_link}')
        ${handles}=  Get Window Handles
        Switch Window    ${handles}[0]
        close window
        Switch Window   ${handles}[1]
        wait until element is visible    ${JOIN_LEAGUE_BUTTON}
        sleep     2
        Click Button    ${JOIN_LEAGUE_BUTTON}
        Login into the espn site    ${USER_EMAILS}[${index}]
        Wait Until Element Is Visible    ${TEAM_LOCATION}
        Input Text    ${TEAM_LOCATION}    FL${index}
        Input Text    ${TEAM_NICKNAME}   FN${index}
        Input Text    ${TEAM_ABBREVIATION}    FB${index}
        Click Button    ${FINISH_BUTTON}
        mouse over             ${PROFILE_ICON_AFTER_LOGIN}
        wait until element is visible    ${LOGOUT_BUTTON}
        click button           ${LOGOUT_BUTTON}
        sleep    2s
    END

Login to the site using the created test account
    Login into the espn site from Homepage        ${random_email}
    sleep    3s
    wait until element is visible   ${PROFILE_LOCATOR}     timeout=10s
    mouse over                      ${PROFILE_LOCATOR}
    click element                   xpath://span[text()='TestLeague']

Begin Draft
    wait until element is visible    ${SCHEDULE_DRAFT_BUTTON}    timeout=10s
    click element    ${SCHEDULE_DRAFT_BUTTON}
    wait until element is visible    ${OFFLINE_DRAFT_TYPE}       timeout=10s
    click element    ${OFFLINE_DRAFT_TYPE}
    sleep       2s
    click button     ${SAVE_DRAFT_TYPE}
    sleep       3s

Navigate to LM Tools
    wait until element is visible    ${LM_TOOL_OPTION}                   timeout=10s
    click element    ${LM_TOOL_OPTION}

select input offline results and start inputing players for the teams
    wait until element is visible     ${INPUT_OFFLINE_RESULTS_LINK}      timeout=10s
    click element    ${INPUT_OFFLINE_RESULTS_LINK}
    wait until element is visible    ${BEGIN_OFFLINE_DRAFT}              timeout=10s
    click element    ${BEGIN_OFFLINE_DRAFT}
    Add players for first team
    Add players for second team
    Add players for third team
    Add players for fourth team
    sleep    2s
    scroll element into view    ${FINISH_ROSTER_BUTTON}
    click button                ${FINISH_ROSTER_BUTTON}
    sleep    2s
    click element                ${RELEASE_ROSTER}


Add players for first team
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${json}     load json from file           resource/UI/team1_players.json
    FOR    ${no}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${no}
      input text    ${players_elements}[${no}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END
    sleep    3s
    scroll element into view         ${SAVE_ROSTER}
    click element                    ${SAVE_ROSTER}

Add players for second team
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${json}     load json from file           resource/UI/team2_players.json
    FOR    ${no}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${no}
      input text    ${players_elements}[${no}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END
    sleep    3s
    scroll element into view         ${SAVE_ROSTER}
    click element                    ${SAVE_ROSTER}

Add players for third team
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${json}     load json from file           resource/UI/team3_players.json
    FOR    ${no}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${no}
      input text    ${players_elements}[${no}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END
    sleep    3s
    scroll element into view         ${SAVE_ROSTER}
    click element                    ${SAVE_ROSTER}

Add players for fourth team
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${json}     load json from file           resource/UI/team4_players.json
    FOR    ${no}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${no}
      input text    ${players_elements}[${no}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END
    sleep    3s
    scroll element into view         ${SAVE_ROSTER}
    click element                    ${SAVE_ROSTER}

Login into the espn site from Homepage
    [Arguments]            ${email}
    go to                            ${HOMEPAGE_URL}
    sleep    4s
    mouse over                       ${PROFILE_LOCATOR}
    click button                     ${LOGIN_BUTTON}
    Select Frame                     ${ONEID_FRAME}
    wait until element is visible    ${EMAIL_FIELD}
    input text                       ${EMAIL_FIELD}        ${email}
    wait until element is visible    ${PASSWORD_FIELD}
    input password                   ${PASSWORD_FIELD}     test_ui
    click button                     ${LOGIN_BUTTON}
    Unselect Frame

Login into the espn site
    [Arguments]            ${email}
    Select Frame                     id:disneyid-iframe
    wait until element is visible    ${USER_EMAIL_FIELD}
    input text                       ${USER_EMAIL_FIELD}        ${email}
    wait until element is visible    ${USER_PASSWORD_FIELD}
    input password                   ${USER_PASSWORD_FIELD}     test_ui
    click button                     ${LOGIN_BUTTON}
    Unselect Frame

Select any fantasy league ${league_name} to move players
     go to                           ${HOMEPAGE_URL}
     wait until element is visible   ${PROFILE_LOCATOR}     timeout=10s
     mouse over                      ${PROFILE_LOCATOR}
     click element                   xpath://span[text()='${league_name}']

select edit rosters from LM Tools page
      wait until element is visible    ${ROSTER_MOVES}                     timeout=10s
      click element    ${ROSTER_MOVES}
      sleep    2s

Delete the fantasy League
    go to                           ${HOMEPAGE_URL}
    Select any fantasy league TestLeague to move players
    Navigate to LM Tools
    click element     ${DELETE_LEAGUE_LINK}
    wait until element is visible    ${DELETE_LEAGUE_BUTTON}               timeout=10s
    click button      ${DELETE_LEAGUE_BUTTON}
    wait until element is visible    ${CONFIRM_DELETE_LEAGUE_BUTTON}       timeout=10s
    click button      ${CONFIRM_DELETE_LEAGUE_BUTTON}

Delete the ESPN Account
     go to                           ${HOMEPAGE_URL}
     wait until element is visible   ${PROFILE_LOCATOR}           timeout=10s
     mouse over                      ${PROFILE_LOCATOR}
     wait until element is visible   ${ESPN_PROFILE}              timeout=10s
     click element                   ${ESPN_PROFILE}
     select frame                    ${ONEID_FRAME}
     wait until element is visible   ${DELETE_ACCOUNT}            timeout=10s
     click element                   ${DELETE_ACCOUNT}
     wait until element is visible   ${CONFIRM_DELETE_ACCOUNT}    timeout=10s
     click element                   ${CONFIRM_DELETE_ACCOUNT}
     wait until element is visible   ${DELETE_ACCOUNT_INFO}       timeout=10s
     click element                   ${DELETE_ACCOUNT_INFO}