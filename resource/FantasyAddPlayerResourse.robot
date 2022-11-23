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

Fetching the FREE AGENT player
    [Documentation]     Fetching the player that going to add from free agent and sending it to json file
    ${Free_Agent}   Load JSON from file   resource/FIilterFreeAgent.json
    ${save_scoring_periodId}    Update value to JSON    ${Free_Agent}    $.players.filterRanksForScoringPeriodIds.value[0]    ${scoring_period_id}
    Save JSON to file    ${save_scoring_periodId}  resource/FIilterFreeAgent.json    
    ${Free_Agent_Filter}    Get File   resource/FIilterFreeAgent.json
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}    x-fantasy-filter=${Free_Agent_Filter}
    ${free_agent_response}=    GET  url= ${API_BASE}/apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}?scoringPeriodId=${scoring_period_id}&view=kona_player_info     headers=${header}      expected_status=200
    ${FreeAgent_Player_Id}    ${free_agents_position_id}    Get the free agent player id and free agent position Id    ${free_agent_response}
    &{add_player_payload}=    Load JSON from file    resource/AddPlayer.json
    ${free_agents_player_id_updated}    Update value to JSON    ${add_player_payload}    $.items[0].playerId  ${FreeAgent_Player_Id}
    Save JSON to file    ${free_agents_player_id_updated}    resource/AddPlayer.json    2
    Set Global Variable    ${FreeAgent_Player_Id}
    Set Global Variable    ${free_agents_position_id}
   

Fetching the Drop Player Id and Scoring Period Id of Player 
    [Documentation]     Fetching the player that going to drop from user's team and sending it to json file
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${team_response}=    GET  url=${TEAM_API}     headers=${header}      expected_status=200 
    ${scoring_period_id}    ${drop_player_id}    ${free_agents_player_id}    Get the scoring period Id and drop player id    ${TEAM_ID}    ${team_response}
    [Return]    ${scoring_period_id}    ${drop_player_id}    ${free_agents_player_id}
    
Update payload ${payload} with ${scoring_period_id} and ${drop_player_id}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${scoring_period_id_updated}    resource/AddPlayer.json    2
    ${drop_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${drop_player_id}
    Save JSON to file    ${drop_player_id_updated}    resource/AddPlayer.json    2
    [Return]    ${payload}
     
A POST request to ${endpoint} with ${payload} add a player should respond with ${status}
    [Documentation]     add a player as a Team Owner in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}

Validate players are added from ${api_response}
    [Documentation]    whenever we add players position then player1's "fromTeamId" will be equal to player2's "toTeamId" or player1's "toTeamId" will be equal to player2's "fromTeamId"
    ${player1s_fromTeamId}  Get value from JSON     ${api_response.json()}       $.items[0].fromTeamId    
    ${player2s_toTeamId}    Get value from JSON     ${api_response.json()}       $.items[1].toTeamId  
    ${player1s_toTeamId}  Get value from JSON      ${api_response.json()}        $.items[0].toTeamId    
    ${player2s_fromTeamId}    Get value from JSON     ${api_response.json()}     $.items[1].fromTeamId   
    should be equal as integers    ${player1s_fromTeamId}    ${player2s_toTeamId}
    Should Be Equal As Integers    ${player1s_toTeamId}      ${player2s_fromTeamId}

Fetching the FREE AGENT player as LM
    [Documentation]     Fetching the player that going to add from free agent and sending it to json file
    ${Free_Agent}   Load JSON from file   resource/FIilterFreeAgent.json
    ${save_scoring_periodId}    Update value to JSON    ${Free_Agent}    $.players.filterRanksForScoringPeriodIds.value[0]    ${scoring_period_id}
    Save JSON to file    ${save_scoring_periodId}  resource/FIilterFreeAgent.json    
    ${Free_Agent_Filter}    Get File   resource/FIilterFreeAgent.json
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}    x-fantasy-filter=${Free_Agent_Filter}
    ${free_agent_response}=    GET  url= ${API_BASE}/apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}?scoringPeriodId=${scoring_period_id}&view=kona_player_info     headers=${header}      expected_status=200
    #${rand_no}    Generate Random String    1    0123456789
    ${free_agent_playerID}=    Get value from JSON    ${free_agent_response.json()}    $.players[0].id
    ${free_agent_positionID}=    Get value from JSON    ${free_agent_response.json()}     $.players[0].player.defaultPositionId
    IF    ${free_agent_playerID} == ${None}
        Log To Console    FREE AGENTS are not Available. Please wait until waivers period has concluded
    END
    &{add_player_payload}=    Load JSON from file    resource/AddPlayerLM.json
    ${save_add_player}    Update value to JSON    ${add_player_payload}    $.items[0].playerId  ${free_agent_playerID}
    Save JSON to file    ${save_add_player}    resource/AddPlayerLM.json    2
    Set Global Variable    ${free_agent_positionID}

As League Manager, Update payload ${payload} with ${playerid} and ${scoring_period_id}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${playerid}
    Save JSON to file    ${player_id_updated}    resource/AddPlayerLM.json    2
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${scoring_period_id_updated}    resource/AddPlayerLM.json     2
    set global variable    ${payload}
    [Return]    ${payload}

A POST request to ${endpoint} with ${payload} add a player as LM should respond with ${status}
    [Documentation]     add a player as a League Manager in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}