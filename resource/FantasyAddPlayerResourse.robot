*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             String
Library             DateTime   
Library             RPA.JSON
Library             lib/validators/FantasyAddPlayerValidator.py
Library             lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/JSON/xpaths.json    WITH NAME    FLM

*** Variables ***
${LEAGUE_ID}             748489070 
${SEASON_ID}             2023
${API_BASE}              https://fantasy.espn.com
${LEAGUE_SLUG}           apis/v3/games/fba/seasons/${SEASON_ID}/segments/0/leagues/${LEAGUE_ID}
${TRANSACTION_SLUG}      transactions/             
${TEAM_API}              ${API_BASE}/${LEAGUE_SLUG}?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav&rosterForTeamId
${HOMEPAGE}              https://www.espn.com/fantasy/
${BROWSER}               Chrome
${user}                  saurav.kumar@zucitech.com
${password}              Saurav@1103
${greeting}              Saurav!


*** Keywords ***

Get user cookie
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${USER_COOKIE}=     FLM.Fantasy API Cookie
    Set Global Variable    ${USER_COOKIE}

Fetch scoring period id for team
    [Arguments]    ${team_id}
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${team_response}=    GET  url=${TEAM_API}=${team_id}      headers=${header}      expected_status=200
    ${scoring_period_id}=    Get value from JSON    ${team_response.json()}    $.scoringPeriodId
    Set Global Variable    ${scoring_period_id}

Get the value of Drop Player Id and Free Agent Player Id of Team 
    [Arguments]    ${team_id1} 
    [Documentation]     Custom keyword for getting the drop player id and free agent player id from reaponse
    ${free_agent_json}   Load JSON from file   resource/JSON/freeAgentFilter.json
    ${scoring_periodId_updated}    Update value to JSON    ${free_agent_json}    $.players.filterRanksForScoringPeriodIds.value[0]    ${scoring_period_id}
    Save JSON to file    ${scoring_periodId_updated}  resource/JSON/freeAgentFilter.json    
    ${free_agent_filter}    Get file   resource/JSON/freeAgentFilter.json
    &{free_agent_header}=   Create Dictionary    cookie=${USER_COOKIE}    x-fantasy-filter=${free_agent_filter}
    ${free_agent_response}=    GET  url= ${API_BASE}/${LEAGUE_SLUG}?scoringPeriodId=${scoring_period_id}&view=kona_player_info     headers=${free_agent_header}      expected_status=200
    &{header}=   Create Dictionary    cookie=${USER_COOKIE}
    ${team_response}=    GET  url=${TEAM_API}=${team_id1}    headers=${header}      expected_status=200 
    @{player_details}    Get the droppable player and free-agent player id    ${team_id1}    ${team_response}    ${free_agent_response}
    Set Global Variable    @{player_details}
    [Return]    @{player_details}
    
