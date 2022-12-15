*** Settings ***
Documentation        Moving players form a fantasy league Positive tests are executing along with schema validation
...                  to run: robot --pythonpath $PWD ./testsuite/fantasy-league-move-players-test.robot
Metadata             Author      Yusuf Mubarak M
Metadata             Date        14-11-2022
Library              RequestsLibrary
Library              Collections
Library              OperatingSystem
Library              RPA.JSON
Resource             resource/FantasyMovePlayer.Resource
Resource             resource/suite_setup_teardown_moveplayer.resource
Library              lib/validators/FantasyMovePlayerValidator.py
Suite Setup          Create a account and a league
Suite Teardown       Delete League and Account

*** Variables ***
${own_team_id}            1

*** Test Cases ***
As a team owner move the Players by swaping the position of the players in current scoring period
    [Tags]    moveplayers    valid  CSEAUTO-28347  CSEAUTO-28392
    ${own_team_id}     convert to integer    ${own_team_id}
    Swap the position of players of team ${own_team_id} in a current scoring period and validate the response

As a team owner move any lineup Player to Bench in current scoring period
    [Tags]    moveplayers  valid   CSEAUTO-28347   CSEAUTO-28395
    ${own_team_id}     convert to integer    ${own_team_id}
    Move any lineup player to bench of ${own_team_id} in current scoring and validate the response

As a team owner move any Player from Bench to LineUp in current scoringperiod
    [Tags]    moveplayers valid   CSEAUTO-28630   CSEAUTO-28640
    ${own_team_id}     convert to integer    ${own_team_id}
    Move the eligible Bench Player of ${own_team_id} to lineup in current scoring and validate the response

As a team owner move the Players by swaping the position of the players in future scoring period
    [Tags]    moveplayers    valid  CSEAUTO-28630  CSEAUTO-28646
    ${own_team_id}     convert to integer    ${own_team_id}
    Swap the position of players of team ${own_team_id} in a future scoring period and validate the response

As a team owner move any lineup Player to Bench in future scoring period
    [Tags]    moveplayers valid   CSEAUTO-28630   CSEAUTO-28649
    ${own_team_id}     convert to integer    ${own_team_id}
    Move any lineup player to bench of ${own_team_id} in future scoring and validate the response

As a team owner move any Player from Bench to LineUp in future scoringperiod
    [Tags]     moveplayers   valid    CSEAUTO-28630    CSEAUTO-28651
    ${own_team_id}     convert to integer    ${own_team_id}
    Move the eligible Bench Player of ${own_team_id} to lineup in future scoring and validate the response

As a League manager swap the position of players of any team in a league in current scoring period
    [Tags]    lm-swap-players-current-scoring-period    valid  CSEAUTO-28347  CSEAUTO-28392
    ${team_id}      Get any different team_id
    Swap the position of players of team ${team_id} in a current scoring period and validate the response

As a League manager move any lineup Player to Bench of any team in a league in current scoring period
    [Tags]    moveplayers  valid   CSEAUTO-28630   CSEAUTO-28641
     ${team_id}      Get any different team_id
     Move any lineup player to bench of ${team_id} in current scoring and validate the response

As a League manager move any Player from Bench to LineUp of any team in a league in current scoringperiod
    [Tags]   moveplayers valid   CSEAUTO-28630  CSEAUTO-28644
    ${team_id}      Get any different team_id
    Move the eligible Bench Player of ${team_id} to lineup in current scoring and validate the response

As a League manager swap the position of players of any team in a league in future scoring period
    [Tags]    moveplayers    valid  CSEAUTO-28630  CSEAUTO-28652
    ${team_id}      Get any different team_id
    Swap the position of players of team ${team_id} in a future scoring period and validate the response

As a League manager move any lineup Player to Bench of any team in a league in future scoring period
    [Tags]    moveplayers  valid   CSEAUTO-28630   CSEAUTO-28653
    ${team_id}      Get any different team_id
    Move any lineup player to bench of ${team_id} in future scoring and validate the response

As a League manager move any Player from Bench to LineUp of any team in a league in future scoringperiod
    [Tags]     moveplayers valid   CSEAUTO-28630   CSEAUTO-28654
    ${team_id}      Get any different team_id
    Move the eligible Bench Player of ${team_id} to lineup in future scoring and validate the response

As a team owner move the player to the same slot
    [Tags]  moveplayers    Invalid     CSEAUTO-29018       CSEAUTO-29062
    ${own_team_id}           convert to integer    ${own_team_id}
    Move any Player of team ${own_team_id} to same slot and validate the response

As a team owner move the player to any ineligible slot
    [Tags]  moveplayers   Invalid     CSEAUTO-29018       CSEAUTO-29063
    ${own_team_id}           convert to integer    ${own_team_id}
    Move any Player of team ${own_team_id} to ineligible slot and validate the response

As a team owner move the player in a current scoring period by providing incorrect type in json payload
    [Tags]  moveplayers   Invalid     CSEAUTO-29018       CSEAUTO-29065
    ${own_team_id}           convert to integer    ${own_team_id}
    Move any Player of team ${own_team_id} in a current scoring period by providing incorrect type in json payload and validate the response

As a team owner move the player in a future scoring period by providing incorrect type in json payload
    [Tags]  moveplayers    Invalid     CSEAUTO-29018       CSEAUTO-29066
    ${own_team_id}           convert to integer    ${own_team_id}
    Move any Player of team ${own_team_id} in a future scoring period by providing incorrect type in json payload and validate the response

As a team owner move the player not available on the team
    [Tags]  moveplayers    Invalid     CSEAUTO-29018       CSEAUTO-29071
    ${own_team_id}           convert to integer    ${own_team_id}
    Move the player not available on team ${own_team_id} and validate the response

As a team owner move the player of any other team
    [Tags]  moveplayers   Invalid     CSEAUTO-29018       CSEAUTO-29075
    ${own_team_id}       convert to integer    ${own_team_id}
    Move the players of any team ${own_team_id} as a team owner and validate the response

As a team owner move the player to an invalid team
    [Tags]  moveplayers   Invalid     CSEAUTO-29018       CSEAUTO-29126
    ${own_team_id}      convert to integer    ${own_team_id}
    Move any player to an invalid team ${own_team_id} and validate the response

As a team owner move players to an invalid slot
    [Tags]  moveplayers   Invalid     CSEAUTO-29018       CSEAUTO-29064
    ${own_team_id}      convert to integer    ${own_team_id}
    Move any player of team ${own_team_id} to invalid slot and validate the response

As a team owner move the invalid player
    [Tags]  moveplayers   Invalid     CSEAUTO-29018       CSEAUTO-29077
    ${own_team_id}      convert to integer    ${own_team_id}
    Move any invalid player to team ${own_team_id} and validate the response