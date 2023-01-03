*** Settings ***
Documentation        Moving players of any fantasy team in fantasy league Positive tests using Robot selenium
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-league-move-players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        20-12-2022
Resource             resource/UI/FantasyUICommonMove.resource
Resource             resource/UI/Pages/FantasyUIMovePlayer.resource
Suite Setup          Create test account and a fantasy League
Suite Teardown       Delete the league, test account and close browser

*** Variables ***

*** Test Cases ***
As a team owner move the Players by swaping the position of the players in current scoring period
    [Tags]    moveplayers    valid     CSEAUTO-29542
    Select any fantasy league TestLeague to move players
     User is navigated to teams page
    Check for the players in the team who are available to move from there existing positions
    Swap the Position of the players in the current scoring period
    Verify whether the player swapped their Position

As a Team Owner of a fantasy league I am able to move any player to the Bench from my team for the current scoring period
    [Tags]    moveplayers    valid     CSEAUTO-29543
    Select any fantasy league TestLeague to move players
    User is navigated to teams page
    Check and Move any eligible existing lineup player to Bench
    Verify whether the Player is Moved to Bench

As a Fantasy Team Owner move any player from the Bench to the lineup for the current scoring period
    [Tags]    moveplayers    valid     CSEAUTO-29544
    Select any fantasy league TestLeague to move players
    User is navigated to teams page
    Move any eligible Bench Player to lineup
    Verify whether the Player is Moved to Lineup

As a League Manager Swap the positions of players of any other team in a Current ScoringPeriod
    [Tags]    moveplayers    valid    CSEAUTO-29773
    Select any fantasy league TestLeague to move players
    Navigate to LM Tools
    select edit rosters from LM Tools page
    Select any team in the league from edit roster page
    Check for the players in the team who are available to move from there existing positions
    Swap the Position of the players in the current scoring period
    Verify whether the player swapped their Position

As a League Manager Move any Player to Bench of any other team in a Current ScoringPeriod
    [Tags]    moveplayers    valid      CSEAUTO-29775
    Select any fantasy league TestLeague to move players
    Navigate to LM Tools
    select edit rosters from LM Tools page
    Select any team in the league from edit roster page
    Check and Move any eligible existing lineup player to Bench
    Verify whether the Player is Moved to Bench

As a League Manager Move Player from the Bench to the lineup of any other team in a Current ScoringPeriod
    [Tags]    moveplayers    valid    CSEAUTO-29776
    Select any fantasy league TestLeague to move players
    Navigate to LM Tools
    select edit rosters from LM Tools page
    Select any team in the league from edit roster page
    Move any eligible Bench Player to lineup
    Verify whether the Player is Moved to Lineup
