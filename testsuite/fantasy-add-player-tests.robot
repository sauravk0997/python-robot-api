*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem

*** Test Cases ***
Add and drop a player to my team as a Team Owner
    [Documentation]     Simple validation of the base level schema url and adding player as a TO for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    Fetch scoring period id 
    ${scoring_period_id}    ${drop_player_id}    ${free_agents_id}     Get the value of Scoring Period Id, Drop Player Id and Free Agent Playre Id of Player 
    &{initial_payload}=    Load JSON from file    resource/AddPlayer.json
    ${final_payload}    Update payload ${initial_payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id}
    ${response}=    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} with ${final_payload} add and drop a player should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

Add and drop a player to my team as a League Manager
    [Documentation]     Simple validation of the base level schema url and adding player as a TO for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    Fetch scoring period id 
    ${scoring_period_id}    ${playerid}    ${free_agents_id}     Get the value of Scoring Period Id, Drop Player Id and Free Agent Playre Id of Player 
    &{initial_payload}=    Load JSON from file    resource/AddPlayerLM.json
    ${final_payload}    As League Manager, Update payload ${initial_payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id}
    ${response}=    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} with ${final_payload} add and drop a player as LM should respond with 200
    As League manager, Validate players are added and dropped from ${response} in my team
    Add Player Schema from ${response} should be valid