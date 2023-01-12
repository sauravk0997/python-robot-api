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
Suite Teardown       Delete the league, test account and close browser


*** Variables ***
${ESPN_URL}        https://www.espn.com/

*** Test Cases ***
Drop a player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select my team and check the available players
    Drop a player from the team
    Verify if the player has been dropped from teams page

Drop a player from my team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select a team from LM tools
    Drop a player from the team inside LM tools
    Verify if the player has been dropped from LM tools page

Drop a player from droppable list as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select my team and check the available players
    Drop a player from the team
    Verify if the player has been dropped from teams page

Drop a player from undroppable list as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29461
    Select a team from LM tools
    Select undroppable player and drop
    Verify if the player has been dropped from LM tools page

 Drop an undroppable player from the team as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select a team from LM tools
    Select undroppable player and drop
    Verify if the player has been dropped from LM tools page

 Drop multiple players from the team at the same time as a league manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select a team from LM tools
    Select multiple players and drop inside LM tools
    Verify multiple players have been dropped inside LM tools

 Drop multiple players from the team at the same time as a Team manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select my team and check the available players
    Select multiple players and drop
    Verify multiple players have been dropped

 Drop 'DTD' player from a team as a League manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select a team from LM tools
    Check availability for Day-To-Day player and drop
    Verify that DTD player has been dropped

 Drop 'OUT' player from a team as a League manager
    [Documentation]    E2E - Add and drop players as a league manager
    [Tags]    valid    fantasy-ui    CSEAUTO-29718
    Select a team from LM tools
    Check availability for Out player and drop
    Verify that OUT player has been dropped
