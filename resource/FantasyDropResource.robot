*** Settings ***
Documentation       All Common robot utils/functions and variables with respect to
...                 ESPN Fantasy Games API are maintained here
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library         ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM
Library        ../lib/validators/FantasyDropValidator.py
Library    String


*** Variables ***
${TEAMS_API}=        https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav  # tests default to the sandbox environment
${PLAYERS_API}=      https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=players_wl
# ${PLAYERINFO_API}=    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?scoringPeriodId={spid}&view=kona_playercard
${DELETE_API}=       https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/
${cleanup}=         ${False}  # False is a built-in RF variable
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}        abdul.waajib@gmail.com
${password}    d8/c7S,HZPt+ZdB
${greeting}    Abdul!
# ${player}     4278129
# ${EXP_CURRENT_SEASON_ID}=       2022
# ${SWID}=      2575812E-8058-4D83-9486-CDD9149938CA
# ${ESPNS2}=    AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA
# ${ck}=          SWID={${SWID}};espn_s2=${ESPNS2}==
# ${headers}       Create Dictionary      Content-Type=application/json      Cookie=${ck}

*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    ${api_response}=    GET  url=${endpoint}  headers=${headers}   expected_status=200 
    [Return]    ${api_response}

Authenticate with captured Cookie
    FLM.Login Fantasy User     username=${user}   password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    set global variable     ${espn_cookie}

Validate the string is equal to the value for the given key
    [Documentation]     Custom validation for the given string equals to the expected value
    [Arguments]    ${response}  ${key}  ${value}
    dictionary should contain key    ${response}   ${key}
    should not be empty    ${response}[${key}]
    should be equal as strings  ${response}[${key}]      ${value}

Validate ${fieldName} should be equal to ${value}
    [Documentation]     Custom field level validation in response to check not null and equal to expected string
    # ${length}=      get length    ${fieldName}
    # IF    ${length}!=0
    should be equal as strings    ${fieldName}      ${value}

A POST request to ${DELETE_API} with ${payload} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    # &{playerdetails}=     Create Dictionary    playerId=3155942     type=DROP    fromTeamId=5
    # @{items}=    Create List
    Log To Console    ${payload}
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    # &{payload}=        Create Dictionary     teamId=5    type=ROSTER    memberId={107F4FFD-2902-4067-80ED-1B60E523AEA6}    scoringPeriodId=23    executionType=EXECUTE    items=${items}  
    ${api_response}=    POST  url=${DELETE_API}  headers=${headers}    json=${payload}    expected_status=200 
    [Return]    ${api_response}
    # Log To Console    ${api_response}


Find scoringPeriodId for the player
    [Documentation]     Custom GET keyword with status validation.
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    ${api_response}=    GET  url=${TEAMS_API}  headers=${headers}   expected_status=200
    # Log To Console    ${api_response.json()["scoringPeriodId"]}   
    ${spid}=    Set Variable     ${api_response.json()["scoringPeriodId"]}
    set global variable    ${spid}
    [Return]   ${spid}

Find teamid for the ${player} in a given scoringPeriodId
    [Documentation]     Custom GET keyword with status validation.
    set test variable    ${PLAYERINFO_API}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?scoringPeriodId=${spid}&view=kona_playercard 
    &{headers}=        Create Dictionary    Content-Type=application/json    x-fantasy-filter={"players":{"filterIds":{"value":[${player}]}}}       Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA== 
    ${api_response}=    GET  url=${PLAYERINFO_API}  headers=${headers}    expected_status=200 
    ${teamid}=    Set Variable     ${api_response.json()["players"][0]["onTeamId"]}
    set global variable    ${teamid}
    [Return]   ${teamid}

create a player List
    [Documentation]     Custom keyword to create a list of players with status validation.
    ${response}=    A GET request to ${PLAYERS_API} should respond with 200
    @{PLAYER_LIST}=    Create List
    FOR    ${item}     IN     @{response.json()["players"]}
        IF    "${item}[player][droppable]" == "True"
            Append To List  ${PLAYER_LIST}    ${item["player"]["id"]}
        END
    END
    [Return]    ${PLAYER_LIST}

Update payload ${payload} with teamid ${playerid} and spid
    [Documentation]     Custom keyword to update the payload with the values from API calls
    Set To Dictionary   ${payload}    teamId    ${teamid}
    Set To Dictionary   ${payload["items"][0]}    playerId=${playerid}
    Set To Dictionary   ${payload["items"][0]}    fromTeamId=${teamid}
    Set To Dictionary   ${payload}    scoringPeriodId    ${spid}
    set global variable    ${payload}
    Log To Console    ${payload}
    [Return]    ${payload}

Check player in ${PLAYER_LIST} not in team0 and return the player
    [Documentation]     Custom keyword to update the payload with the values from API calls
    @{FINAL_LIST}=    Create List
    FOR    ${player}    IN    @{PLAYER_LIST}
        # ${spid}    Find scoringPeriodId for the player
        ${teamid}    Find teamid for the ${player} in a given scoringPeriodId
        # ${playerid}    verify the ${teamid} is not zero
        IF    "${teamid}" != '0'
            # Log To Console    ${player}
            Append To List  ${FINAL_LIST}    ${player}
        END
        
    END
    [Return]    ${FINAL_LIST}[0]

