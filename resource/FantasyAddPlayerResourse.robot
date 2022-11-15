*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             String
Library             DateTime   
Library             RPA.JSON

Library             ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM       
Library    Telnet

*** Variables ***

${API_BASE}      https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/                 
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         saurav.kumar@zucitech.com
${password}     Saurav@1103
${greeting}     Saurav!
${myTeamPlayer_url}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav&rosterForTeamId=1
${AllFreeAgent_url}      https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?scoringPeriodId=23&view=kona_player_info


#${espn_cookie}

*** Keywords ***
Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    Log To Console    ${espn_cookie}
    Set Global Variable     ${espn_cookie}
    #SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;

To Fetch the FREE AGENT player 

    [Documentation]     Custom GET keyword with status validation.
    &{header}=   Create Dictionary    cookie="SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;"      #cookie=${espn_cookie}
    ${FreeAgent_response}=    GET  url=${AllFreeAgent_url}     headers=${header}      expected_status=200 
    ${random}   generate random string    1    0123456789
    ${add_player}   get value from json    ${FreeAgent_response.json()}     $.players[${random}].id 
    &{add_player_payload}=    Load JSON from file    resource/AddPlayer.json
    ${save_add_player}    Update value to JSON    ${add_player_payload}    $.items[0].playerId  ${add_player}
    Save JSON to file    ${save_add_player}  resource/AddPlayer.json

    
To fetch the Droppable Player 
    [Documentation]     Custom GET keyword with status validation.
    &{header}=   Create Dictionary    cookie="SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;"      #cookie=${espn_cookie}
    ${MyTeam_response}=    GET  url=${myTeamPlayer_url}     headers=${header}      expected_status=200  
    ${random}   generate random string    1    0123456789
    #IF    "$.teams[0].roster.entries[${random}].playerPoolEntry.player.droppable" == "True"
    ${drop_player}   get value from json    ${MyTeam_response.json()}     $.teams[0].roster.entries[7].playerPoolEntry.player.id
    &{drop_player_payload}=    Load JSON from file    resource/AddPlayer.json
    ${save_drop_player}    Update value to JSON    ${drop_player_payload}    $.items[1].playerId  ${drop_player}
    Save JSON to file    ${save_drop_player}  resource/AddPlayer.json
    
        
    #END
    

To Fetch scoringPeriodId for the player
    [Documentation]     Custom GET keyword with status validation.
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    ${spid_response}=    GET  url=${myTeamPlayer_url}  headers=${headers}   expected_status=200
    
    ${spid}   get value from json    ${spid_response.json()}     $.scoringPeriodId
    &{spid_payload}=    Load JSON from file    resource/AddPlayer.json
    ${save_spid}    Update value to JSON    ${spid_payload}    $.scoringPeriodId  ${spid}
    Save JSON to file    ${save_spid}  resource/AddPlayer.json
    
   
A POST request to ${endpoint} add a player should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    
    ${payload}=  Get File  resource/AddPlayer.json
    ${data}=     Evaluate    json.loads('''${payload}''')   
    &{header}=   Create Dictionary      cookie="SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;"    #cookie=${espn_cookie}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${data}     expected_status=${status}           
    [Return]    ${api_response}

A POST request to ${endpoint} add player as LM should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    
    ${payload}=  Get File  resource/AddPlayerLM.json
    ${data}=     Evaluate    json.loads('''${payload}''')   
    &{header}=   Create Dictionary       cookie="SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;"   #cookie=${espn_cookie}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${data}     expected_status=${status}           
    [Return]    ${api_response}

