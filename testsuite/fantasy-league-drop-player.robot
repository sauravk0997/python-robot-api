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

    #Load the template for the delete api payload
    &{initial_payload}=    Load JSON from file    resource/dropplayer.json
    #keyword to fetch the details to form the payload
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player
    #keyword to update the payload with the values from the previous step
    ${final_payload}    Update payload ${initial_payload} with ${teamid} ${playerid} and ${spid}
    ${finalresponse}    A POST request to ${DELETE_API} with ${payload} should respond with ${status}
    #Validates the schema of the delete api response
    Fantasy Drop Schema from ${finalresponse} should be valid
    #Validates the actual values of the delete api response with expected values
    should be equal as integers    ${finalresponse.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${finalresponse.json()["items"][0]["toTeamId"]}    ${droppedteamid}
