*** Settings ***
Documentation       All Common robot utils/functions and variables with respect to
...                 ESPN Fantasy Games API are maintained here
Library             RequestsLibrary
Library             Collections
Library             ../lib/validators/FantasyDropValidator.py
Resource            resource/FantasyResource.robot

*** Variables ***
${FANTASY_BASE_URL}=                https://fantasy.espn.com
${GAME}=                            fba
${SEASON}=                          2023
${QUERY_PARAMS}=                    view=mDraftDetail&view=mTeam&view=mNav&view=mRoster
${TEAMS_SLUG}=                      apis/v3/games/${GAME}/seasons/${SEASON}/segments/0/leagues
${TRANSACTIONS_BASE_URL}=           https://lm-api-writes.fantasy.espn.com
${TRANSACTION_SLUG}=                apis/v3/games/${GAME}/seasons/${SEASON}/segments/0/leagues
${DROP_API}=                        ${TRANSACTIONS_BASE_URL}/${TRANSACTION_SLUG}
${ERROR_UNDROPPABLE}                TRAN_ROSTER_PLAYER_NOT_DROPPABLE
${ERROR_INVALID_TYPE}               TRAN_INVALID_SCORINGPERIOD_NOT_FUTURE
${ERROR_INVALID_PLAYER}             TRAN_PLAYER_NOT_ON_TEAM
${ERROR_INVALID_TEAM}               TEAM_NOT_FOUND
${ERROR_INVALID_SCORING_PERIOD}     TRAN_INVALID_SCORINGPERIOD_NOT_CURRENT


*** Keywords ***
A GET request to ${endpoint} respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    ${api_response}=    GET  url=${endpoint}  headers=&{header_value}   expected_status=200 
    [Return]            ${api_response}

Validate the string is equal to the value for the given key
    [Documentation]                  Custom validation for the given string equals to the expected value
    [Arguments]                      ${response}  ${key}  ${value}
    dictionary should contain key    ${response}   ${key}
    should not be empty              ${response}[${key}]
    should be equal as strings       ${response}[${key}]      ${value}

A POST request to ${DROP_API} with ${payload} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    Log To Console      ${payload}
    ${api_response}=    POST  url=${DROP_API}/${league_id}/transactions  headers=&{header_value}    json=${payload}    expected_status=${status} 
    [Return]            ${api_response}
 
Fetch payload details to drop a player ${myteamid}
    [Documentation]   Custom keyword to get a player for drop
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAMS_SLUG}/${league_id}?${QUERY_PARAMS} respond with 200
    ${spid}    ${teamid}    ${playerid}    Get a player to drop ${response} ${myteamid}
    [Return]          ${spid}    ${teamid}    ${playerid}

Get droppable players ${myteamid}
    [Documentation]   Custom keyword to get the droppable players of a team
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAMS_SLUG}/${league_id}?${QUERY_PARAMS} respond with 200
    ${spid}    ${teamid}    ${playerid}    Find droppable players of a team ${response} ${myteamid}
    [Return]          ${spid}    ${teamid}    ${playerid}

Get undroppable players ${myteamid} ${league_manager}
    [Documentation]   Custom keyword to get the undroppable players of a team
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAMS_SLUG}/${league_id}?${QUERY_PARAMS} respond with 200
    ${spid}    ${teamid}    ${playerid}    Find undroppable players of a team ${response} ${myteamid}
    [Return]          ${spid}    ${teamid}    ${playerid[0]}

Get injured players ${myteamid}
    [Documentation]   Custom keyword to get the injured players of a team
    ${response}=      A GET request to ${FANTASY_BASE_URL}/${TEAMS_SLUG}/${league_id}?${QUERY_PARAMS} respond with 200
    ${spid}    ${teamid}    ${playerid}    Find injured players of a team ${response} ${myteamid}
    ${count}=    Get Length    ${playerid}
    IF    ${count} > 0
    ${status}    Set Variable    200
    ${playerid}    Set Variable    ${playerid[0]}
    ELSE
    ${status}    Set Variable    400
    Log To Console    "No injured players in the team"
    END
    [Return]          ${spid}    ${teamid}    ${playerid}    ${status}

Update payload ${payload} with ${teamid} ${playerid} ${scoring_period_id} and ${league_manager}
    [Documentation]         Custom keyword to update the DROP API payload with the values from API calls.
    Set To Dictionary       ${payload}    teamId    ${teamid}
    Set To Dictionary       ${payload["items"][0]}    playerId=${playerid}
    Set To Dictionary       ${payload["items"][0]}    fromTeamId=${teamid}
    Set To Dictionary       ${payload}    scoringPeriodId    ${scoring_period_id}
    Set To Dictionary       ${payload}    isLeagueManager    ${league_manager}
    set global variable     ${payload}    
    [Return]                ${payload}

Undroppable error response ${drop_api_response} along with schema should be valid
    [Documentation]         Custom keyword to validate error response and schema
    invalid drop response ${drop_api_response} schema should be valid
    ${responsebool}    error response ${drop_api_response} should contain ${ERROR_UNDROPPABLE}
    IF    ${responsebool} == True
    Log To Console    "Error message is as expected"
    END

Invalid type error response ${drop_api_response} along with schema should be valid
    [Documentation]         Custom keyword to validate error response and schema
    invalid drop response ${drop_api_response} schema should be valid
    ${responsebool}    error response ${drop_api_response} should contain ${ERROR_INVALID_TYPE}
    IF    ${responsebool} == True
    Log To Console    "Error message is as expected"
    END

Invalid player error response ${drop_api_response} along with schema should be valid
    [Documentation]         Custom keyword to validate error response and schema
    invalid drop response ${drop_api_response} schema should be valid
    ${responsebool}    error response ${drop_api_response} should contain ${ERROR_INVALID_PLAYER}
    IF    ${responsebool} == True
    Log To Console    "Error message is as expected"
    END

Invalid team error response ${drop_api_response} along with schema should be valid
    [Documentation]         Custom keyword to validate error response and schema
    invalid drop response ${drop_api_response} schema should be valid
    ${responsebool}    error response ${drop_api_response} should contain ${ERROR_INVALID_TEAM}
    IF    ${responsebool} == True
    Log To Console    "Error message is as expected"
    END

Invalid scoring period error response ${drop_api_response} along with schema should be valid
    [Documentation]         Custom keyword to validate error response and schema
    invalid drop response ${drop_api_response} schema should be valid
    ${responsebool}    error response ${drop_api_response} should contain ${ERROR_INVALID_SCORING_PERIOD}
    IF    ${responsebool} == True
    Log To Console    "Error message is as expected"
    END
