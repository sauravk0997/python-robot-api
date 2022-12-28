*** Settings ***
Documentation    All the Common objects and keywords
Library          SeleniumLibrary
Library          lib/fantasyUI/FantasyUICustomKeywords.py
Library          lib/fantasyAPI/FantasyUtils.py
Library          RPA.JSON

*** Variables ***
${HOMEPAGE_URL}                            https://www.espn.com/
${profile_Locator}                         global-user-trigger
${login_button}                            xpath://button[text()='Log In']
${oneid_frame}                             id:oneid-iframe
${Email_field}                             id:InputLoginValue
${Password_field}                          id:InputPassword
${signup_link}                             //a[text()='Sign Up']
${first_name_field}                        id:InputFirstName
${last_name_field}                         id:InputLastName
${new_email_field}                         id:InputEmail
${new_password_field}                      id:password-new
${signup_button}                           xpath://button[text()='Sign Up']
${league_create_url}                       https://fantasy.espn.com/basketball/league/create?ex_cid=FBA2018_RightRailCreate
${league_name_field}                       xpath://input[@class='form__control LeagueNameInput']
${no_of_teams}                             xpath://div[text()=4]//parent::div
${scoring_option}                          xpath://div[text()='H2H Points']
${league_create_button}                    xpath://button[text()='Create League']
${dismiss_invite}                          xpath://div[@class='lightbox__closebtn__wrap flex items-center justify-center']
${schedule_draft_button}                   xpath://a[text()="Schedule Your Draft"]
${offline_draft_type}                      xpath://label[text()="Offline"]
${save_draft_type}                         xpath://button[text()='Save Changes']
${lm_tool_option}                          xpath://span[text()='LM Tools']//ancestor::a
${input_offline_results_link}              xpath://a[text()='Input Offline Draft Results']
${begin_offline_draft}                     xpath://button[text()='Begin Offline Draft']
${player_names}                            xpath://input[@placeholder='Player Name']
${save_roster}                             xpath://button[text()='Save Roster']
${finish_button}                           xpath://button[text()="I Am Finished Entering Results"]
${release_roster}                          xpath://span[text()='Release Rosters']
${league_roster}                           xpath://a[text()='Take me to League Rosters']
${test_button}                             xpath://button[@class='player--search--match selected']
${espn_profile}                            xpath://div[@style="left: auto; float: left; right: 0px;"]//a[text()="ESPN Profile"]
${delete_account}                          xpath://a[text()='Delete Account']
${confirm_delete_account}                  xpath://button[text()='Yes, delete this account']
${delete_account_info}                     xpath://button[text()='OK']

*** Keywords ***
Launch the Browser and Navigate to Espn site
    ${Browser_path}          Get the Browser Path
    create webdriver         Chrome  executable_path=${Browser_path}
    Go To                    ${HOMEPAGE_URL}
    MAXIMIZE BROWSER WINDOW

Delete the account and close browser
    Delete the ESPN Account
    close browser

Launch the site and create a test account and a fantasy league
    Launch the Browser and Navigate to Espn site
    mouse over                       ${profile_Locator}
    click button                     ${login_button}
    Select Frame                     ${oneid_frame}
    click button                     ${signup_button}
    wait until element is visible    ${first_name_field}
    input text                       ${first_name_field}       Test
    input text                       ${last_name_field}        Ui
    ${random_email}                  generate a random email
    input text                       ${new_email_field}        ${random_email}
    input password                   ${new_password_field}     test_api
    wait until element is visible    ${signup_button}          10s
    click button                     ${signup_button}
    sleep     8s
    set global variable              ${random_email}
    Create a League

Create a League
    go to                            ${league_create_url}
    set selenium implicit wait       10s
    wait until element is visible    ${league_name_field}     10s
    input text                       ${league_name_field}    TestLeague
    click element                    ${no_of_teams}
    click button                     ${league_create_button}
    wait until element is visible    ${dismiss_invite}       10s
    click element                    ${dismiss_invite}
    Begin Draft
    Navigate to LM Tools and start inputing players for the team
    click element                    ${save_roster}
    reload page
    wait until element is visible    ${finish_button}       10s
    click element                    ${finish_button}
    wait until element is visible    ${release_roster}      10s
    click element                    ${release_roster}
    sleep       2s

Begin Draft
    wait until element is visible    ${schedule_draft_button}    10s
    click element    ${schedule_draft_button}
    wait until element is visible    ${offline_draft_type}       10s
    click element    ${offline_draft_type}
    click button     ${save_draft_type}
    sleep       3s

Navigate to LM Tools and start inputing players for the team
    wait until element is visible    ${lm_tool_option}                   10s
    click element    ${lm_tool_option}
    wait until element is visible     ${input_offline_results_link}      10s
    click element    ${input_offline_results_link}
    wait until element is visible    ${begin_offline_draft}              10s
    click element    ${begin_offline_draft}
    Add players for team 1

Add players for team 1
    wait until element is visible             ${player_names}           10s
    @{players_elements}    get webelements    ${player_names}
    ${json}     load json from file           resource/UI/Pages/Team1_players.json
    FOR    ${no}    IN RANGE    13
      ${name}     get value from json     ${json}      $.Player${no}
      input text    ${players_elements}[${no}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
    END

Login into the espn site
    mouse over                       ${profile_Locator}
    click button                     ${login_button}
    Select Frame                     ${oneid_frame}
    wait until element is visible    ${Email_field}
    input text                       ${Email_field}        ${random_email}
    wait until element is visible    ${Password_field}
    input password                   ${Password_field}     test_api
    click button                     ${login_button}

Select any fantasy team from the existing league ${league_name} to move players
     go to                           ${HOMEPAGE_URL}
     wait until element is visible   ${profile_Locator}     10s
     mouse over                      ${profile_Locator}
     click element                   xpath://span[text()='${league_name}']

Delete the ESPN Account
     go to                           ${HOMEPAGE_URL}
     wait until element is visible   ${profile_Locator}           10s
     mouse over                      ${profile_Locator}
     wait until element is visible   ${espn_profile}              10s
     click element                    ${espn_profile}
     select frame                    ${oneid_frame}
     wait until element is visible   ${delete_account}            10s
     click element                   ${delete_account}
     wait until element is visible   ${confirm_delete_account}    10s
     click element                    ${confirm_delete_account}
     wait until element is visible   ${delete_account_info}       10s
     click element                   ${delete_account_info}