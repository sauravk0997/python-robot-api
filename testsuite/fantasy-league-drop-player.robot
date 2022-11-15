*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyDropValidator.py
Resource            ../resource/FantasyDropResource.robot
Library             OperatingSystem
Library    String
Library    Telnet

*** Variables ***
${status}=    200


*** Test Cases ***
Drop a player from any team as a league manager
    [Documentation]     Simple validation of the base level schema url for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-27839
    # Authenticate with captured Cookie
    ${pjs}=    Get file     /Users/abdul/Disney/espn-fantasy-api/dropplayer.json
    #LOAD JSON from file
    ${object}=    Evaluate     json.loads('''${pjs}''')    json
    @{PLAYER_LIST}    create a player List
    ${spid}    Find scoringPeriodId for the player
    ${eligible_player}    Check player in @{PLAYER_LIST} not in team0 and return the player
    IF    "${eligible_player}" == None
        Log To Console    "No players available to drop as a league manager"
    ELSE
        ${teamid}    Find teamid for the ${eligible_player} in a given scoringPeriodId
        ${payload}    Update payload ${object} with teamid ${eligible_player} and spid
        ${finalresponse}    A POST request to ${DELETE_API} with ${payload} should respond with ${status}
    END
    Fantasy Drop Schema from ${finalresponse} should be valid
    should be equal as integers    ${finalresponse.json()["items"][0]["fromTeamId"]}    ${teamid}
    should be equal as integers    ${finalresponse.json()["items"][0]["toTeamId"]}    0
    # ${spid}    Find scoringPeriodId for the player
    # ${teamid}    Find teamid for the ${PLAYER_LIST}[0] in a given scoringPeriodId
    # ${payload}    Update payload ${object} with ${teamid} ${PLAYER_LIST}[0] and ${spid}
    # A POST request to ${DELETE_API} with ${payload} should respond with ${status}