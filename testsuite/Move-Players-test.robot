*** Settings ***
Documentation       Moving players form a fantasy league Positive tests are executing along with schema validation
...                 to run: robot --pythonpath $PWD ./testsuite/Move-Players-test.robot
Metadata    Author      Yusuf Mubarak M
Metadata    Date        14-11-2022
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    ../lib/validators/FantasyLeagueCoreValidator.py
Library     RPA.JSON
Resource    resource/FantasyLeagueResource.Robot


*** Test Cases ***
Create a League and Extract the LeagueId           #For Moving a player Required a Fantasy league instead of assuming and hardcoding a leagueid created a tesst league without any validation and also to create league with all validations will be covered by CSEAUTO-28333 once its completed this test case be removed
    &{headers}  create dictionary    cookie=SWID={95096766-E11A-4C94-BB21-2BA8F8C0D3EF}; espn_s2=AECrGNEO5w1VlDOoJEgL1wquDjPrYr1r0XR9A5zJln93t968%2BICfJi3k32jhzzwTZpEzvBWbOf0%2FFx0ObwGqatXTiooE1n3SkjICYmcbiqCYUJjHQp6e9JyUT67qTYAVlmpWwiir8Auj6AMyk5Du%2BySpeboBjJLUm%2BPGsk7ajvLy26t8PgyzWpnbM8EzazCCLqAkeLNjEe1PdV6%2FmHj9t2fZgfusdIAns%2FpsBtgNQtBnzwhFUhrJ6JvyLFF0syVwv%2FGszPfVEzIwfOtXGHbSkdsI3WlAqQc61wm6q%2BkLeUxVnw%3D%3D;
    set global variable    ${headers}
    ${create_league}=    get file   resource/create.json
    ${create_league_payload}=   Evaluate  json.loads('''${create_league}''')
    To Create a league send a post request to ${CreateLeague_url} using ${headers} with ${create_league_payload} should respond with 200

Offline Draft Begin                 #For Moving a player Required a Fantasy league with offline drafting startegy instead of assuming and hardcoding created a league with offline draft strategy without any validation and also to create a league with offline strategy along with the validations will be covered by CSEAUTO-28333 once its completed this test case be removed
    set test variable    ${request_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/draftDetail
    &{BeginDraft_payload}   create dictionary     inProgress=true
    A post request to ${request_url} using ${headers} with ${BeginDraft_payload} should respond with 200

Add Players to a team               #For Moving a player Required a Fantasy league and a team with players instead of assuming and hardcoding a team with players created a test case to add players to a team without any validation and also to add players with all validations will be covered by CSEAUTO-28331 once its completed this test case be removed
    set test variable    ${addPlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    ${Players}=    get file  resource/PlayerList.json
    ${players_payload}=   Evaluate  json.loads('''${Players}''')
    A post request to ${addPlayer_url} using ${headers} with ${players_payload} should respond with 200


Save the Team and complete Draft    #For Moving a player Required a Fantasy league and a team with players instead of assuming and hardcoding a team with players created a test case to add players to a team without any validation and also to add players with all validations will be covered by CSEAUTO-28331 once its completed this test case be removed
    set test variable    ${request_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/draftDetail
    &{CompleteDraft_payload}   create dictionary    drafted=true   inProgress=false
    A post request to ${request_url} using ${headers} with ${CompleteDraft_payload} should respond with 200

Move the Players by swaping the position of the players
    [Tags]    swap players  valid CSEAUTO-28392
    set test variable    ${MovePlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    ${swap_players}=    get file    resource/SwapPlayer.json
    ${swap_players_payload}=     Evaluate  json.loads('''${swap_players}''')     #if a user wants to move a player in current scoringperiod then type should be roster and for future scoring period type should be future roster
    ${response}         A post request to ${MovePlayer_url} using ${headers} with ${swap_players_payload} should respond with 200
    Move Player Schema from ${response} should be valid
    #validation to check whether the players positions are swapped
    ${fromLineupSlotId}  Get value from JSON     ${response.json()}     $.items[0].fromLineupSlotId
    log to console   ${fromLineupSlotId}
    ${toLineupSlotId}    Get value from JSON     ${response.json()}    $.items[1].toLineupSlotId        #whenever we swap the positions of a player then player1 fromLineupslotid will be equal to player2's toLineupSlotId
    log to console   ${toLineupSlotId}
    should be equal as integers    ${fromLineupSlotId}    ${toLineupSlotId}



Move the Players to Bench
    [Tags]    move players to Bench  valid  CSEAUTO-28395
    set test variable    ${MovePlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    ${Move_to_Bench}=    get file    resource/MovetoBench.json
    ${Move_to_Bench_payload}=     Evaluate  json.loads('''${Move_to_Bench}''')      #if a user wants to move a player in current scoringperiod then type should be roster and for future scoring period type should be future roster
    ${response}     A post request to ${MovePlayer_url} using ${headers} with ${Move_to_Bench_payload} should respond with 200
    Move Player Schema from ${response} should be valid
    #validation to check whether the player is moved to bench
    ${toLineupSlotId}    Get value from JSON    ${response.json()}    $.items[0].toLineupSlotId
    should be equal as integers    ${toLineupSlotId}    12           # whenever any player is moved to bench toLineupSlotId will be 12 hence fetched the value from response and checked whether its equal to 12 or not















