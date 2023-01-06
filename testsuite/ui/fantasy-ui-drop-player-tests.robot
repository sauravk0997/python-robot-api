*** Settings ***
Library              Collections
Library              OperatingSystem
Library              SeleniumLibrary
Library              RequestsLibrary
Resource             resource/UI/Pages/FantasyDropPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Resource             resource/UI/FantasyUICommonMove.resource
Resource             resource/UI/Pages/FantasyUIMovePlayer.resource
Suite Setup          FantasyUIcommon.Launch the site and create a test account and a fantasy league
Suite Teardown       Delete the account and close browser


*** Variables ***
${ESPN_URL}        https://www.espn.com/
${MY_LEAGUE}       My-Fantasy-League-5324

*** Test Cases ***
Drop a player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select my fantasy team
    Click on drop button
    ${before_drop}    check no of players available to drop
    Click on drop player and continue
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from my team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Click on drop player and continue in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from droppable list as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select my fantasy team
    Click on drop button
    ${before_drop}    check no of players available to drop
    Click on drop player and continue
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Drop a player from undroppable list as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Click on drop undroppable player and continue in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

 Drop an undroppable player from the team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Click on drop undroppable player and continue in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

 Drop multiple players from the team at the same time as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Click on multiple players to drop in LM tools
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-2}    ${after_drop}

 Drop multiple players from the team at the same time as a Team manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select my fantasy team
    Click on drop button
    ${before_drop}    check no of players available to drop
    Click on multiple players to drop
    Click on confirm drop
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-2}    ${after_drop}

 Drop 'DTD' player from a team as a League manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Check availability for Day-To-Day player and drop
    IF    ${avail} == ${TRUE}
      ${after_drop}    Verify the player has been dropped inside LM tools
      Should Be Equal    ${${before_drop}-1}    ${after_drop}
    ELSE 
      Log To Console    "No DTD players in the team"
    END

 Drop 'OUT' player from a team as a League manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Check availability for Out player and drop
    IF    ${avail} == ${TRUE}
      ${after_drop}    Verify the player has been dropped inside LM tools
      Should Be Equal    ${${before_drop}-1}    ${after_drop}
    ELSE
      Log To Console    "No OUT players in the team"
    END
