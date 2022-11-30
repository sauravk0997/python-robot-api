*** Settings ***
Documentation       Test suite to demontrate  move player functionality in FLM

Library    RequestsLibrary
Library    ../lib/validators/FantasyDropValidator.py
Resource   ../resource/FantasyDropResource.robot
Library    RPA.JSON

*** Variables ***
${droppedteamid}=    0                           #A dropped player will always have a teamid 0


*** Test Cases ***
Drop a player from any team as a league manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid   fantasy_games    drop   smoke       	CSEAUTO-28332
    #Load the template for the delete api payload
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    0
    #keyword to fetch the details to form the payload
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}
    Log To Console     ${playerid}
    # keyword to update the payload with the values from the previous step
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid} and ${spid}
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with 200
    # #Validates the schema of the delete api response
    Fantasy Drop Schema from ${drop_api_response} should be valid
    # #Validates the actual values of the delete api response with expected values
    should be equal as integers    ${drop_api_response.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${drop_api_response.json()["items"][0]["toTeamId"]}    ${droppedteamid}

Drop a player from my team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid   fantasy_games    drop   smoke       	CSEAUTO-28332
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    5
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}    
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid} and ${spid}
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with 200
    Fantasy Drop Schema from ${drop_api_response} should be valid
    should be equal as integers    ${drop_api_response.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${drop_api_response.json()["items"][0]["toTeamId"]}    ${droppedteamid}

Drop a player from the list of droppable players of a team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    5
    ${spid}    ${teamid}    ${playerid}    Get droppable players ${myteamid}
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid[0]} and ${spid}
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with 200
    Fantasy Drop Schema from ${drop_api_response} should be valid
    should be equal as integers    ${drop_api_response.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${drop_api_response.json()["items"][0]["toTeamId"]}    ${droppedteamid}
    
Drop a player from the list of undroppable players of a team as a league manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    5
    ${spid}    ${teamid}    ${playerid}    Get undroppable players ${myteamid}
    Log To Console     ${playerid}
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid[0]} and 20
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with 409

Drop a player from the list of injured players of a team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    6
    ${spid}    ${teamid}    ${playerid}    ${status}   Get injured players ${myteamid}
    ${final_payload}     Update payload ${initial_payload} with ${teamid} ${playerid} and ${spid}
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with ${status}
    IF    ${status} == 200
            Fantasy Drop Schema from ${drop_api_response} should be valid
    END

Drop a player from any team in a different scoringPeriodId as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid   fantasy_games    drop   smoke       	CSEAUTO-28332
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    0
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}
    Log To Console     ${playerid}
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid} and 20
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with 409

Drop a player from the list of undroppable players of a team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    5
    ${spid}    ${teamid}    ${playerid}    Get undroppable players ${myteamid}
    Log To Console     ${playerid}
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid[0]} and 20
    ${drop_api_response}    A POST request to ${DELETE_API} with ${final_payload} should respond with 409
