*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: python3 -m robot testsuite/fantasy-add-player-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem
Resource            testsuite/sel-based-login.robot
Suite Setup         Get user cookie
Suite Teardown      Browser Shutdown

*** Test Cases ***
Add and drop a player in my team as a Team Owner
    [Documentation]     Simple validation of the base level schema url and 'adding and dropping' player in my team as a Team Owner for Fantasy Games API.
    [Tags]    valid    fantasy_games    CSEAUTO-28331    CSEAUTO-28388
    Fetch scoring period id for team    1
    @{player_details}      Get the value of Drop Player Id and Free Agent Player Id of Team    1
    &{initial_payload}=    Load JSON from file    resource/JSON/addDropPlayerasTO.json
    ${final_payload}       Update payload ${initial_payload} with ${scoring_period_id}, ${player_details}[0] and ${player_details}[1]
    ${response}=           A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} with ${final_payload} to add and drop a player should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

Add and drop a player in my team as a League Manager
    [Documentation]     Simple validation of the base level schema url and 'adding and dropping' player in my team as a League Manager for Fantasy Games API.
    [Tags]    valid   fantasy_games    CSEAUTO-28331    CSEAUTO-28388
    Fetch scoring period id for team    1
    @{player_details}      Get the value of Drop Player Id and Free Agent Player Id of Team     1
    &{initial_payload}=    Load JSON from file    resource/JSON/addDropPlayerasLM.json
    ${final_payload}    As League Manager, Update payload ${initial_payload} with ${scoring_period_id}, ${player_details}[0] and ${player_details}[1] for team id 1
    ${response}=    A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} with ${final_payload} to add and drop a player as LM should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

As a Fantasy League Manager, add and drop a player to other team
    [Documentation]     Simple validation of the base level schema url and 'adding and dropping' player in other team as a League Manager for Fantasy Games API.
    [Tags]    valid   fantasy_games    CSEAUTO-28331    CSEAUTO-28388
    Fetch scoring period id for team    5 
    @{player_details}      Get the value of Drop Player Id and Free Agent Player Id of Team     5
    &{initial_payload}=    Load JSON from file    resource/JSON/addDropPlayerasLM.json
    ${final_payload}    As League Manager, Update payload ${initial_payload} with ${scoring_period_id}, ${player_details}[0] and ${player_details}[1] for team id 5
    ${response}=    A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} with ${final_payload} to add and drop a player as LM should respond with 200
    Validate players are added and dropped from ${response}
    Add Player Schema from ${response} should be valid

Drop and add a player in my team as a Team Owner
    [Documentation]     Simple validation of the base level schema url and 'dropping and then adding' a player in my team as a Team Owner for Fantasy Games API.
    [Tags]    valid   fantasy_games    CSEAUTO-28331    CSEAUTO-28388
    ${drop_player_response}=    A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} drop a player from my team should respond with 200
    ${add_player_response}=     A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} add a player to my team should respond with 200
    Add Player Schema from ${drop_player_response} should be valid
    Add Player Schema from ${add_player_response} should be valid
    Validate player is dropped from my team from ${drop_player_response}
    Validate player is added to my team from ${add_player_response}

Drop and add a player in other team as a League Manager
    [Documentation]     Simple validation of the base level schema url and 'dropping and then adding' a player in my team as a Team Owner for Fantasy Games API.
    [Tags]    valid   fantasy_games    CSEAUTO-28331    CSEAUTO-28388
    ${drop_player_as_LM_response}=    A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} drop a player from other team as LM should respond with 200
    ${add_player_as_LM_response}=     A POST request to ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} add a player to other team as LM should respond with 200
    Add Player Schema from ${drop_player_as_LM_response} should be valid
    Add Player Schema from ${add_player_as_LM_response} should be valid
    Validate player is dropped from my team from ${drop_player_as_LM_response}
    Validate player is added to my team from ${add_player_as_LM_response}

As a Team Owner, I should not be able to add a new player in my team, if my roaster is full.
    [Documentation]     Simple validation of the base level schema url and 'dropping and then adding' a player in my team as a Team Owner for Fantasy Games API.
    [Tags]    valid   fantasy_games    CSEAUTO-29016    CSEAUTO-28388
    ${free_agent_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} not to add a player to my team if my roaster is full should respond with 409
    Validate player is not added to my team from ${free_agent_response} and message

As a Team Owner, I should not be able to add more than 4 players at 'Position C' in my team.
    [Documentation]     Simple validation of the base level schema url and 'dropping and then adding' a player in my team as a Team Owner for Fantasy Games API.
    [Tags]    valid   fantasy_games    CSEAUTO-29016    CSEAUTO-28388
    ${free_agent_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add a player at position C to my team should respond with 409
    Validate Position C player is not added to my team from ${free_agent_response} and message
