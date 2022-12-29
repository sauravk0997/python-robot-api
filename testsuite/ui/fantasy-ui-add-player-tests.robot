*** Settings ***
Documentation        Dropping and then Adding a players to the team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-league-move-players-test.robot
Metadata             Author      Saurav Kumar
Metadata             Date        26-12-2022
Resource             resource/UI/Pages/FantasyUIAddPlayerPage.resource
Resource             resource/UI/FantasyUIcommon.resource
Test Setup           Launch the Browser and Navigate to the https://www.espn.com/ site
Test Teardown        Close the current Browser

*** Variables ***
${username}        sauravk0997@gmail.com
${password}        Saurav@1103
${LEAGUE_NAME}     UI-Automation-Testing-League-1
${ACTION}          addPlayers
${TEAM_ID_1}         1

*** Test Cases ***
As a Team Owner, drop and then add player to my team
    [Tags]    fantasy-ui    drop-add-player    valid    CSEAUTO-29548
    Login into the espn site with user credentials ${username} and ${password}
    Select my fantasy league ${LEAGUE_NAME} to drop players
    validate the user is navigated to the teams page
    Drop a player from my fantasy team
    Validate whether player is dropped from team
    Navigate to LM tools, Click on Roster moves and do the ${ACTION} on the ${TEAM_ID_1} 
    Add players to the team as an LM
    Validate the player is added to a team