*** Settings ***
Documentation    All the Common objects and keywords
Library          SeleniumLibrary
Library          lib/fantasyAPI/FantasyUtils.py
Library          lib/fantasyUI/FantasyUIutils.py
Library          RPA.JSON

*** Variables ***
${HOMEPAGE_URL}                            https://www.espn.com/
${LEAGUE_CREATE_URL}                       https://fantasy.espn.com/basketball/league/create?ex_cid=FBA2018_RightRailCreate
${PROFILE_LOCATOR}                         global-user-trigger
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
${SAVE_ROSTER}                             xpath://button[text()='Save Roster']
${FINISH_BUTTON}                           xpath://button[text()="I Am Finished Entering Results"]
${RELEASE_ROSTER}                          xpath://span[text()='Release Rosters']
${ESPN_PROFILE}                            xpath://div[@style="left: auto; float: left; right: 0px;"]//a[text()="ESPN Profile"]
${DELETE_ACCOUNT}                          xpath://a[text()='Delete Account']
${CONFIRM_DELETE_ACCOUNT}                  xpath://button[text()='Yes, delete this account']
${DELETE_ACCOUNT_INFO}                     xpath://button[text()='OK']

*** Keywords ***
Launch the Browser and Navigate to Espn site
    ${Browser_path}          get chromedriver path
    create webdriver         Chrome  executable_path=${Browser_path}
    Go To                    ${HOMEPAGE_URL}
    MAXIMIZE BROWSER WINDOW

Delete the account and close browser
    Delete the ESPN Account
    close browser

Launch the site and create a test account and a fantasy league
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
    input password                   ${NEW_PASSWORD_FIELD}     test_api
    sleep     4s
    wait until element is visible    ${SIGNUP_BUTTON}          timeout=10s
    click button                     ${SIGNUP_BUTTON}
    sleep     4s
    set global variable              ${random_email}
    Create a League

Create a League
    go to                            ${LEAGUE_CREATE_URL}
    set selenium implicit wait       10s
    wait until element is visible    ${LEAGUE_NAME_FIELD}     timeout=10s
    input text                       ${LEAGUE_NAME_FIELD}    TestLeague
    click element                    ${NO_OF_TEAMS}
    click button                     ${LEAGUE_CREATE_BUTTON}
    wait until element is visible    ${DISMISS_INVITE}       timeout=10s
    click element                    ${DISMISS_INVITE}
    Begin Draft
    Navigate to LM Tools and start inputing players for the team
    click element                    ${SAVE_ROSTER}
    reload page
    wait until element is visible    ${FINISH_BUTTON}       timeout=10s
    click element                    ${FINISH_BUTTON}
    wait until element is visible    ${RELEASE_ROSTER}      timeout=10s
    click element                    ${RELEASE_ROSTER}
    sleep       2s

Begin Draft
    wait until element is visible    ${SCHEDULE_DRAFT_BUTTON}    timeout=10s
    click element    ${SCHEDULE_DRAFT_BUTTON}
    wait until element is visible    ${OFFLINE_DRAFT_TYPE}       timeout=10s
    click element    ${OFFLINE_DRAFT_TYPE}
    click button     ${SAVE_DRAFT_TYPE}
    sleep       3s

Navigate to LM Tools and start inputing players for the team
    wait until element is visible    ${LM_TOOL_OPTION}                   timeout=10s
    click element    ${LM_TOOL_OPTION}
    wait until element is visible     ${INPUT_OFFLINE_RESULTS_LINK}      timeout=10s
    click element    ${INPUT_OFFLINE_RESULTS_LINK}
    wait until element is visible    ${BEGIN_OFFLINE_DRAFT}              timeout=10s
    click element    ${BEGIN_OFFLINE_DRAFT}
    Add players for team 1

Add players for team 1
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${json}     load json from file           resource/UI/team1_players.json
    FOR    ${no}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${no}
      input text    ${players_elements}[${no}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END

Login into the espn site
    mouse over                       ${PROFILE_LOCATOR}
    click button                     ${LOGIN_BUTTON}
    Select Frame                     ${ONEID_FRAME}
    wait until element is visible    ${EMAIL_FIELD}
    input text                       ${EMAIL_FIELD}        ${random_email}
    wait until element is visible    ${PASSWORD_FIELD}
    input password                   ${PASSWORD_FIELD}     test_api
    click button                     ${LOGIN_BUTTON}

Select any fantasy team from the existing league ${league_name} to move players
     go to                           ${HOMEPAGE_URL}
     wait until element is visible   ${PROFILE_LOCATOR}     timeout=10s
     mouse over                      ${PROFILE_LOCATOR}
     click element                   xpath://span[text()='${league_name}']

Delete the ESPN Account
     go to                           ${HOMEPAGE_URL}
     wait until element is visible   ${PROFILE_LOCATOR}           timeout=10s
     mouse over                      ${PROFILE_LOCATOR}
     wait until element is visible   ${ESPN_PROFILE}              timeout=10s
     click element                    ${ESPN_PROFILE}
     select frame                    ${ONEID_FRAME}
     wait until element is visible   ${DELETE_ACCOUNT}            timeout=10s
     click element                   ${DELETE_ACCOUNT}
     wait until element is visible   ${CONFIRM_DELETE_ACCOUNT}    timeout=10s
     click element                   ${CONFIRM_DELETE_ACCOUNT}
     wait until element is visible   ${DELETE_ACCOUNT_INFO}       timeout=10s
     click element                   ${DELETE_ACCOUNT_INFO}