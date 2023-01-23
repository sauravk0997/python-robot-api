*** Settings ***
Documentation       Sample suite showing a simple endpoint validation example as well as a more indepth test configuration with more assertions.
...                 to run: python3 -m robot testsuite/fantasy-add-player-tests.robot

Library             RequestsLibrary
Library             ../lib/validators/FantasyAddPlayerValidator.py
Resource            ../resource/FantasyAddPlayerResourse.robot
Library             OperatingSystem
Library             RPA.JSON
Resource            resource/sel-based-login.robot
Suite Setup         Get user cookie
Suite Teardown      Browser Shutdown

*** Test Cases ***
As a Team Owner, I should not be able to add more than 4 players at 'Position C' in my team.
    [Documentation]     Simple validation of the base level schema url and adding a Position C player in my team when I already have 4 Position C player in my team as a Team Owner for Fantasy Games API.
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29060
    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add a player at position C to my team should respond with 409

Add and drop a player in my team as a Team Owner
    [Documentation]     Simple validation of the base level schema url and 'adding and dropping' player in my team as a Team Owner for Fantasy Games API.
    [Tags]    RoxasAPI    valid    FantasyAPI    CSEAUTO-28331    CSEAUTO-28388    CSEAUTO-28397
    Sending POST request and validating for adding and dropping a player from my team as Team Owner

Add and drop a player in my team as a League Manager
    [Documentation]     Simple validation of the base level schema url and 'adding and dropping' player in my team as a League Manager for Fantasy Games API.
    [Tags]    RoxasAPI    valid   fantasy_games    CSEAUTO-28331    CSEAUTO-28388    CSEAUTO-28390
    Sending POST request and validating for adding and dropping a player from my team as League Manager

As a Fantasy League Manager, add and drop a player to other team
    [Documentation]     Simple validation of the base level schema url and 'adding and dropping' player in other team as a League Manager for Fantasy Games API.
    [Tags]    RoxasAPI    valid   FantasyAPI    CSEAUTO-28331    CSEAUTO-28388    CSEAUTO-28643
    Sending POST request and validating for adding and dropping a player from other team as League Manager
    
As a Team Owner, I should not be able to add a new player in my team, if my roaster is full.
    [Documentation]     Simple validation of the base level schema url and adding a player in my team as a Team Owner when my roaster is full for Fantasy Games API.
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29058
    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} not to add a player to my team if my roaster is full should respond with 409

Drop and add a player in my team as a Team Owner
    [Documentation]     Simple validation of the base level schema url and 'dropping and then adding' a player in my team as a Team Owner for Fantasy Games API.
    [Tags]    RoxasAPI    valid   FantasyAPI    CSEAUTO-28331    CSEAUTO-28388    CSEAUTO-28648
    Drop a player from my team as TO
    Add a player to my team as TO

Drop and add a player in other team as a League Manager
    [Documentation]     Simple validation of the base level schema url and 'dropping and then adding' a player in my team as a Team Owner for Fantasy Games API.
    [Tags]    RoxasAPI    valid   FantasyAPI    CSEAUTO-28331    CSEAUTO-28388    CSEAUTO-28645
    As League Manager, Drop a player from other team 4
    As League Manager, Add a player to other team 4

As a Team Owner, I should not be able to add an On Waivers player in my team.
    [Documentation]     Simple validation of the base level schema url and adding a waiver player in my team as a Team Owner for Fantasy Games API.
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388     CSEAUTO-29059
    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add an On Waiver player in my team should respond with 409

As a Team Owner, I should not be able to add an On Roster player in my team.
    [Documentation]     Simple validation of the base level schema url and adding a rosters player in my team as a Team Owner for Fantasy Games API.
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29061
    ${on_roster_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add an On Roaster player in my team should respond with 409
    Validate the response ${on_roster_response} and response should contain error message TRAN_PLAYER_NOT_AVAILABLE
    Invalid Add Player Schema from ${on_roster_response} should be valid

As a Team Owner, I should not be able to add a player with wrong scoring period Id
    [Documentation]    Simple validation of the base level schema url and adding a player with wrong scoring period id
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29129
    ${wrong_scoring_periodId_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add player with wrong scoring period id should respond with 409
    Validate the response ${wrong_scoring_periodId_response} and response should contain error message TRAN_INVALID_SCORINGPERIOD_NOT_CURRENT
    Invalid Add Player Schema from ${wrong_scoring_periodId_response} should be valid

As a League Manager, add a valid player to invalid team
    [Documentation]    Simple validation of the base level schema and adding a valid player to invlaid team
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29118
    ${invalid_team_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add a player with proper resource/JSON/InvalidTeam.json should respond with 409
    Validate the response ${invalid_team_response} and response should contain error message TEAM_NOT_FOUND
    Invalid Add Player Schema from ${invalid_team_response} should be valid

As a Team Owner, add an invalid player to my team
    [Documentation]    Simple validation of the base level schema url and adding a invalid player to my team
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29116
    ${invalid_player_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add a player with proper resource/JSON/InvalidPlayer.json should respond with 400
    Validate the response ${invalid_player_response} and response should contain error message PLAYER_NOT_EXISTS
    Invalid Add Player Schema from ${invalid_player_response} should be valid    

As a League Manager, add an invalid player to my team
    [Documentation]    Simple validation of the base level schema url and adding an invalid player as LM to my team
    [Tags]    RoxasAPI    invalid   FantasyAPI    CSEAUTO-29016    CSEAUTO-28388    CSEAUTO-29117
    ${invalid_player_response}=    A POST request ${API_BASE}/${LEAGUE_SLUG}/${TRANSACTION_SLUG} to add a player with proper resource/JSON/InvlaidPlayerasLM.json should respond with 400
    Validate the response ${invalid_player_response} and response should contain error message PLAYER_NOT_EXISTS
    Invalid Add Player Schema from ${invalid_player_response} should be valid