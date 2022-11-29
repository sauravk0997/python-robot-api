*** Settings ***
Documentation       All Common robot utils/functions and variables with respect to
...                 ESPN Fantasy Games API are maintained here
Library             RequestsLibrary
Library             Collections
Library             ../lib/validators/FantasyDropValidator.py

*** Variables ***
${FANTASY_BASE_URL}=            https://fantasy.espn.com
${GAME}=                        fba
${SEASON}=                      2023
${LEAGUEID}=                    748489070
${QUERY_PARAM}=                 view=mDraftDetail&view=mTeam&view=mNav&view=mRoster
${TEAM_SLUG}=                   apis/v3/games/${GAME}/seasons/${SEASON}/segments/0/leagues/${LEAGUEID}?${QUERY_PARAM}
${TRANSACTIONS_BASE_URL}=       https://lm-api-writes.fantasy.espn.com
${TRANSACTIONS_SLUG}=           apis/v3/games/${GAME}/seasons/${SEASON}/segments/0/leagues/${LEAGUEID}/transactions
${USER_COOKIE}=                 SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
${DELETE_API}=                  ${TRANSACTIONS_BASE_URL}/${TRANSACTIONS_SLUG} 


*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    &{headers}=         Create Dictionary    Cookie=${USER_COOKIE}
    ${api_response}=    GET  url=${endpoint}  headers=${headers}   expected_status=200 
    [Return]            ${api_response}

Validate the string is equal to the value for the given key
    [Documentation]                  Custom validation for the given string equals to the expected value
    [Arguments]                      ${response}  ${key}  ${value}
    dictionary should contain key    ${response}   ${key}
    should not be empty              ${response}[${key}]
    should be equal as strings       ${response}[${key}]      ${value}

A POST request to ${DELETE_API} with ${payload} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    Log To Console      ${payload}
    &{headers}=         Create Dictionary    Cookie=${USER_COOKIE}
    ${api_response}=    POST  url=${DELETE_API}  headers=${headers}    json=${payload}    expected_status=${status} 
    [Return]            ${api_response}
 
Fetch payload details to drop a player ${myteamid}
    [Documentation]   Custom keyword to form the request payload for the delete API
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAM_SLUG} should respond with 200
    ${spid}    ${teamid}    ${playerid}    Get a player to drop ${response} ${myteamid}
    [Return]          ${spid}    ${teamid}    ${playerid}

Get droppable players ${myteamid}
    [Documentation]   Custom keyword to form the request payload for the delete API
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAM_SLUG} should respond with 200
    ${spid}    ${teamid}    ${playerid}    Find droppable players of a team ${response} ${myteamid}
    [Return]          ${spid}    ${teamid}    ${playerid}

Get undroppable players ${myteamid}
    [Documentation]   Custom keyword to form the request payload for the delete API
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAM_SLUG} should respond with 200
    ${spid}    ${teamid}    ${playerid}    Find undroppable players of a team ${response} ${myteamid}
    [Return]          ${spid}    ${teamid}    ${playerid}

Get injured players ${myteamid}
    [Documentation]   Custom keyword to form the request payload for the delete API
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAM_SLUG} should respond with 200
    ${spid}    ${teamid}    ${playerid}    Find injured players of a team ${response} ${myteamid}
    ${count}=    Get Length    ${playerid}
    IF    ${count} > 0
    ${status}    Set Variable    200
    ${playerid}    Set Variable    ${playerid[0]}
    ELSE
    ${status}    Set Variable    400
    END
    [Return]          ${spid}    ${teamid}    ${playerid}    ${status}


Update payload ${payload} with ${teamid} ${playerid} and ${spid}
    [Documentation]         Custom keyword to update the DELETE API payload with the values from API calls.
    Set To Dictionary       ${payload}    teamId    ${teamid}
    Set To Dictionary       ${payload["items"][0]}    playerId=${playerid}
    Set To Dictionary       ${payload["items"][0]}    fromTeamId=${teamid}
    Set To Dictionary       ${payload}    scoringPeriodId    ${spid}
    set global variable     ${payload}    
    [Return]                ${payload}
