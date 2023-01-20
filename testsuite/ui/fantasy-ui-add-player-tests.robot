*** Settings ***
Documentation        Adding the player to the team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-ui-add-players-tests.robot
Metadata             Author      Saurav Kumar
Metadata             Date        26-12-2022
Resource             resource/UI/Pages/FantasyUIAddPlayerPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Suite Setup           Run Keywords    Launch the Browser and Navigate to the https://www.espn.com/ site
...        AND        Login into the espn site with user credentials ${username} and ${encrypted_password}
...        AND        Select my fantasy league ${LEAGUE_NAME}
Suite Teardown        Close the current Browser

*** Variables ***
${username}                  sauravk0997@gmail.com
${encrypted_password}        U2F1cmF2QDExMDM=
${LEAGUE_NAME}               UI-Automation-Testing-League-1
${OTHER_LEAGUE}              My 2023 League
${MESSAGE1}                  You must drop a player to clear your roster for the incoming players.
${MESSAGE2}                  You must drop a player with default position C to clear your roster for the incoming players.

*** Test Cases ***
As a Team Owner, drop and then add player to my team
    [Documentation]    Firstly, Drop a Player from my team and then add a player to my team as a Team Owner.
    [Tags]    fantasy-ui    add-player    valid    CSEAUTO-29548    CSEAUTO-28338    CSEAUTO-29683
    validate the user is navigated to the teams page
    Drop a player from my fantasy team
    Validate whether player is dropped from team
    Add players to the team as a Team Owner
    Validate the player is added to a team

As a League Manager, drop and then add player to other team
    [Documentation]    Firstly, Drop a Player from other team and then add a player to that team as a League Manager.
    [Tags]    fantasy-ui    add-player    valid    CSEAUTO-29716    CSEAUTO-28338    CSEAUTO-29685
    validate the user is navigated to the teams page
    Navigate to LM tools, Click on Roster moves and do the dropPlayers on the Team 2 
    Drop players fom the team as an LM
    Validate whether player is dropped from team
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 2
    Add players to the team as an LM
    Click on the my team link
    Validate the player is added to a team

As a League Manager, drop and then add player to my team
    [Documentation]    Firstly, Drop a Player from my team and then add a player to my team as a League Manager.
    [Tags]    fantasy-ui    add-player    valid    CSEAUTO-29716    CSEAUTO-28338    CSEAUTO-29763
    validate the user is navigated to the teams page
    Navigate to LM tools, Click on Roster moves and do the dropPlayers on the Team 1 
    Drop players fom the team as an LM
    Validate whether player is dropped from team
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 1
    Add players to the team as an LM
    Click on the my team link
    Validate the player is added to a team

As a Team Owner, add and drop a player from my team
    [Documentation]     Add a player to my team and Drop a player from my team as a Team Owner.
    [Tags]    fantasy-ui    add-player    valid    CSEAUTO-29716    CSEAUTO-28338    CSEAUTO-29764
    Add and drop a player when team roster is full
    Validate the player is added to a team

As a League Manager, add and drop a player from another team
    [Documentation]    Add a player to another team and Drop a player from that team as a League Manager.
    [Tags]    fantasy-ui    add-player    valid    CSEAUTO-29716    CSEAUTO-28338    CSEAUTO-29765
    Click on the my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 3
    Click on the my team link
    Add and drop a player from other team as an LM, when roster is full
    Click on the my team link
    Validate the player is added to a team

As a League Manager, add and drop a player from my team
    [Documentation]    Add a player to my team and Drop a player from my team as a League Manager.
    [Tags]    fantasy-ui    add-player    valid    CSEAUTO-29716    CSEAUTO-28338    CSEAUTO-29766
    Click on the my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 1
    Click on the my team link
    Add and drop a player from my team as an LM, when roster is full
    Click on the my team link
    Validate the player is added to a team

As a Team Owner, I should not be able to add a player to my team if the roster is full.
    [Documentation]    As a Team Owner, I should not be able to add a player to my team if my roster is full.
    [Tags]    fantasy-ui    add-player    invalid    CSEAUTO-30053    CSEAUTO-28338    CSEAUTO-30138
    Switch to the league ${OTHER_LEAGUE}
    Validate players are addable when the roster is full
    Validate that the player is not added to your team with the error message ${MESSAGE1}.

As a Team Manager, I should not be able to add more than 4 Position C players to my team.
    [Documentation]    As a Team Owner, I should not be able to add a Position C player to my team if my roster already has 4 Position C players.
    [Tags]    fantasy-ui    add-player    invalid    CSEAUTO-30053    CSEAUTO-28338    CSEAUTO-30135
    Switch to the league ${OTHER_LEAGUE}
    Add Position C player to my team as Team Owner
    Drop a non Position C Player from the team
    Validate that the player is not added to your team with the error message ${MESSAGE2}.

As a League Manager, I should not be able to add more than 4 Positon C players to anothe team.
    [Documentation]    As a League Manager, I should not be able to add a Position C player to another team if that team's roster already has 4 Position C players.
    [Tags]    fantasy-ui    add-player    invalid    CSEAUTO-30053    CSEAUTO-28338    CSEAUTO-30136
    Switch to the league ${OTHER_LEAGUE}
    Click on the my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 3
    Select any Opposition Team, Team 3
    Add Position C player to another team 3 as an LM
    Drop a non Position C Player from the team 
    Validate that the player is not added to your team with the error message ${MESSAGE2}.

As a League Manager, I should not be able to add a player to another team if the roster is full.
    [Documentation]    As a League Manager, I should not be able to add a player to another team if my roster is full.
    [Tags]    fantasy-ui    add-player    invalid    CSEAUTO-30053    CSEAUTO-28338    CSEAUTO-30136
    Switch to the league ${OTHER_LEAGUE}
    Navigate to LM tools, Click on Roster moves and do the dropPlayers on the Team 3