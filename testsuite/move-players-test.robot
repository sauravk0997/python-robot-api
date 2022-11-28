*** Settings ***
Documentation        Moving players form a fantasy league Positive tests are executing along with schema validation
...                  to run: robot --pythonpath $PWD ./testsuite/Move-Players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        14-11-2022
Library              RequestsLibrary
Library              Collections
Library              OperatingSystem
Library              RPA.JSON
Resource             resource/FantasyLeagueResource.Resource
Library              lib/validators/FantasyMovePlayerValidator.py

*** Test Cases ***
Move the Players by swaping the position of the players in current scoring period
    [Tags]    swap-players    valid  CSEAUTO-28347  CSEAUTO-28392
#    Intialize user cookie and Create a league
#    Start offline draft
#    Add players to a team
#    Save the added players to the team
    ${team_id}    convert to integer    0
    Swap the position of players of ${team_id} in current scoring period and validate the response schema and check whether the players changed their positions


Move any lineup Player to Bench in current scoring period
    [Tags]    moveplayers-to-bench  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}    convert to integer    0
    Move any lineup player to bench of ${team_id} in current scoring period and validate the response schema and check whether the player is moved to bench


Move any Player from Bench to LineUp in current scoringperiod
    [Tags]    moveplayers-from-bench-to-lineup  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}    convert to integer    0
    Move the eligible Bench Player of ${team_id} to lineup in current scoring period and validate the response schema and check whether the players changed their positions


Move the Players by swaping the position of the players in future scoring period
    [Tags]    swap-players-future-scoring-period    valid  CSEAUTO-28630  CSEAUTO-28646
    ${team_id}    convert to integer    0
    ${swap_player_response}     Swap the position of players of ${team_id} in future scoring period and validate the response schema
    Validate players changed their positions    ${swap_player_response}

Move any lineup Player to Bench in future scoring period
    [Tags]    moveplayers-to-bench  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}    convert to integer    0
    ${lineup_to_bench_response}     Move any lineup player to bench of ${team_id} in future scoring period and validate the response schema
    Validate player is moved to bench ${lineup_to_bench_response}

Move any Player from Bench to LineUp in future scoringperiod
    [Tags]    moveplayers-from-bench-to-lineup  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}    convert to integer    0
    ${swap_player_response}     Move the eligible Bench Player of ${team_id} to lineup in future scoring period and validate the response schema
    Validate players changed their positions    ${swap_player_response}

As a League manager swap the position of players of any team in a league in current scoring period
    [Tags]    swap-players    valid  CSEAUTO-28347  CSEAUTO-28392
    ${team_id}      Get any different team_id
    Swap the position of players of ${team_id} in current scoring period and validate the response schema and check whether the players changed their positions


As a League manager move any lineup Player to Bench of any team in a league in current scoring period
    [Tags]    moveplayers-to-bench  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}      Get any different team_id
    Move the eligible Bench Player of ${team_id} to lineup in current scoring period and validate the response schema and check whether the players changed their positions


As a League manager move any Player from Bench to LineUp of any team in a league in current scoringperiod
    [Tags]    moveplayers-from-bench-to-lineup  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}      Get any different team_id
    Move the eligible Bench Player of ${team_id} to lineup in current scoring period and validate the response schema and check whether the players changed their positions


As a League manager swap the position of players of any team in a league in future scoring period
    [Tags]    swap-players-future-scoring-period    valid  CSEAUTO-28630  CSEAUTO-28646
    ${team_id}      Get any different team_id from future scoring period
    Swap the position of players of ${team_id} in future scoring period and validate the response schema
    Validate players changed their positions    ${swap_player_response}

As a League manager move any lineup Player to Bench of any team in a league in future scoring period
    [Tags]    moveplayers-to-bench  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}      Get any different team_id from future scoring period
    Move any lineup player to bench of ${team_id} in future scoring period and validate the response schema
    Validate player is moved to bench ${lineup_to_bench_response}

As a League manager move any Player from Bench to LineUp of any team in a league in future scoringperiod
    [Tags]    moveplayers-from-bench-to-lineup  valid   CSEAUTO-28347   CSEAUTO-28395
    ${team_id}      Get any different team_id from future scoring period
    Move the eligible Bench Player of ${team_id} to lineup in future scoring period and validate the response schema
    Validate players changed their positions    ${swap_player_response}






