*** Settings ***
Documentation        Dropping and then Adding a players to the team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-ui-add-players-tests.robot
Metadata             Author      Saurav Kumar
Metadata             Date        26-12-2022
Resource             resource/UI/Pages/FantasyUIAddPlayerPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Suite Setup           Run Keywords    Launch the Browser and Navigate to the https://www.espn.com/ site
...        AND        Login into the espn site with user credentials ${username} and ${password}
...        AND        Select my fantasy ${LEAGUE_NAME}
Suite Teardown        Close the current Browser

*** Variables ***
${username}        sauravk0997@gmail.com
${password}        U2F1cmF2QDExMDM=
${LEAGUE_NAME}     UI-Automation-Testing-League-1

*** Test Cases ***
As a Team Owner, drop and then add player to my team
    [Tags]    fantasy-ui    drop-add-player    valid    CSEAUTO-29548    CSEAUTO-29683
    validate the user is navigated to the teams page
    Drop a player from my fantasy team
    Validate whether player is dropped from team
    Add players to the team as an TO
    Validate the player is added to a team

As a League Manager, drop and then add player to other team
    [Tags]    fantasy-ui    drop-add-player    valid    CSEAUTO-29716    CSEAUTO-29685    
    validate the user is navigated to the teams page
    Navigate to LM tools, Click on Roster moves and do the dropPlayers on the Team 2 
    Drop players fom the team as an LM
    Validate whether player is dropped from team
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 2
    Add players to the team as an LM
    Validate the player is added to a team

As a League Manager, drop and then add player to my team
    [Tags]    fantasy-ui    drop-add-player    valid    CSEAUTO-29716    CSEAUTO-29763
    validate the user is navigated to the teams page
    Navigate to LM tools, Click on Roster moves and do the dropPlayers on the Team 1 
    Drop players fom the team as an LM
    Validate whether player is dropped from team
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 1
    Add players to the team as an LM
    Validate the player is added to a team

As a Team Owner, add and drop a player from my team
    [Tags]    fantasy-ui    drop-add-player    valid    CSEAUTO-29716    CSEAUTO-29764
    Add and drop a player when team roster is full
    Validate the player is added to a team
  
    
    


