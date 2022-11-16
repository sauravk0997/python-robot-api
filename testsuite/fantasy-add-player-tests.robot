*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem




*** Test Cases ***
Add a player to my team as a Team Owner
    
    [Documentation]     Simple validation of the base level schema url and adding player as a TO for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    Fetching the FREE AGENT player
    ${spid}    ${playerid}     Fetching the DropPlayerId and spid of Player
    &{initial_payload}=    Load JSON from file    resource/AddPlayer.json
    ${final_payload}    Update payload ${initial_payload} with ${playerid} and ${spid}
    ${response}=    A POST request to ${API_BASE}/${transaction_params} with ${final_payload} add a player should respond with 200
    Validate ${response} to check whether the players is added
    Fantasy Games Schema from ${response} should be valid




