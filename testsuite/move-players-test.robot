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

*** Test Cases ***
Move the Players by swaping the position of the players
    [Tags]    swap-players  valid CSEAUTO-28392
    Create a League
    Start offline draft
    Add players to a team
    Save the added players to the team
    ${swapped_response}    Swap the position of players and validate the response schema
    Validate players swapped their positions ${swapped_response}

Move the Players to Bench
    [Tags]    moveplayers-to-bench  valid  CSEAUTO-28395
    ${move_to_bench_response}     Move any player to bench and validate the response schema
    Validate player is moved to bench ${move_to_bench_response}