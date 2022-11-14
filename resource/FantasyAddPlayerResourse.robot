*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             DateTime   

Library             ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM       

*** Variables ***

${API_BASE}=       https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/     

             #https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/season_id/segments/segment_id/leagues/league_id/transactions/
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         saurav.kumar@zucitech.com
${password}     Saurav@1103
${greeting}     Saurav!
${myTeamPlayer_url}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav&rosterForTeamId=1
${AllTeamPlayer_url}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?scoringPeriodId=23&view=kona_player_info


#${espn_cookie}

*** Keywords ***
Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    Log To Console    ${espn_cookie}
    Set Global Variable     ${espn_cookie}
    #SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;

A GET request to ${endpoint} get list of all my team players respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    GET  url=${endpoint}     headers=${header}      expected_status=${status}    
    [Return]    ${api_response}


A GET request to ${endpoint} get list of all the players respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    GET  url=${endpoint}     headers=${header}      expected_status=${status}           
    [Return]    ${api_response}




A POST request to ${endpoint} add player to my team as a TO should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    
    ${payload}=  Get File  resource/AddPlayer.json
    ${data}=     Evaluate    json.loads('''${payload}''')   
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${data}     expected_status=${status}           
    [Return]    ${api_response}

A POST request to ${endpoint} add player to my team as a LM should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    
    ${payload}=  Get File  resource/AddPlayerLM.json
    ${data}=     Evaluate    json.loads('''${payload}''')   
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${data}     expected_status=${status}           
    [Return]    ${api_response}

To fetch the list of playerid from my team ${endpoint}
    [Documentation]     Custom GET keyword with status validation.
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    GET    url=${endpoint}     headers=${header}   
    @{Player_list}     Create list  
    FOR    ${i}    IN    ${api_response}.get(picks)
        FOR    ${j}    ${k}    IN    ${i}.items()
            IF    ${j} == 'playerId'
                Append To List  @Player_list  ${j}   
            END       
        END
        log    @Player_list
    END
    [Return]     @Player_list


To fetch the list of playerId from unroasted list ${endpoint}
    [Documentation]     Custom GET keyword with status validation.
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    ${api_response}=    GET  url=${endpoint}     headers=${header} 
    @{Player_list_ur} Create list  
    FOR    ${i}    IN    ${api_response}.get(players)
        FOR    ${j}    ${k}    IN    ${i}.items()
            Append To List  @Player_list  ${j}
                   
        END
        
    END
    [Return]     @Player_list_ur



# Validate ${links} should respond with ${status}
#     [Documentation]     Custom GET keyword with status validation.
#     FOR    ${link}    IN    @{links}
#         A GET request to ${link} should respond with 200   
#     END