*** Settings ***
Documentation       Test suite to demontrate  move player functionality in FLM

Library    RequestsLibrary
Library    ../lib/validators/FantasyDropValidator.py
Resource   ../resource/FantasyDropResource.robot
Library    OperatingSystem
Library    Collections
Library    String    
Library    RPA.JSON

*** Variables ***
${status}=    200
${droppedteamid}=    0                           #A dropped player will always have a teamid 0


*** Test Cases ***
Drop a player from any team as a league manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid   fantasy_games    drop   smoke       	CSEAUTO-28332
    # Authenticate with captured Cookie
    &{initial_payload}=    Load JSON from file    resource/dropplayer.json
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid} and ${spid}
    Log To Console    ${final_payload}
    ${finalresponse}    A POST request to ${DELETE_API} with ${payload} should respond with ${status}
    Fantasy Drop Schema from ${finalresponse} should be valid
    should be equal as integers    ${finalresponse.json()["items"][0]["fromTeamId"]}    ${teamid}
    should be equal as integers    ${finalresponse.json()["items"][0]["toTeamId"]}    ${droppedteamid}
