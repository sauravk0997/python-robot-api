*** Settings ***
Documentation        Dropping and then Adding a players to the team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-league-move-players-test.robot
Metadata             Author      Saurav Kumar
Metadata             Date        26-12-2022
Resource             resource/UI/Common/Common.resource
Resource             resource/UI/Pages/AddDrop.robot
Test Setup           Launch the Browser and Navigate to Espn site
Test Teardown        Close Browser Session


*** Variables ***


*** Test Cases ***
As a Team Owner drop and plyers to my team
    [Tags]    moveplayers    valid
    Login into the espn site
    Select fantasy team from the existing league to drop players
    User is navigated to teams page
    Dropping a player from my team
    Validate whether player is dropped from team
    Adding a player to my team
    # Validate whether player is added to team
    