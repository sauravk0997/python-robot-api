*** Settings ***
Documentation        Moving players of any fantasy team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-league-move-players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        20-12-2022
Resource             resource/UI/Common/Common.resource
Resource             resource/UI/Pages/TeamsPage.robot
Test Setup           Launch the Browser and Navigate to Espn site
Test Teardown        Close Browser Session


*** Variables ***


*** Test Cases ***
As a team owner move the Players by swaping the position of the players in current scoring period
    [Tags]    moveplayers    valid
    Login into the espn site
    Select any fantasy team from the existing league My-Fantasy-League-5487 to move players
    User is navigated to teams page
    Check for the players in the team who are available to move
    check for the players who can swap their positions based on the availability of players who are eligible for move
