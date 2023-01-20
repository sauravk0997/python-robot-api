*** Settings ***
Resource    resource/UI/FantasyUIcommon.resource

*** Variables ***
${FANTASY_PROFILE_ICON}       css:[role='button']
${FANTASY_LOGIN_LINK}         xpath://li//span[text()='Log In']
${DISNEY_ID_IFRAME}           id:disneyid-iframe
${LOGOUT_LINK}                xpath://li//span[text()='Log Out']
${CREATE_A_LEAGUE_BUTTON}     xpath://button[contains(text(),'Create a League')]
${CREATE_LEAGUE_BUTTON}       xpath://button[.='Create League']
${LEAGUE_NAME_INPUT_FIELD}    css:.form__control.LeagueNameInput
${LEAGUE_SIZE_4}              css:.LeagueSizeRadioGroup__ControlLabel:nth-of-type(1)
${SCORING_H2H_POINTS}         css:.LargeRadioGroup__ControlLabel:nth-of-type(2)
${CLOSE_ICON}                 css:.lightbox__closebtn__wrap
${INVITE_MANAGERS}            xpath://a[text()='Invite Managers']
${INVITE_LINK_TEXT}           xpath://input[@id='invite_link_input_text']
${JOIN_THIS_LEAGUE_BUTTON}    xpath://button[contains(text(),'Join This League')]
${TEAM_LOCATION}              css:[data-name='teamLocation']
${TEAM_NICKNAME}              css:[data-name='teamNickName']
${TEAM_ABBREVIATION}          css:[data-name='teamAbbrev']
${FINISH_BUTTON}              css:.join-league-form__finish
${MY_TEAMS_ICON}              css:.myTeams.NavSecondary__Item>a>svg
${LM_TOOLS}                   xpath://span[text()='LM Tools']
${OPPOSING_TEAMS}             xpath://span[text()='Opposing Teams']
${DELETE_LEAGUE_TEXT}         xpath://a[text()='Delete League']
${DELETE_LEAGUE_BUTTON}       xpath://button[text()='Delete League']
${CONFIRM_TEXT}               xpath://span[text()='Confirm']
${SUCCESS_HEADING}            css:.success-heading
${OFFLINE_DRAFT_TYPE}         xpath://label[text()="Offline"]
${SAVE_DRAFT_TYPE}            xpath://button[text()='Save Changes']
${EDIT_DRAFT_SETTINGS}        xpath://a[text()='Edit Draft Settings']
${INPUT_OFFLINE_DRAFT}        xpath://a[text()='Input Offline Draft Results']
${BEGIN_OFFLINE_DRAFT}        xpath://button[text()='Begin Offline Draft']
${PLAYER_NAMES}               xpath://input[@placeholder='Player Name']
${SAVE_ROSTER}                xpath:(//button[text()='Save Roster'])[4]
${FINISHED_RESULT_BUTTON}     xpath://button[text()='I Am Finished Entering Results']
${RELEASE_ROSTER}             xpath://span[text()='Release Rosters']
${ASSIGN_LM_POWERS}           xpath://a[text()='Assign League Manager Powers']
${SUBMIT_CHANGES_BUTTON}      xpath://button[text()='Submit Changes']
${CONTINUE_LEAGUE_OFFICE}     xpath://a[text()='Continue to League Office']
${SAVE_ROSTER_DEFAULT_BUTTON}    xpath://button[@class='Button Button--default rosterButton']
${TAKE_ME_TO_LEAGUE_ROSTERS}     xpath://div[@class='lightbox__content lightbox__content--desktop lightbox__content--isContent']//a[text()='Take me to League Rosters']
${INVALID_LEAGUE_NAME_ERROR}     xpath://div[text()='League name is not the correct length.']
${INVALID_LEAGUE_JOIN_ERROR}     xpath://div[text()='Oops! Looks like something went wrong. Please try again!']
${INVALID_USER_LOGIN_ERROR}      xpath://div[text()='The credentials you entered are incorrect.']

*** Keywords ***
Create a league
    Sleep    6
    Wait Until Page Contains Element    ${CREATE_A_LEAGUE_BUTTON}
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
    Wait Until Page Contains Element    ${INVITE_LINK_TEXT}
    ${invite_link}=    Get Element Attribute    ${INVITE_LINK_TEXT}    value
    Log    "Invite Link ::::"${invite_link}
    Set Global Variable    ${invite_link}

Send invitations, Accept Invitation send by the inviter and create teams
    FOR    ${index}    IN RANGE    0    3
        Execute Javascript   window.open('${invite_link}')
        ${handles}=  Get Window Handles
        Switch Window   ${handles}[1]
        log in to the site    ${user_emails}[${index}]    VUl1c2VyQEVTUE4=
        Page Should Contain Button    ${JOIN_THIS_LEAGUE_BUTTON}
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
    check iframe and re-login into the application
    Wait Until Page Contains Element    ${MY_TEAMS_ICON}
    Wait Until Element Is Visible    ${MY_TEAMS_ICON}
    Mouse Over       ${MY_TEAMS_ICON}
    click element    xpath://span[text()='${league_name}']
    Mouse Over    ${OPPOSING_TEAMS}
    Wait Until Element Is Visible     ${LM_TOOLS}    timeout=10
    Mouse Over    ${LM_TOOLS}
    Sleep    2
    Double Click Element    ${LM_TOOLS}
    Sleep    2
    Wait Until Element Is Visible    ${DELETE_LEAGUE_TEXT}
    click element    ${DELETE_LEAGUE_TEXT}
    Wait Until Element Is Visible    ${DELETE_LEAGUE_BUTTON}
    Click Button    ${DELETE_LEAGUE_BUTTON}
    Wait Until Element Is Visible    ${CONFIRM_TEXT}
    Click Element   ${CONFIRM_TEXT}
    Wait Until Element Is Visible    ${SUCCESS_HEADING}
    ${success_text}=    Get Text    ${SUCCESS_HEADING}
    Should Be Equal As Strings    ${success_text}    Success!    msg=The expected and actual strings are not Equal
    Close the current Browser

check iframe and re-login into the application
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    ${DISNEY_ID_IFRAME}
    Run Keyword If    ${present}    
    ...    Re-login to the fantasy application as root default user
    ...  ELSE    Run Keywords
    ...    Logout from Fantasy Application
    ...    Re-login to the fantasy application as root default user
    Sleep    2

Schedule Offline Draft
    check iframe and re-login into the application
    Wait Until Page Contains Element    ${MY_TEAMS_ICON}
    Wait Until Element Is Visible    ${MY_TEAMS_ICON}
    Mouse Over       ${MY_TEAMS_ICON}
    click element    xpath://span[text()='${league_name}']
    Wait Until Element Is Visible     ${LM_TOOLS}
    Click Element   ${LM_TOOLS}
    Wait Until Element Is Visible    ${EDIT_DRAFT_SETTINGS}
    click element     ${EDIT_DRAFT_SETTINGS}
    wait until element is visible    ${OFFLINE_DRAFT_TYPE}       timeout=10s
    click element    ${OFFLINE_DRAFT_TYPE}
    click button     ${SAVE_DRAFT_TYPE}

Begin Offline Draft
    Click on LM Tools Tab
    Wait Until Page Contains Element    ${INPUT_OFFLINE_DRAFT}
    click element     ${INPUT_OFFLINE_DRAFT}
    Wait Until Element Is Visible    ${BEGIN_OFFLINE_DRAFT}
    Click Button     ${BEGIN_OFFLINE_DRAFT}

Click on LM Tools Tab
    Mouse Over    ${OPPOSING_TEAMS}
    Wait Until Page Contains Element    ${LM_TOOLS}
    Wait Until Element Is Visible     ${LM_TOOLS}    timeout=10
    Mouse Over    ${LM_TOOLS}
    Sleep    1
    Double Click Element    ${LM_TOOLS}
    Sleep    2

Add players to all teams as league creator user and save the roster
    Add players to team 1 as league creator user
    Add players to team 2 as league creator user
    Add players to team 3 as league creator user
    Add players to team 4 as league creator user
    Scroll Element Into View    ${FINISHED_RESULT_BUTTON}
    Wait Until Element Is Visible    ${FINISHED_RESULT_BUTTON}
    Sleep    2
    Click Button    ${FINISHED_RESULT_BUTTON}
    Wait Until Element Is Visible    ${RELEASE_ROSTER}
    Sleep    2
    Click Element    ${RELEASE_ROSTER}
    Wait Until Element Is Visible    ${TAKE_ME_TO_LEAGUE_ROSTERS}
    Click element     ${TAKE_ME_TO_LEAGUE_ROSTERS}

Add players to team ${team_no} as league creator user
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${players_list}     load json from file           resource/UI/offlineDraftTeam${team_no}.json
    FOR    ${index}    IN RANGE    13
      ${name}     get value from json     ${players_list}      $.Player${index}
      input text    ${players_elements}[${index}]      ${name}
      wait until element is visible      //button[@data-player-search-playername="${name}"]
      click button    //button[@data-player-search-playername="${name}"]
      Scroll Element Into View    ${SAVE_ROSTER}
    END
    IF    ${team_no} == 3
        Scroll Element Into View    ${SAVE_ROSTER}
        Click Button    xpath:(//button[text()='Save Roster'])[${team_no}]
    ELSE
        Scroll Element Into View    xpath:(//button[text()='Save Roster'])[${team_no}]
        Click Button    xpath:(//button[text()='Save Roster'])[${team_no}]
    END

Assign League Manager Roles to Team2, Team3 and Team4 owners
    Click on LM Tools Tab
    Wait Until Element Is Visible     ${ASSIGN_LM_POWERS}
    Click Element    ${ASSIGN_LM_POWERS}
    FOR    ${index}    IN RANGE    1    4
        Wait Until Element Is Visible     css:[data-idx='${index}'] .control__indicator
        Click Element    css:[data-idx='${index}'] .control__indicator
    END
    Click Button    ${SUBMIT_CHANGES_BUTTON}
    Wait Until Element Is Visible     ${CONTINUE_LEAGUE_OFFICE}
    click element    ${CONTINUE_LEAGUE_OFFICE}

Add players to team ${team_id} as team owner ${team_owner_id}
    Logout from Fantasy Application
    Re-login to the fantasy application as a ${team_id} user
    #Reload Page
    Wait Until Page Contains Element    ${PLAYER_NAMES}
    wait until element is visible             ${PLAYER_NAMES}           timeout=10s
    @{players_elements}    get webelements    ${PLAYER_NAMES}
    ${players_list}     load json from file           resource/UI/offlineDraftTeam${team_id}.json
    FOR    ${index}    IN RANGE    13
      ${name}     get value from json     ${players_list}      $.Player${index}
      ${int_value}=    Convert To Integer    ${team_id}
      ${expressioin status}=    Evaluate    ${int_value} == 3
        IF    ${expressioin status} == True
            Scroll Element Into View    xpath:(//button[text()='Save Roster'])[2]
            input text    ${players_elements}[${index}]      ${name}
            click button    //button[@data-player-search-playername="${name}"]
        ELSE
            input text    ${players_elements}[${index}]      ${name}
            wait until element is visible      //button[@data-player-search-playername="${name}"]
            click button    //button[@data-player-search-playername="${name}"]
        END
    END
    click button     ${SAVE_ROSTER_DEFAULT_BUTTON}

Create a Fantasy League with a lengthy league name and validate the error message
    Sleep    6
    Wait Until Page Contains Element    ${CREATE_A_LEAGUE_BUTTON}
    Wait Until Element Is Enabled    ${CREATE_A_LEAGUE_BUTTON}  timeout=10s
    Click Button    ${CREATE_A_LEAGUE_BUTTON}
    ${random_string}=    Generate Random String    25    0123456789
    ${league_name}=   Convert To String     My-Fantasy-League-${random_string}
    Wait Until Element Is Visible    ${LEAGUE_NAME_INPUT_FIELD}   timeout=10s
    Input Text    ${LEAGUE_NAME_INPUT_FIELD}     ${league_name}
    Click Element    ${LEAGUE_SIZE_4}
    Click Element    ${SCORING_H2H_POINTS}
    Click Element    ${CREATE_LEAGUE_BUTTON}
    Wait Until Element Is Visible    ${INVALID_LEAGUE_NAME_ERROR}
    ${error_message}=    Get Text    ${INVALID_LEAGUE_NAME_ERROR}
    Should Be Equal As Strings    ${error_message}    League name is not the correct length.    msg=The expected and actual strings are not Equal
    Close the current Browser

Join invalid invite id and valid the error message
    Execute Javascript   window.open('${invite_link}12345')
    ${handles}=  Get Window Handles
    Switch Window   ${handles}[1]
    Wait Until Page Contains Element    ${INVALID_LEAGUE_JOIN_ERROR}
    ${error_message}=    Get Text    ${INVALID_LEAGUE_JOIN_ERROR}
    Should Be Equal As Strings    ${error_message}    Oops! Looks like something went wrong. Please try again!    msg=The expected and actual strings are not Equal
    Switch Window    ${handles}[0]

Join the league as an invalid user and valid the error message
    ${invalid_username}=    Set Variable    xyz11@test.com
    ${invalid_password}=    Set Variable    YWJj
    Execute Javascript   window.open('${invite_link}')
    ${handles}=  Get Window Handles
    Switch Window   ${handles}[1]
    log in to the site    ${invalid_username}    ${invalid_password}
    Select Frame      ${DISNEY_ID_IFRAME} 
    sleep    1
    Wait Until Element Is Visible    ${INVALID_USER_LOGIN_ERROR}
    ${error_message}=    Get Text    ${INVALID_USER_LOGIN_ERROR}
    Should Contain Any    ${error_message}    The credentials you entered are incorrect.    msg=The expected and actual strings are not Equal
    Switch Window    ${handles}[0]
    Reload Page
    Sleep    2
    Wait Until Element Is Visible    ${DISNEY_ID_IFRAME}

validate that the invalid league id is not present
    Wait Until Page Contains Element    ${MY_TEAMS_ICON}
    Wait Until Element Is Visible    ${MY_TEAMS_ICON}
    Mouse Over       ${MY_TEAMS_ICON}
    ${status}=    Run Keyword And Return Status    Element Should Be Visible    xpath://span[text()='invalid-league']
    Run Keyword If    ${status} is not ${TRUE}
    ...    Log    "Invalid league does not exists and it is expected."