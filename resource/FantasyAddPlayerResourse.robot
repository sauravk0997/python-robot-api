*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             String
Library             DateTime   
Library             RPA.JSON
Library             lib/validators/FantasyAddPlayerValidator.py

*** Variables ***
${LEAGUE_ID}             748489070 
${SEASON_ID}             2023
${API_BASE}              https://fantasy.espn.com
${TRANSACTION_PARAMS}    apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}/transactions/                 
${TEAM_API}              ${API_BASE}/apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav&rosterForTeamId
${USER_COOKIE}           SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;

*** Keywords ***
Fetch scoring period id
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${teams_response}=    GET  url=${TEAM_API}     headers=${header}      expected_status=200
    ${scoring_period_id}=    Get value from JSON    ${teams_response.json()}    $.scoringPeriodId
    # declaring scoring period id as global to update its value in url and json, to use it in different function
    Set Global Variable    ${scoring_period_id}

Get the value of Drop Player Id and Free Agent Player Id of Player 
    [Arguments]    ${team-id} 
    [Documentation]     Custom keyword for getting the drop player id and free agent player id from reaponse
    # Updating free agent URL and free agent json with current scoring period id
    ${free_agent_json}   Load JSON from file   resource/freeAgentFilter.json
    ${save_scoring_periodId}    Update value to JSON    ${free_agent_json}    $.players.filterRanksForScoringPeriodIds.value[0]    ${scoring_period_id}
    Save JSON to file    ${save_scoring_periodId}  resource/freeAgentFilter.json    
    # ${free_agent_filter}    Get File   resource/freeAgentFilter.json
    ${free_agent_filter}    Get file   resource/freeAgentFilter.json
    &{free_agent_header}=   Create Dictionary    cookie=${USER_COOKIE}    x-fantasy-filter=${free_agent_filter}
    ${free_agent_response}=    GET  url= ${API_BASE}/apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}?scoringPeriodId=${scoring_period_id}&view=kona_player_info     headers=${free_agent_header}      expected_status=200
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${team_response}=    GET  url=${TEAM_API}=${team-id}    headers=${header}      expected_status=200 
    # Storing drop player id and free agent id in the list (player details)
    @{Player_details}    Get the droppable player and free-agent player id    ${team-id}    ${team_response}    ${free_agent_response}
    # Setting player details list as global so that it can be used in test case
    Set Global Variable    @{Player_details}
    [Return]    @{Player_details}
    
Update payload ${payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${scoring_period_id_updated}    resource/AddPlayer.json    2
    ${droppable_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${Player_details}[0]
    Save JSON to file    ${droppable_player_id_updated}    resource/AddPlayer.json    2
    ${free_agents_player_id_updated}    Update value to JSON    ${payload}    $.items[0].playerId  ${Player_details}[1]
    Save JSON to file    ${free_agents_player_id_updated}    resource/AddPlayer.json    2
    [Return]    ${payload}
     
A POST request to ${endpoint} with ${payload} add and drop a player should respond with ${status}
    [Documentation]     Post request for adding and dropping a player as a Team Owner in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}

Validate players are added and dropped from ${api_response}
    [Documentation]    Validation to check whether player is added and dropped in my team
    # whenever we add players position then player1's "fromTeamId" will be equal to player2's "toTeamId" or player1's "toTeamId" will be equal to player2's "fromTeamId"
    ${player1s_fromTeamId}  Get value from JSON     ${api_response.json()}       $.items[0].fromTeamId    
    ${player2s_toTeamId}    Get value from JSON     ${api_response.json()}       $.items[1].toTeamId  
    ${player1s_toTeamId}  Get value from JSON      ${api_response.json()}        $.items[0].toTeamId    
    ${player2s_fromTeamId}    Get value from JSON     ${api_response.json()}     $.items[1].fromTeamId   
    should be equal as integers    ${player1s_fromTeamId}    ${player2s_toTeamId}
    Should Be Equal As Integers    ${player1s_toTeamId}      ${player2s_fromTeamId}

As League Manager, Update payload ${payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id} for team id ${TEAM_ID}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${scoring_period_id_updated}    resource/AddPlayerLM.json    2
    ${droppable_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${Player_details}[0]
    Save JSON to file    ${droppable_player_id_updated}    resource/AddPlayerLM.json    2
    ${free_agents_player_id_updated}    Update value to JSON    ${payload}    $.items[0].playerId  ${Player_details}[1]
    Save JSON to file    ${free_agents_player_id_updated}    resource/AddPlayerLM.json    2
    ${team_id_updated_1}    Update value to JSON    ${payload}    $.teamId     ${TEAM_ID}
    Save JSON to file    ${team_id_updated_1}    resource/AddPlayerLM.json    2
    ${team_id_updated_2}    Update value to JSON    ${payload}    $.items[0].toTeamId     ${TEAM_ID}
    Save JSON to file    ${team_id_updated_2}    resource/AddPlayerLM.json    2
    ${team_id_updated_3}    Update value to JSON    ${payload}    $.items[1].fromTeamId   ${TEAM_ID}
    Save JSON to file    ${team_id_updated_3}    resource/AddPlayerLM.json    2
    [Return]    ${payload}

A POST request to ${endpoint} with ${payload} add and drop a player as LM should respond with ${status}
    [Documentation]     Post request for adding and dropping a player as a League Manager in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}

Drop a player from my team
    Fetch scoring period id
    ${save_scoringPeriodId}    Update value to JSON    ${drop_payload}    $..scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${save_scoringPeriodId}  resource/droppablePlayer.json     2 
    Get the value of Drop Player Id and Free Agent Player Id of Player    1 
    &{drop_payload}=    Load JSON from file    resource/droppablePlayer.json
    ${droppable_players_id_updated}=    Update value to JSON    ${drop_payload}    $.items[0].playerId    ${Player_details}[0]
    Save JSON to file    ${droppable_players_id_updated}    resource/droppablePlayer.json    2
    Set Global Variable    ${drop_payload}

Add a player to my team
    Fetch scoring period id  
    ${save_scoringPeriodId}    Update value to JSON    ${add_payload}    $..scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${save_scoringPeriodId}  resource/addablePlayer.json    2 
    Get the value of Drop Player Id and Free Agent Player Id of Player    1 
    &{add_payload}=    Load JSON from file    resource/addablePlayer.json
    ${addable_players_id_updated}=    Update value to JSON    ${add_payload}    $.scoringPeriodId    ${Player_details}[1]
    Save JSON to file    ${addable_players_id_updated}    resource/addablePlayer.json    2
    Set Global Variable    ${add_payload}

A POST request to ${endpoint} drop a player from my team should respond with ${status}
    [Documentation]     Post request for dropping a player from my team
    Drop a player from my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${drop_payload}     expected_status=${status}           
    [Return]    ${api_response}

A POST request to ${endpoint} add a player to my team should respond with ${status}
    [Documentation]     Post request for adding a player to my team
    Add a player to my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${add_payload}     expected_status=${status}           
    [Return]    ${api_response}