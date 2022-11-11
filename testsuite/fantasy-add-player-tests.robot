*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
# Library             lib.validators.FantasyAddValidator.py
Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem


*** Test Cases ***
Get Fantasy Add player API Response
    [Documentation]     Simple validation of the base level schema url for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-27839
    Auth with Cookie Capture
    ${response}=    A POST request to ${API_BASE} add player to my team as a TO should respond with 200
    Fantasy Games Schema from ${response} should be valid




    