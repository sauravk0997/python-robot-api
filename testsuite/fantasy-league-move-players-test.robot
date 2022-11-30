*** Settings ***
Documentation        Moving players form a fantasy league Positive tests are executing along with schema validation
...                  to run: robot --pythonpath $PWD ./testsuite/Move-Players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        14-11-2022
Library              RequestsLibrary
Library              Collections
Library              OperatingSystem
Library              RPA.JSON
Resource             resource/FantasyMovePlayer.Resource
Resource             resource/suite_setup_teardown_moveplayer.resource
Library              lib/validators/FantasyMovePlayerValidator.py
Suite Setup          Get a Fantasy League details
Suite Teardown       Delete League

*** Variables ***
${own_team_id}     1

*** Test Cases ***
As a team owner move the Players by swaping the position of the players in current scoring period
    [Tags]    team-owner-swap-players-current-scoring-period    valid  CSEAUTO-28347  CSEAUTO-28392
    ${own_team_id}     convert to integer    ${own_team_id}
    Swap the position of players of team ${own_team_id} in a current scoring period and validate the response

As a team owner move any lineup Player to Bench in current scoring period
    [Tags]    to-moveplayers-to-bench-current-scoring-period  valid   CSEAUTO-28347   CSEAUTO-28395
    ${own_team_id}     convert to integer    ${own_team_id}
    Move any lineup player to bench of ${own_team_id} in current scoring and validate the response


As a team owner move any Player from Bench to LineUp in current scoringperiod
    [Tags]    to-moveplayers-from-bench-to-lineup-current-scoring-period  valid   CSEAUTO-28630   CSEAUTO-28640
    ${own_team_id}     convert to integer    ${own_team_id}
    Move the eligible Bench Player of ${own_team_id} to lineup in current scoring and validate the response

As a team owner move the Players by swaping the position of the players in future scoring period
    [Tags]    to-swap-players-future-scoring-period    valid  CSEAUTO-28630  CSEAUTO-28646
    ${own_team_id}     convert to integer    ${own_team_id}
    ${to-swap-players-future-scoring-period_response}     Swap the position of players of ${own_team_id} in future scoring period and validate the response schema
    Validate players changed their positions    ${to-swap-players-future-scoring-period_response}

As a team owner move any lineup Player to Bench in future scoring period
    [Tags]    to-owner-moveplayers-to-bench-future-scoring-period  valid   CSEAUTO-28630   CSEAUTO-28649
    ${own_team_id}     convert to integer    ${own_team_id}
    ${to-moveplayers-to-bench-future-scoring-period_response}     Move any lineup player to bench of ${own_team_id} in future scoring period and validate the response schema
    Validate player is moved to bench ${to-moveplayers-to-bench-future-scoring-period_response}

As a team owner move any Player from Bench to LineUp in future scoringperiod
    [Tags]     to-owner-moveplayers-from-bench-to-lineup-future-scoring-period    valid    CSEAUTO-28630    CSEAUTO-28651
    ${own_team_id}     convert to integer    ${own_team_id}
    ${to-moveplayers-from-bench-to-lineup-future-scoring-period_response}     Move the eligible Bench Player of ${own_team_id} to lineup in future scoring period and validate the response schema
    Validate players changed their positions    ${to-moveplayers-from-bench-to-lineup-future-scoring-period_response}

As a League manager swap the position of players of any team in a league in current scoring period
    [Tags]    lm-swap-players-current-scoring-period    valid  CSEAUTO-28347  CSEAUTO-28392
    ${team_id}      Get any different team_id
    Swap the position of players of team ${team_id} in a current scoring period and validate the response


As a League manager move any lineup Player to Bench of any team in a league in current scoring period
    [Tags]    lm-moveplayers-to-bench-current-scoring-period  valid   CSEAUTO-28630   CSEAUTO-28641
    ${team_id}      Get any different team_id
     Move any lineup player to bench of ${team_id} in current scoring and validate the response

As a League manager move any Player from Bench to LineUp of any team in a league in current scoringperiod
    [Tags]    lm-moveplayers-from-bench-to-lineup-current-scoring-period  valid   CSEAUTO-28630  CSEAUTO-28644
    ${team_id}      Get any different team_id
    Move the eligible Bench Player of ${team_id} to lineup in current scoring and validate the response

As a League manager swap the position of players of any team in a league in future scoring period
    [Tags]    lm-swap-players-future-scoring-period    valid  CSEAUTO-28630  CSEAUTO-28652
    ${team_id}      Get any different team_id
    ${lm-swap-players-future-scoring-period_response}     Swap the position of players of ${team_id} in future scoring period and validate the response schema
    Validate players changed their positions    ${lm-swap-players-future-scoring-period_response}

As a League manager move any lineup Player to Bench of any team in a league in future scoring period
    [Tags]    lm-moveplayers-to-bench-future-scoring-period  valid   CSEAUTO-28630   CSEAUTO-28653
    ${team_id}      Get any different team_id
    ${lm-moveplayers-to-bench-future-scoring-period_response}     Move any lineup player to bench of ${team_id} in future scoring period and validate the response schema
    Validate player is moved to bench ${lm-moveplayers-to-bench-future-scoring-period_response}

As a League manager move any Player from Bench to LineUp of any team in a league in future scoringperiod
    [Tags]     lm-moveplayers-from-bench-to-lineup-future-scoring-period valid   CSEAUTO-28630   CSEAUTO-28654
    ${team_id}      Get any different team_id
    ${lm-moveplayers-from-bench-to-lineup-future-scoring-period_response}     Move the eligible Bench Player of ${team_id} to lineup in future scoring period and validate the response schema
    Validate players changed their positions     ${lm-moveplayers-from-bench-to-lineup-future-scoring-period_response}






