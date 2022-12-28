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
${DELETE_LEAGUE_TEXT}         xpath://a[text()='Delete League']
${DELETE_LEAGUE_BUTTON}       xpath://button[text()='Delete League']
${CONFIRM_TEXT}               xpath://span[text()='Confirm']
${SUCCESS_HEADING}            css:.success-heading

*** Keywords ***
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
