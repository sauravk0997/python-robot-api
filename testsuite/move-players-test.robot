*** Settings ***
Documentation        Moving players form a fantasy league Positive tests are executing along with schema validation
...                  to run: robot --pythonpath $PWD ./testsuite/Move-Players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        14-11-2022
Library              RequestsLibrary
Library              Collections
Library              OperatingSystem
Library              RPA.JSON
Resource             resource/FantasyLeagueResource.Robot
Library              lib/validators/FantasyMovePlayerValidator.py

*** Test Cases ***
Move the Players by swaping the position of the players in current scoring period
    [Tags]    swap-players    valid  CSEAUTO-28347  CSEAUTO-28392
    Intialize user cookie and Create a league
    Start offline draft
    Add players to a team
    Save the added players to the team
    Swap the position of players in current scoring period and validate the response schema
    Validate players changed their positions ${swap_player_response}

Move any lineup Player to Bench in current scoring period
    [Tags]    moveplayers-to-bench  valid   CSEAUTO-28347   CSEAUTO-28395
    Move any lineup player to bench in current scoring period and validate the response schema
    Validate player is moved to bench ${lineup_to_bench_response}

Move any Player from Bench to LineUp in current scoringperiod
    [Tags]    moveplayers-from-bench-to-lineup  valid   CSEAUTO-28347   CSEAUTO-28395
    Move the eligible Bench Player to lineup in current scoring period and validate the response schema
    Validate players changed their positions ${swap_player_response}

Move the Players by swaping the position of the players in future scoring period
    [Tags]    swap-players-future-scoring-period    valid  CSEAUTO-28630  CSEAUTO-28646
    Swap the position of players in future scoring period and validate the response schema
    Validate players changed their positions ${swap_player_response}

Move any lineup Player to Bench in future scoring period
    [Tags]    moveplayers-to-bench  valid   CSEAUTO-28347   CSEAUTO-28395
    Move any lineup player to bench in future scoring period and validate the response schema
    Validate player is moved to bench ${lineup_to_bench_response}

Move any Player from Bench to LineUp in future scoringperiod
    [Tags]    moveplayers-from-bench-to-lineup  valid   CSEAUTO-28347   CSEAUTO-28395
    Move the eligible Bench Player to lineup in future scoring period and validate the response schema
    Validate players changed their positions ${swap_player_response}

