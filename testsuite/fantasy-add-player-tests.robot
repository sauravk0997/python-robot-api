*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
#Library             lib.validators.FantasyAddValidator.py
#Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem


*** Test Cases ***
Get Fantasy Add player API Response
    [Documentation]     Simple validation of the base level schema url and adding player as a TO for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    Auth with Cookie Capture
    ${myTeamPlayer_response}=    A GET request to ${myTeamPlayer_url} get list of all my team players respond with 200
    ${AllTeamPlayer_response}=   A GET request to ${AllTeamPlayer_url} get list of all the players respond with 200
    To fetch the list of playerid from my team ${myTeamPlayer_url}
    To fetch the list of playerId from unroasted list ${AllTeamPlayer_url}
    ${response}=    A POST request to ${API_BASE} add player to my team as a TO should respond with 200
    ${response_LM}=   A POST request to ${API_BASE} add player to my team as a LM should respond with 200 
    Fantasy Games Schema from ${response} should be valid




