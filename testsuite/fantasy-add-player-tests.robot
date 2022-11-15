*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: robot --pythonpath $PWD ./testsuite/fantasy-games-api-tests.robot

Library             RequestsLibrary
#Library             lib.validators.FantasyAddValidator.py
Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem




*** Test Cases ***
Add a player to my team as a Team Owner
    
    [Documentation]     Simple validation of the base level schema url and adding player as a TO for Fantasy Games API.
    [Tags]  valid   fantasy_games       smoke       	CSEAUTO-28331
    #Auth with Cookie Capture
    # ${payload}=  Get File  resource/AddPlayer.json
    # ${data}=     Evaluate    json.loads('''${payload}''') 
    To Fetch the FREE AGENT player
    To fetch the Droppable Player
    To Fetch scoringPeriodId for the player
    #${payload}    Update the json ${data} with ${FA_Player_list}[0] ${Drop_Player_list}[0] ${spid}

    ${response}=    A POST request to ${API_BASE} add a player should respond with 200
    #${response_LM}=   A POST request to ${API_BASE} as LM should respond with 200 
    Fantasy Games Schema from ${response} should be valid




