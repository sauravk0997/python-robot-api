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
${TEAM_ID}               1
${TRANSACTION_PARAMS}    apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}/transactions/                 
${TEAM_API}              ${API_BASE}/apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav&rosterForTeamId=${TEAM_ID}
${USER_COOKIE}           SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;

*** Keywords ***
Fetch scoring period id
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${teams_response}=    GET  url=${TEAM_API}     headers=${header}      expected_status=200
    ${scoring_period_id}=    Get value from JSON    ${teams_response.json()}    $.scoringPeriodId
    Set Global Variable    ${scoring_period_id}

Get the value of Scoring Period Id, Drop Player Id and Free Agent Playre Id of Player 
    [Documentation]     Fetching the player that going to drop from user's team and sending it to json file
    ${Free_Agent_Json}   Load JSON from file   resource/FIilterFreeAgent.json
    ${save_scoring_periodId}    Update value to JSON    ${Free_Agent_Json}    $.players.filterRanksForScoringPeriodIds.value[0]    ${scoring_period_id}
    Save JSON to file    ${save_scoring_periodId}  resource/FIilterFreeAgent.json    
    ${Free_Agent_Filter}    Get File   resource/FIilterFreeAgent.json
    &{Free_Agent_header}=   Create Dictionary    cookie=${USER_COOKIE}    x-fantasy-filter=${Free_Agent_Filter}
    ${free_agent_response}=    GET  url= ${API_BASE}/apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}?scoringPeriodId=${scoring_period_id}&view=kona_player_info     headers=${Free_Agent_header}      expected_status=200
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${team_response}=    GET  url=${TEAM_API}     headers=${header}      expected_status=200 
    @{Player_details}    Get the scoring period Id, drop player Id and free agent player Id    ${TEAM_ID}    ${team_response}    ${free_agent_response}
    Set Global Variable    @{Player_details}
    [Return]    @{Player_details}
    
Update payload ${payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${Player_details}[0]
    Save JSON to file    ${scoring_period_id_updated}    resource/AddPlayer.json    2
    ${drop_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${Player_details}[1]
    Save JSON to file    ${drop_player_id_updated}    resource/AddPlayer.json    2
    ${free_agents_player_id_updated}    Update value to JSON    ${payload}    $.items[0].playerId  ${Player_details}[2]
    Save JSON to file    ${free_agents_player_id_updated}    resource/AddPlayer.json    2
    [Return]    ${payload}
     
A POST request to ${endpoint} with ${payload} add and drop a player should respond with ${status}
    [Documentation]     add a player as a Team Owner in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}

Validate players are added and dropped from ${api_response}
    [Documentation]    whenever we add players position then player1's "fromTeamId" will be equal to player2's "toTeamId" or player1's "toTeamId" will be equal to player2's "fromTeamId"
    ${player1s_fromTeamId}  Get value from JSON     ${api_response.json()}       $.items[0].fromTeamId    
    ${player2s_toTeamId}    Get value from JSON     ${api_response.json()}       $.items[1].toTeamId  
    ${player1s_toTeamId}  Get value from JSON      ${api_response.json()}        $.items[0].toTeamId    
    ${player2s_fromTeamId}    Get value from JSON     ${api_response.json()}     $.items[1].fromTeamId   
    should be equal as integers    ${player1s_fromTeamId}    ${player2s_toTeamId}
    Should Be Equal As Integers    ${player1s_toTeamId}      ${player2s_fromTeamId}

As League Manager, Update payload ${payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${Player_details}[0]
    Save JSON to file    ${scoring_period_id_updated}    resource/AddPlayerLM.json    2
    ${drop_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${Player_details}[1]
    Save JSON to file    ${drop_player_id_updated}    resource/AddPlayerLM.json    2
    ${free_agents_player_id_updated}    Update value to JSON    ${payload}    $.items[0].playerId  ${Player_details}[2]
    Save JSON to file    ${free_agents_player_id_updated}    resource/AddPlayerLM.json    2
    [Return]    ${payload}

A POST request to ${endpoint} with ${payload} add and drop a player as LM should respond with ${status}
    [Documentation]     add and drop a player as a League Manager in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}

As League manager, Validate players are added and dropped from ${api_response} in my team
    [Documentation]    whenever we add players position then player1's "fromTeamId" will be equal to player2's "toTeamId" or player1's "toTeamId" will be equal to player2's "fromTeamId"
    ${player1s_fromTeamId}  Get value from JSON     ${api_response.json()}       $.items[0].fromTeamId    
    ${player2s_toTeamId}    Get value from JSON     ${api_response.json()}       $.items[1].toTeamId  
    ${player1s_toTeamId}  Get value from JSON      ${api_response.json()}        $.items[0].toTeamId    
    ${player2s_fromTeamId}    Get value from JSON     ${api_response.json()}     $.items[1].fromTeamId   
    should be equal as integers    ${player1s_fromTeamId}    ${player2s_toTeamId}
    Should Be Equal As Integers    ${player1s_toTeamId}      ${player2s_fromTeamId}