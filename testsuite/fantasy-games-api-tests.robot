*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyGamesCoreValidator.py
Library             ../lib/validators/FantasyGamesValidator.py
Resource            ../resource/FantasyGamesResource.robot
Library             OperatingSystem


*** Test Cases ***
Get Base Fantasy Games API Response
    [Documentation]     Simple validation of the base level schema url for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-27839
    ${response}=    A GET request to ${API_BASE} should respond with 200
    Fantasy Games Schema from ${response} should be valid

Get current season id from Fantasy Games API Response
    [Documentation]     Validate the current season id from the Fantasy Games API response
    [Tags]  valid   fantasy_games       	CSEAUTO-27840
    ${response}=    A GET request to ${API_BASE} should respond with 200
    ${actualCurrentSeasonId}=     Extract current season Id from fantasy game API Response        ${response.json()}
    log to console    ${actualCurrentSeasonId}
    should be equal as numbers    ${actualCurrentSeasonId}      ${EXP_CURRENT_SEASON_ID}

Get client flag from Fantasy Games API Response
    [Documentation]     Validate the value of the keys in client flag from the Fantasy Games API response
    [Tags]  valid   fantasy_games       CSEAUTO-27841
    ${response}=    A GET request to ${API_BASE} should respond with 200
    ${actualCurrentSeasonId}=     Extract client flags from fantasy game API Response    ${response.json()}     ESPN_PLUS_ENABLED
    log to console    ${actualCurrentSeasonId}

Get current scoring period id from Fantasy Games API Response
    [Documentation]     Validate the value of the id in scoring period from the Fantasy Games API response
    [Tags]  valid   fantasy_games       	CSEAUTO-27842
    ${response}=    A GET request to ${API_BASE} should respond with 200
    ${actualCurrentScoringPeriodId}=     Extract current scoring period id from fantasy game API Response       ${response.json()}
    log to console    ${actualCurrentScoringPeriodId}
    should be equal as numbers    ${actualCurrentScoringPeriodId}      6

Get value of settings key from Fantasy Games API Response
    [Documentation]     Validate the value of the keys in settings from the Fantasy Games API response.
    ...                 Possible entries: allowLeagueCreation/gated/proScheduleAvailable
    [Tags]  valid   fantasy_games       	CSEAUTO-27844
    ${response}=    A GET request to ${API_BASE} should respond with 200
    ${actualSettings}=     Extract value of the key from settings object of fantasy game API Response       ${response.json()}        gated
    log to console    ${actualSettings}
    should be equal as strings    ${actualSettings}      ${false}

Get draft schedule settings from Fantasy Games API Response
    [Documentation]     Validate the value of the keys in draft schedule settings from the Fantasy Games API response.
    ...                 Possible enteries: endDate/liveLobbyGated/mockLobbyGated/startDate
    [Tags]  valid   fantasy_games       	CSEAUTO-27845
    ${response}=    A GET request to ${API_BASE} should respond with 200
    ${actualDraftScheduleSettings}=     Extract draft schedule settings from fantasy game API Response    ${response.json()}     liveLobbyGated
    log to console    ${actualDraftScheduleSettings}