Update payload ${payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${scoring_period_id_updated}    resource/JSON/addDropPlayerasTO.json    2
    ${droppable_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${player_details}[0]
    Save JSON to file    ${droppable_player_id_updated}    resource/JSON/addDropPlayerasTO.json    2
    ${free_agents_player_id_updated}    Update value to JSON    ${payload}    $.items[0].playerId  ${player_details}[1]
    Save JSON to file    ${free_agents_player_id_updated}    resource/JSON/addDropPlayerasTO.json    2
    [Return]    ${payload}
     
A POST request to ${endpoint} with ${payload} to add and drop a player should respond with ${status}
    [Documentation]     Post request for adding and dropping a player as a Team Owner in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${response}

Validate players are added and dropped from ${response}
    [Documentation]    Validation to check whether player is added and dropped in my team
    ${player1s_fromTeamId}    Get value from JSON     ${response.json()}       $.items[0].fromTeamId    
    ${player2s_toTeamId}      Get value from JSON     ${response.json()}       $.items[1].toTeamId  
    should be equal as integers    ${player1s_fromTeamId}    ${player2s_toTeamId}
    

As League Manager, Update payload ${payload} with ${scoring_period_id}, ${drop_player_id} and ${free_agents_id} for team id ${team_ID}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    ${scoring_period_id_updated}=    Update value to JSON    ${payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${scoring_period_id_updated}    resource/JSON/addDropPlayerasLM.json    2
    ${droppable_player_id_updated}=    Update value to JSON    ${payload}    $.items[1].playerId    ${player_details}[0]
    Save JSON to file    ${droppable_player_id_updated}    resource/JSON/addDropPlayerasLM.json    2
    ${free_agents_player_id_updated}    Update value to JSON    ${payload}    $.items[0].playerId  ${player_details}[1]
    Save JSON to file    ${free_agents_player_id_updated}    resource/JSON/addDropPlayerasLM.json    2
    ${team_id_updated_1}    Update value to JSON    ${payload}    $.teamId     ${team_ID}
    Save JSON to file    ${team_id_updated_1}    resource/JSON/addDropPlayerasLM.json    2
    ${team_id_updated_2}    Update value to JSON    ${payload}    $.items[0].toTeamId     ${team_ID}
    Save JSON to file    ${team_id_updated_2}    resource/JSON/addDropPlayerasLM.json    2
    ${team_id_updated_3}    Update value to JSON    ${payload}    $.items[1].fromTeamId   ${team_ID}
    Save JSON to file    ${team_id_updated_3}    resource/JSON/addDropPlayerasLM.json    2
    [Return]    ${payload}

A POST request to ${endpoint} with ${payload} to add and drop a player as LM should respond with ${status}
    [Documentation]     Post request for adding and dropping a player as a League Manager in my team
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${response}

Drop a player from my team as TO
    Fetch scoring period id for team    1
    &{drop_payload}=    Load JSON from file    resource/JSON/dropPlayerasTO.json
    ${save_scoringPeriodId}    Update value to JSON    ${drop_payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${save_scoringPeriodId}    resource/JSON/dropPlayerasTO.json     2 
    Get the value of Drop Player Id and Free Agent Player Id of Team    1 
    ${droppable_players_id_updated}=    Update value to JSON    ${drop_payload}    $.items[0].playerId    ${player_details}[0]
    Save JSON to file    ${droppable_players_id_updated}    resource/JSON/dropPlayerasTO.json    2
    Set Global Variable    ${drop_payload}

Add a player to my team as TO
    Fetch scoring period id for team    1
    &{add_payload}=    Load JSON from file    resource/JSON/addPlayerasTO.json
    ${save_scoringPeriodId}    Update value to JSON    ${add_payload}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${save_scoringPeriodId}    resource/JSON/addPlayerasTO.json    2 
    Get the value of Drop Player Id and Free Agent Player Id of Team    1 
    ${addable_players_id_updated}=    Update value to JSON    ${add_payload}    $.items[0].playerId   ${player_details}[1]
    Save JSON to file    ${addable_players_id_updated}    resource/JSON/addPlayerasTO.json    2
    Set Global Variable    ${add_payload}

A POST request to ${endpoint} drop a player from my team should respond with ${status}
    [Documentation]     Post request for dropping a player from my team
    Drop a player from my team as TO
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${response}=    POST  url=${endpoint}     headers=${header}    json=${drop_payload}     expected_status=${status}           
    [Return]    ${response}

A POST request to ${endpoint} add a player to my team should respond with ${status}
    [Documentation]     Post request for adding a player to my team
    Add a player to my team as TO
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${response}=    POST  url=${endpoint}     headers=${header}    json=${add_payload}     expected_status=${status}           
    [Return]    ${response}

Validate player is dropped from my team from ${response}
    [Documentation]    Validation to check whether player is dropped from my team
    ${player_fromTeamId}  Get value from JSON       ${response.json()}         $.items[0].fromTeamId   
    ${player_TeamId}      Get value from JSON       ${response.json()}         $.teamId 
    Should Be Equal As Integers    ${player_fromTeamId}      ${player_TeamId}

Validate player is added to my team from ${response}
    [Documentation]    Validation to check whether player is added to my team
    ${player_toTeamId}  Get value from JSON       ${response.json()}       $.items[0].toTeamId     
    ${player_TeamId}    Get value from JSON       ${response.json()}       $.teamId   
    Should Be Equal As Integers    ${player_toTeamId}      ${player_TeamId}

As League Manager, Drop a player from other team ${team_ID}
    Fetch scoring period id for team    5
    &{drop_payload1}=    Load JSON from file    resource/JSON/dropPlayerasLM.json
    ${save_scoringPeriodId}    Update value to JSON    ${drop_payload1}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${save_scoringPeriodId}  resource/JSON/dropPlayerasLM.json     2 
    Get the value of Drop Player Id and Free Agent Player Id of Team    5 
    ${droppable_players_id_updated}=    Update value to JSON    ${drop_payload1}    $.items[0].playerId    ${player_details}[0]
    Save JSON to file    ${droppable_players_id_updated}    resource/JSON/dropPlayerasLM.json    2
    ${team_id_updated_1}    Update value to JSON    ${drop_payload1}    $.teamId     ${TEAM_ID}
    Save JSON to file    ${team_id_updated_1}    resource/JSON/dropPlayerasLM.json    2
    ${team_id_updated_2}    Update value to JSON    ${drop_payload1}    $.items[0].fromTeamId     ${TEAM_ID}
    Save JSON to file    ${team_id_updated_2}    resource/JSON/dropPlayerasLM.json    2
    Set Global Variable    ${drop_payload1}

As League Manager, Add a player to other team ${team_ID}
    Fetch scoring period id for team    5
    &{add_payload1}=    Load JSON from file    resource/JSON/addPlayerasLM.json
    ${save_scoringPeriodId}    Update value to JSON    ${add_payload1}    $.scoringPeriodId    ${scoring_period_id}
    Save JSON to file    ${save_scoringPeriodId}    resource/JSON/addPlayerasLM.json    2 
    Get the value of Drop Player Id and Free Agent Player Id of Team    5 
    ${addable_players_id_updated}=    Update value to JSON    ${add_payload1}    $.items[0].playerId   ${player_details}[1]
    Save JSON to file    ${addable_players_id_updated}    resource/JSON/addPlayerasLM.json    2
    ${team_id_updated_1}    Update value to JSON    ${add_payload1}    $.teamId     ${TEAM_ID}
    Save JSON to file    ${team_id_updated_1}    resource/JSON/addPlayerasLM.json    2
    ${team_id_updated_2}    Update value to JSON    ${add_payload1}    $.items[0].toTeamId     ${TEAM_ID}
    Save JSON to file    ${team_id_updated_2}    resource/JSON/addPlayerasLM.json    2
    Set Global Variable    ${add_payload1}

A POST request to ${endpoint} drop a player from other team as LM should respond with ${status}
    [Documentation]     Post request for dropping a player from my team
    As League Manager, Drop a player from other team 5
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${response}=    POST  url=${endpoint}     headers=${header}    json=${drop_payload1}     expected_status=${status}           
    [Return]    ${response}

A POST request to ${endpoint} add a player to other team as LM should respond with ${status}
    [Documentation]     Post request for adding a player to my team
    As League Manager, Add a player to other team 5
    &{header}=   Create Dictionary      cookie=${USER_COOKIE}
    ${response}=    POST  url=${endpoint}     headers=${header}    json=${add_payload1}     expected_status=${status}           
    [Return]    ${response}