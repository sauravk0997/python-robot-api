*** Settings ***
Resource             resource/UI/Pages/FantasyDropPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Resource             resource/UI/FantasyUICommonMove.resource
Suite Setup          FantasyUIcommon.Launch the site and create a test account and a fantasy league
Suite Teardown       Delete the league, test account and close browser

*** Test Cases ***
Drop a player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29481
    Select my team and check the available players
    Drop a player from the team
    Verify if the player has been dropped from teams page

Drop a player from my team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29482
    Select a team from LM tools
    Drop a player from the team inside LM tools
    Verify if the player has been dropped from LM tools page

Drop a player from droppable list as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29483
    Select my team and check the available players
    Drop a player from the team
    Verify if the player has been dropped from teams page

Drop a player from undroppable list as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29484
    Select a team from LM tools
    Select undroppable player and drop
    Verify if the player has been dropped from LM tools page

 Drop an undroppable player from the team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29768
    Select a team from LM tools
    Select undroppable player and drop
    Verify if the player has been dropped from LM tools page

 Drop multiple players from the team at the same time as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29769
    Select a team from LM tools
    Select multiple players and drop inside LM tools
    Verify multiple players have been dropped inside LM tools

 Drop multiple players from the team at the same time as a Team manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29770
    Select my team and check the available players
    Select multiple players and drop
    Verify multiple players have been dropped

 Drop 'DTD' player from a team as a League manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29771
    Select a team from LM tools
    Check availability for Day-To-Day player and drop
    Verify that DTD player has been dropped

 Drop 'OUT' player from a team as a League manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29772
    Select a team from LM tools
    Check availability for Out player and drop
    Verify that OUT player has been dropped

Drop an undroppable player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-30213
    Select my team and check the available players
    Undroppable player button should be disabled

 As a team manager, drop button not visible in other Team
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-30214
    Select an opposition team
    Drop button should not be visible

 As a team owner, you shouldn't be able to delete player from other team
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-30215
    Select a team from LM tools as a team manager
    All players button should be disabled

 As a team owner, drop button should not be visible in same team when team is empty
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-30216
    Reset and schedule empty draft
    Select my team and check the available players
    Drop button should be disabled
