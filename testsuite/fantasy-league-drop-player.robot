*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyDropValidator.py
Resource            ../resource/FantasyDropResource.robot
Library             OperatingSystem
Library    String


*** Test Cases ***
Get the player from my team for delete
    [Documentation]     Simple validation of the base level schema url for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-27839
    # Authenticate with captured Cookie
    ${response}=    A GET request to ${PLAYERS_API} should respond with 200
    @{PLAYER_LIST}=    Create List
    FOR    ${item}     IN     @{response.json()["players"]}
        IF    "${item}[player][droppable]" == "True"
            Append To List  ${PLAYER_LIST}    ${item["player"]["id"]}
        END
    END
    Log To Console    ${PLAYER_LIST}[0]
    Find scoringPeriodId for the player
    
    # Validate ${response.json()["id"]} should be equal to 748489070
    # ${response.json()[teams][0]["roster"]["entries"][0]["playerPoolEntry"]["player"]["droppable"]}
    # Validate player from response for drop
    # ${response}=    A POST request to ${DELETE_API} should respond with 200