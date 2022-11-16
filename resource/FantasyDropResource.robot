*** Settings ***
Documentation       All Common robot utils/functions and variables with respect to
...                 ESPN Fantasy Games API are maintained here
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             ../lib/validators/FantasyDropValidator.py
Library             String

*** Variables ***
${TEAMS_API}=        https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav  # tests default to the sandbox environment
${PLAYERS_API}=      https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=players_wl
${PLAYERINFO_API}=    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?scoringPeriodId={spid}&view=kona_playercard
${DELETE_API}=       https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/
${cleanup}=         ${False}  # False is a built-in RF variable

*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    ${api_response}=    GET  url=${endpoint}  headers=${headers}   expected_status=200 
    [Return]    ${api_response}

Authenticate with captured Cookie
    [Documentation]     Custom keyword for FLM login using selenium to capture cookies required for login.
    FLM.Login Fantasy User     username=${user}   password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    set global variable     ${espn_cookie}

Validate the string is equal to the value for the given key
    [Documentation]     Custom validation for the given string equals to the expected value
    [Arguments]    ${response}  ${key}  ${value}
    dictionary should contain key    ${response}   ${key}
    should not be empty    ${response}[${key}]
    should be equal as strings  ${response}[${key}]      ${value}

A POST request to ${DELETE_API} with ${payload} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    Log To Console    ${payload}
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    ${api_response}=    POST  url=${DELETE_API}  headers=${headers}    json=${payload}    expected_status=200 
    [Return]    ${api_response}
 
Fetch payload details to drop a player
    [Documentation]    Custom keyword to form the request payload for the delete API
    ${response}=    A GET request to ${TEAMS_API} should respond with 200
    ${spid}    ${teamid}    ${playerid}   get droppable players from any team with ${response} 
    [Return]    ${spid}    ${teamid}    ${playerid}

Update payload ${payload} with ${teamid} ${playerid} and ${spid}
    [Documentation]     Custom keyword to update the DELETE API payload with the values from API calls.
    Set To Dictionary   ${payload}    teamId    ${teamid}
    Set To Dictionary   ${payload["items"][0]}    playerId=${playerid}
    Set To Dictionary   ${payload["items"][0]}    fromTeamId=${teamid}
    Set To Dictionary   ${payload}    scoringPeriodId    ${spid}
    set global variable    ${payload}
    [Return]    ${payload}
