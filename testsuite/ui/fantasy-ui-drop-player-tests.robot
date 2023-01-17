*** Settings ***
Resource             resource/UI/Pages/FantasyDropPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Resource             resource/UI/Pages/FantasyUIAddPlayerPage.resource
# Resource             resource/UI/Pages/FantasyUIMovePlayer.resource
# Suite Setup          FantasyUIcommon.Launch the site and create a test account and a fantasy league
# Suite Teardown       Delete the league, test account and close browser
Suite Setup           Run Keywords    Launch the Browser and Navigate to the https://www.espn.com/ site
...        AND        Login into the espn site with user credentials ${username} and ${encrypted_password}
...        AND        Select my fantasy ${LEAGUE_NAME}
Suite Teardown        FantasyUIcommon.Close the current Browser

*** Variables ***
${username}                  abdultest@test.com
${encrypted_password}        WVdrQ1h6YSFhVW44WU1u
${LEAGUE_NAME}               My-Fantasy-League-1059

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

Drop an undroppable player from my team as a team manager
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-29461
    Select my team and check the available players
    ${Status}=     Run Keyword And Return Status    Element Should be Disabled    id=//button[contains(@aria-label,'Can')]
    Run Keyword If    '${Status}'=='True'      Log To Console    "Can't drop an undroppable player"

 As a team manager, drop button not visible in other Team
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-29461
    Mouse Over    //span[text()='Opposing Teams']
    Click Element    //span[text()='FTM0 FN0 (FL0)']
    Element Should Not Be Visible    ${COMMON_DROP_BUTTON}

 As a team owner, you shouldn't be able to delete player from other team
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-29461
    Select a team from LM tools as a team manager
    ${Status}=     Run Keyword And Return Status    Element Should be Disabled    id=//button[contains(@aria-label,'Can')]
    Run Keyword If    '${Status}'=='True'      Log To Console    "Can't drop an undroppable player"

 As a team owner, drop button should not be visible in same team when team is empty
    [Documentation]    E2E - Add and drop players as a team manager
    [Tags]    invalid    fantasy-ui    CSEAUTO-29461
    Select my team and check the available players
    Drop all players from team and verify its empty
    Element Should Not Be Visible    ${COMMON_DROP_BUTTON}
