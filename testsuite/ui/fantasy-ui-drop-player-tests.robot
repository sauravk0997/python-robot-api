*** Settings ***
Library              Collections
Library              OperatingSystem
Library              SeleniumLibrary
Library              RequestsLibrary
Resource             resource/UI/FantasyUIdrop.resource
Resource             resource/UI/Common/Common.resource
Test Setup           Load players
Test Teardown        Reset draft

*** Test Cases ***
Drop a player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Launch the Browser and Navigate to Espn site
    Login into the espn site for drop
    Select any fantasy team
    Click on drop button
    ${before_drop}    check no of players available to drop
    Click on drop player and continue
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from my team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Launch the Browser and Navigate to Espn site
    Login into the espn site for drop
    Select any fantasy team
    Click on LM tools
    Click on roster moves
    Select options from dropdown
    ${before_drop}    check no of players available to drop
    Click on drop player and continue in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}
