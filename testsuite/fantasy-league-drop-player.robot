*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyDropValidator.py
Resource            ../resource/FantasyDropResource.robot
Library             OperatingSystem


*** Test Cases ***
Get the player from my team for delete
    [Documentation]     Simple validation of the base level schema url for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-27839
    # ${response}=    A GET request to ${TEAMS_API} should respond with 200
    # Validate player from response for drop
    ${response}=    A POST request to ${DELETE_API} should respond with 200