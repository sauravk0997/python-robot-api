*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             String
Library             DateTime   
Library             RPA.JSON
Library             lib/validators/FantasyAddPlayerValidator.py

*** Variables ***
${League_id}             748489070
${season_id}             2023
${API_BASE}              https://lm-api-writes.fantasy.espn.com
${transaction_params}    apis/v3/games/fba/seasons/${season_id}/segments/0/leagues/${League_id}/transactions/                 
${myTeamPlayer_url}      https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav&rosterForTeamId=1
${AllFreeAgent_url}      https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?scoringPeriodId=23&view=kona_player_info
${espn_cookie}           SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;

*** Keywords ***
Fetching the FREE AGENT player
    [Documentation]     Fetching the player that going to add from free agent and sending it to json file
    &{header}=   Create Dictionary    cookie=${espn_cookie}
    ${FreeAgent_response}=    GET  url=${AllFreeAgent_url}     headers=${header}      expected_status=200 
    ${random}   generate random string    1    0123456789
    ${add_player}   get value from json    ${FreeAgent_response.json()}     $.players[${random}].id 
    &{add_player_payload}=    Load JSON from file    resource/AddPlayer.json
    ${save_add_player}    Update value to JSON    ${add_player_payload}    $.items[0].playerId  ${add_player}
    Save JSON to file    ${save_add_player}  resource/AddPlayer.json

Fetching the DropPlayerId and spid of Player 
    [Documentation]     Fetching the player that going to drop from user's team and sending it to json file
    &{header}=   Create Dictionary    cookie=${espn_cookie}
    ${MyTeam_response}=    GET  url=${myTeamPlayer_url}     headers=${header}      expected_status=200 
    ${spid}    ${playerid}    Fetching droppable player        ${MyTeam_response}
    [Return]    ${spid}    ${playerid}
    
Update payload ${payload} with ${playerid} and ${spid}
    [Documentation]     Custom keyword to update the payload with the values from API calls
    Set To Dictionary   ${payload["items"][1]}    playerId=${playerid}
    Set To Dictionary   ${payload}    scoringPeriodId    ${spid}
    set global variable    ${payload}
    [Return]    ${payload}
     
A POST request to ${endpoint} with ${payload} add a player should respond with ${status}
    [Documentation]     add a player as a Team Owner in my team
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${payload}     expected_status=${status}           
    [Return]    ${api_response}

Validate ${api_response} to check whether the players is added
    [Documentation]    whenever we add players position then player1's "fromTeamId" will be equal to player2's "toTeamId" or player1's "toTeamId" will be equal to player2's "fromTeamId"
    ${Player1s_fromTeamId}  Get value from JSON     ${api_response.json()}       $.items[0].fromTeamId    
    ${Player2s_toTeamId}    Get value from JSON     ${api_response.json()}       $.items[1].toTeamId  
    ${Player1s_toTeamId}  Get value from JSON      ${api_response.json()}        $.items[0].toTeamId    
    ${Player2s_fromTeamId}    Get value from JSON     ${api_response.json()}     $.items[1].fromTeamId   
    should be equal as integers    ${Player1s_fromTeamId}    ${Player2s_toTeamId}
    Should Be Equal As Integers    ${Player1s_toTeamId}      ${Player2s_fromTeamId}