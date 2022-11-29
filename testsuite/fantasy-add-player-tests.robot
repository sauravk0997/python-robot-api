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
    @{Player_details}    Get the value of Drop Player Id and Free Agent Player Id of Player    1
    &{initial_payload}=    Load JSON from file    resource/AddPlayer.json
    ${final_payload}    Update payload ${initial_payload} with ${scoring_period_id}, ${Player_details}[0] and ${Player_details}[1]
    ${response}=    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} with ${final_payload} add and drop a player should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

Add and drop a player to my team as a League Manager
    [Documentation]     Simple validation of the base level schema url and adding player as a LM for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    Fetch scoring period id 
    @{Player_details}      Get the value of Drop Player Id and Free Agent Player Id of Player     1
    &{initial_payload}=    Load JSON from file    resource/AddPlayerLM.json
    ${final_payload}    As League Manager, Update payload ${initial_payload} with ${scoring_period_id}, ${Player_details}[0] and ${Player_details}[1] for team id 1
    ${response}=    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} with ${final_payload} add and drop a player as LM should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

As a Fantasy League Manager, add and drop a player to other team
    [Documentation]     Simple validation of the base level schema url and adding player as a LM for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    Fetch scoring period id 
    @{Player_details}      Get the value of Drop Player Id and Free Agent Player Id of Player     5
    &{initial_payload}=    Load JSON from file    resource/AddPlayerLM.json
    ${final_payload}    As League Manager, Update payload ${initial_payload} with ${scoring_period_id}, ${Player_details}[0] and ${Player_details}[1] for team id 5
    ${response}=    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} with ${final_payload} add and drop a player as LM should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

Drop and add a player 
    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} drop a player from my team should respond with 200
    A POST request to ${API_BASE}/${TRANSACTION_PARAMS} add a player to my team should respond with 200