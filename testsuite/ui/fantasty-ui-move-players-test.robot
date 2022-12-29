*** Settings ***
Documentation        Moving players of any fantasy team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-league-move-players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        20-12-2022
Resource             resource/UI/FantasyUICommonMove.resource
Resource             resource/UI/Pages/FantasyUIMovePlayer.resource
Suite Setup          Launch the site and create a test account and a fantasy league
Suite Teardown       Delete the account and close browser

*** Variables ***


*** Test Cases ***
As a team owner move the Players by swaping the position of the players in current scoring period
    [Tags]    moveplayers    valid
    Select any fantasy team from the existing league TestLeague to move players
    User is navigated to teams page
    Check for the players in the team who are available to move from there existing positions
    Swap the Position of the players in the current scoring period
    Verify whether the player swapped their Position

As a Team Owner of a fantasy league I am able to move any player to the Bench from my team for the current scoring period
    Select any fantasy team from the existing league TestLeague to move players
    User is navigated to teams page
    Check and Move any eligible existing lineup player to Bench
    Verify whether the Player is Moved to Bench

As a Fantasy Team Owner move any player from the Bench to the lineup for the current scoring period
    Select any fantasy team from the existing league TestLeague to move players
    User is navigated to teams page
    Move any eligible Bench Player to lineup
    Verify whether the Player is Moved to Lineup
