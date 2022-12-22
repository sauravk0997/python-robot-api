*** Settings ***
Documentation       Test suite to demontrate  move player functionality in FLM

Library              RequestsLibrary
Library              lib/validators/FantasyDropValidator.py
Resource             resource/suite_setup_teardown_moveplayer.resource
Resource             ../resource/FantasyDropResource.robot
Library              RPA.JSON
Suite Setup          Get a Fantasy League details
# Suite Teardown       Delete League

*** Variables ***
${droppedteamid}=    0                           #A dropped player will always have a teamid 0

*** Test Cases ***
Drop a player from any team as a league manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid   fantasy_games    drop   smoke    CSEAUTO-28332
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    0
    ${league_manager}    Set Variable    True
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}
    Log To Console     ${playerid}
    Update payload ${initial_payload} with ${teamid} ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 200
    Fantasy Drop Schema from ${drop_api_response} should be valid
    should be equal as integers    ${drop_api_response.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${drop_api_response.json()["items"][0]["toTeamId"]}    ${droppedteamid}

Drop a player from my team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid    fantasy_games    drop    smoke    CSEAUTO-28629
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    3
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}    
    Update payload ${initial_payload} with ${teamid} ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 200
    Fantasy Drop Schema from ${drop_api_response} should be valid
    should be equal as integers    ${drop_api_response.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${drop_api_response.json()["items"][0]["toTeamId"]}    ${droppedteamid}

Drop a player from the list of droppable players of a team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid    fantasy_games    drop    smoke    CSEAUTO-28629
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    4
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    Get droppable players ${myteamid}
    Update payload ${initial_payload} with ${teamid} ${playerid[0]} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 200
    Fantasy Drop Schema from ${drop_api_response} should be valid
    should be equal as integers    ${drop_api_response.json()["items"][0]["fromTeamId"]}    ${teamid}    
    should be equal as integers    ${drop_api_response.json()["items"][0]["toTeamId"]}    ${droppedteamid}
    
Drop a player from the list of undroppable players of a team as a league manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid    fantasy_games    drop    smoke    CSEAUTO-28629
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    1
    ${league_manager}    Set Variable    True
    ${spid}    ${teamid}    ${playerid}    Get undroppable players ${myteamid} ${league_manager}
    Update payload ${initial_payload} with ${teamid} ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 200
    Fantasy Drop Schema from ${drop_api_response} should be valid

Drop a player from the list of injured players of a team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  valid    fantasy_games    drop    smoke    CSEAUTO-28629
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    4
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    ${status}   Get injured players ${myteamid}
    Update payload ${initial_payload} with ${teamid} ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with ${status}
    IF    ${status} == 200
            Fantasy Drop Schema from ${drop_api_response} should be valid
    END

Drop a player from any team in a different scoringPeriodId as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  invalid    fantasy_games    drop    smoke    CSEAUTO-28629
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    0
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}
    Update payload ${initial_payload} with ${teamid} ${playerid} 20 and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 409
    Invalid scoring period error response ${drop_api_response} along with schema should be valid

Drop a player from the list of undroppable players of a team as a team manager
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  invalid    fantasy_games    drop    smoke    CSEAUTO-28629
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    1
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    Get undroppable players ${myteamid} ${league_manager}
    Update payload ${initial_payload} with ${teamid} ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 409
    Undroppable error response ${drop_api_response} along with schema should be valid

Drop a player from a team as a team owner using invalid type
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  invalid    fantasy_games    drop    smoke    CSEAUTO-29003
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player_invalid_type.json
    ${myteamid}    Set Variable    3
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}    
    Update payload ${initial_payload} with ${teamid} ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 409
    Invalid type error response ${drop_api_response} along with schema should be valid

Drop an invalid player from a team as a team owner
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  invalid    fantasy_games    drop    smoke    CSEAUTO-29003
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    3
    ${league_manager}    Set Variable    False
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}    
    Update payload ${initial_payload} with ${teamid} 3945274 ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 409
    Invalid player error response ${drop_api_response} along with schema should be valid

Drop an invalid player from a team as a league owner
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  invalid    fantasy_games    drop    smoke    CSEAUTO-29003
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    3
    ${league_manager}    Set Variable    True
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}    
    Update payload ${initial_payload} with ${teamid} 3945274 ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 409
    Invalid player error response ${drop_api_response} along with schema should be valid

Drop a player from an invalid team as a league owner
    [Documentation]     Simple validation with steps for the drop player API response schema and values for Fantasy Games API.
    [Tags]  invalid    fantasy_games    drop    smoke    CSEAUTO-29003
    &{initial_payload}=    Load JSON from file    resource/JSON/drop_player.json
    ${myteamid}    Set Variable    0
    ${league_manager}    Set Variable    True
    ${spid}    ${teamid}    ${playerid}    Fetch payload details to drop a player ${myteamid}    
    Update payload ${initial_payload} with 0 ${playerid} ${spid} and ${league_manager}
    ${drop_api_response}    A POST request to ${DROP_API} with ${payload} should respond with 409
    Invalid team error response ${drop_api_response} along with schema should be valid
