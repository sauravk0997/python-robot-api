*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library             RequestsLibrary
Library             RPA.JSON
Library             Collections
Library             String
Library             OperatingSystem
Library             lib/validators/FantasyMovePlayerValidator.py

*** Variables ***
${fantasy_url}                    https://fantasy.espn.com
${BASEBALL_SPORT}                 fba
${SEASON}                         2023
${SEGMENT}                        0
${create_league_url}              ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues?createAsTypeId=2
${league_invite_url}              ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/<leagueid>/invites?copyLMOnInvite=false&notifyUnjoined=false
${league_invitation_accept_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/<leagueid>/invites/{leagueInviteId}?memberId=BC6305D7-5A17-4840-B231-8D34D45B1DCB&join=true
${team_create_url}                ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/<leagueid>/teams/<teamId>
${offline_draftStarting_url}      ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/<leagueid>/draftDetail
${teams_info_url}                 ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/<leagueid>?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav
${transaction_url}                ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/<leagueid>/transactions/
${espn_cookie}                    SWID={95096766-E11A-4C94-BB21-2BA8F8C0D3EF}; espn_s2=AECrGNEO5w1VlDOoJEgL1wquDjPrYr1r0XR9A5zJln93t968%2BICfJi3k32jhzzwTZpEzvBWbOf0%2FFx0ObwGqatXTiooE1n3SkjICYmcbiqCYUJjHQp6e9JyUT67qTYAVlmpWwiir8Auj6AMyk5Du%2BySpeboBjJLUm%2BPGsk7ajvLy26t8PgyzWpnbM8EzazCCLqAkeLNjEe1PdV6%2FmHj9t2fZgfusdIAns%2FpsBtgNQtBnzwhFUhrJ6JvyLFF0syVwv%2FGszPfVEzIwfOtXGHbSkdsI3WlAqQc61wm6q%2BkLeUxVnw%3D%3D;
${BROWSER}                        Chrome
${user}                           test_api@gmail.com
${password}                       test_api
${greeting}                       TestUser!
${BenchSlotId}                    12

*** Keywords ***
#Post request for creating a legaue
To create a league send a post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${headers}     json=${payload}    expected_status=${status}
    ${leagueid}      get from dictionary    ${response.json()}  id
    #getting the league id value and setting it global, so that it can used whenever required
    set global variable     ${leagueid}

#Post request for Performing various transactions like move,add,delete,drop..etc
A post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${header}     json=${payload}    expected_status=${status}
    [Return]    ${response}

Create a league
    &{headers}  create dictionary    cookie=${espn_cookie}
    set global variable    ${headers}
    ${create_league_payload}=    Load JSON from file    resource/create.json
    To Create a league send a post request to ${CreateLeague_url} using ${headers} with ${create_league_payload} should respond with 200

Start offline draft
    set test variable    ${request_url}     ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail
    &{BeginDraft_payload}   create dictionary     inProgress=true
    A post request to ${request_url} using ${headers} with ${BeginDraft_payload} should respond with 200

Add players to a team
    set test variable    ${addPlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    ${Players_payload}=    Load JSON from file    resource/PlayerList.json
    A post request to ${addPlayer_url} using ${headers} with ${players_payload} should respond with 200

Save the added players to the team
    set test variable    ${request_url}     ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail
    &{CompleteDraft_payload}   create dictionary    drafted=true   inProgress=false
    A post request to ${request_url} using ${headers} with ${CompleteDraft_payload} should respond with 200

Update values to JSON template to swap players
    set test variable    ${Teams_info_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav
    ${response}     GET   url=${Teams_info_url}     headers=${headers}
    ${scoringPeriodId}      get from dictionary    ${response.json()}   scoringPeriodId
    #making global in order to update scoring period for all other json files
    set global variable    ${scoringPeriodId}
    &{swap_players_payload}=    Load JSON from file    resource/SwapPlayer_template.json
    ${save_scoringperiod}    Update value to JSON    ${swap_players_payload}    $.scoringPeriodId  ${scoringPeriodId}
    #Save content to JSON file with indentation (value:2 Tab Space)
    Save JSON to file    ${save_scoringperiod}  resource/SwapPlayer_template.json    2

Swap the position of players and validate the response schema
    set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    Update values to JSON template to swap players
    &{swap_players_payload}=    Load JSON from file    resource/SwapPlayer_template.json
    #if a user wants to move a player in current scoringperiod then type should be roster and for future scoring period type should be future roster
    ${response}         A post request to ${MovePlayer_url} using ${headers} with ${swap_players_payload} should respond with 200
    Move Player Schema from ${response} should be valid
    [Return]    ${response}

#validation to check whether the players positions are swapped
Validate players swapped their positions ${response}
    [Documentation]    whenever we swap players position then player1s "fromLineupSlotId" will be equal to player2s "toLineupSlotId" or player1s "toLineupSlotId" will be equal to player2s "fromLineupSlotId"
    ${Player1s_fromLineupSlotId}  Get value from JSON     ${response.json()}     $.items[0].fromLineupSlotId    #fetching the fromLineupSlotId of player1
    ${Player2s_toLineupSlotId}    Get value from JSON     ${response.json()}    $.items[1].toLineupSlotId       #fetching the toLineupSlotId of player2
    should be equal as integers    ${Player1s_fromLineupSlotId}    ${Player2s_toLineupSlotId}

Update Values to JSON template tp move a player to bench
    ${Move_to_Bench_payload}=    Load JSON from file    resource/MovetoBench_template.json
    ${save_scoringperiod}    Update value to JSON    ${Move_to_Bench_payload}    $.scoringPeriodId  ${scoringPeriodId}
    #Save content to JSON file with indentation (value:2 Tab Space)
    Save JSON to file    ${save_scoringperiod}     resource/MovetoBench_template.json    2

Move any player to bench and validate the response schema
    set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    Update Values to JSON template tp move a player to bench
    ${Move_to_Bench_payload}=    Load JSON from file    resource/MovetoBench_template.json
    #if a user wants to move a player in current scoringperiod then type should be roster and for future scoring period type should be future roster
    ${response}     A post request to ${MovePlayer_url} using ${headers} with ${Move_to_Bench_payload} should respond with 200
    Move Player Schema from ${response} should be valid
    [Return]    ${response}

#validation to check whether the player is moved to bench
Validate player is moved to bench ${response}
    [Documentation]    whenever any player is moved to bench "toLineupSlotId" attribute value will be ${BenchSlotId}
    ${toLineupSlotId}    Get value from JSON    ${response.json()}    $.items[0].toLineupSlotId
    should be equal as integers    ${toLineupSlotId}    ${BenchSlotId}