*** Settings ***
Library              Collections
Library              OperatingSystem
Library              SeleniumLibrary
Library              RequestsLibrary
Resource             resource/UI/Pages/FantasyDropPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Test Setup           Load players
Test Teardown        Reset draft

*** Variables ***
${ESPN_URL}        https://www.espn.com/
${MY_LEAGUE}       My-Fantasy-League-5324

*** Test Cases ***
Drop a player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Launch the Browser and Navigate to the ${ESPN_URL} site
    Login into the espn site for drop
    Select my fantasy ${MY_LEAGUE}
    Click on drop button
    ${before_drop}    check no of players available to drop
    Click on drop player and continue
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from my team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Launch the Browser and Navigate to the ${ESPN_URL} site
    Login into the espn site for drop
    Select my fantasy ${MY_LEAGUE}
    Click on LM tools
    Click on roster moves
    Select options from dropdown
    ${before_drop}    check no of players available to drop
    Click on drop player and continue in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from droppable list as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Launch the Browser and Navigate to the ${ESPN_URL} site
    Login into the espn site for drop
    Select my fantasy ${MY_LEAGUE}
    Click on drop button
    ${before_drop}    check no of players available to drop
    Click on drop player and continue
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from undroppable list as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Launch the Browser and Navigate to the ${ESPN_URL} site
    Login into the espn site for drop
    Select my fantasy ${MY_LEAGUE}
    Click on LM tools
    Click on roster moves
    Select options from dropdown
    ${before_drop}    check no of players available to drop
    Click on drop undroppable player and continue in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}