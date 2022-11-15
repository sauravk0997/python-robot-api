*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library    RequestsLibrary
Library    RPA.JSON
Library    Collections
Library    String
Library    OperatingSystem



*** Variables ***
${HOMEPAGE}             https://www.espn.com/fantasy/
${CreateLeague_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues?createAsTypeId=2
${LeagueInvite_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/invites?copyLMOnInvite=false&notifyUnjoined=false
${LeagueInvitationAccept_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/invites/{leagueInviteId}?memberId=BC6305D7-5A17-4840-B231-8D34D45B1DCB&join=true
${TeamCreate_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/teams/{teamId}
${OfflineDraftStarting_url}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/draftDetail
${Teams_info_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav
${Transaction_url}   https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/transactions/     #This is the common url which will be perfoming different action like adding player,moving players..etc Based on the Json payload we send
${BROWSER}      Chrome
${user}         test_api@gmail.com
${password}     test_api
${greeting}     TestUser!



*** Keywords ***
#Post request for creating a legaue
To Create a league send a post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${headers}     json=${payload}    expected_status=${status}
    ${leagueid}      get from dictionary    ${response.json()}  id
    set global variable     ${leagueid}               #getting the league id value and setting itglobal so that it can used whenever required

#Post request for Performing various transactions like move,add,delete,drop..etc
A post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${header}     json=${payload}    expected_status=${status}
    [Return]    ${response}

Create a League        #For Moving a player Required a Fantasy league instead of assuming and hardcoding a leagueid created a tesst league without any validation and also to create league with all validations will be covered by CSEAUTO-28333 once its completed this test case be removed
    &{headers}  create dictionary    cookie=SWID={95096766-E11A-4C94-BB21-2BA8F8C0D3EF}; espn_s2=AECrGNEO5w1VlDOoJEgL1wquDjPrYr1r0XR9A5zJln93t968%2BICfJi3k32jhzzwTZpEzvBWbOf0%2FFx0ObwGqatXTiooE1n3SkjICYmcbiqCYUJjHQp6e9JyUT67qTYAVlmpWwiir8Auj6AMyk5Du%2BySpeboBjJLUm%2BPGsk7ajvLy26t8PgyzWpnbM8EzazCCLqAkeLNjEe1PdV6%2FmHj9t2fZgfusdIAns%2FpsBtgNQtBnzwhFUhrJ6JvyLFF0syVwv%2FGszPfVEzIwfOtXGHbSkdsI3WlAqQc61wm6q%2BkLeUxVnw%3D%3D;
    set global variable    ${headers}
    ${create_league_payload}=    Load JSON from file    resource/create.json
    To Create a league send a post request to ${CreateLeague_url} using ${headers} with ${create_league_payload} should respond with 200

Start Offline Draft                 #For Moving a player Required a Fantasy league with offline drafting startegy instead of assuming and hardcoding created a league with offline draft strategy without any validation and also to create a league with offline strategy along with the validations will be covered by CSEAUTO-28333 once its completed this test case be removed
    set test variable    ${request_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/draftDetail
    &{BeginDraft_payload}   create dictionary     inProgress=true
    A post request to ${request_url} using ${headers} with ${BeginDraft_payload} should respond with 200

Add Players to a team               #For Moving a player Required a Fantasy league and a team with players instead of assuming and hardcoding a team with players created a test case to add players to a team without any validation and also to add players with all validations will be covered by CSEAUTO-28331 once its completed this test case be removed
    set test variable    ${addPlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    ${Players_payload}=    Load JSON from file    resource/PlayerList.json
    A post request to ${addPlayer_url} using ${headers} with ${players_payload} should respond with 200

After adding players save the team   #For Moving a player Required a Fantasy league and a team with players instead of assuming and hardcoding a team with players created a test case to add players to a team without any validation and also to add players with all validations will be covered by CSEAUTO-28331 once its completed this test case be removed
    set test variable    ${request_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/draftDetail
    &{CompleteDraft_payload}   create dictionary    drafted=true   inProgress=false
    A post request to ${request_url} using ${headers} with ${CompleteDraft_payload} should respond with 200

Update/Add values to swapplayerlist jsontemplate file
    set test variable    ${Teams_info_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav
    ${response}     GET   url=${Teams_info_url}     headers=${headers}
    ${scoringPeriodId}      get from dictionary    ${response.json()}   scoringPeriodId
    set global variable    ${scoringPeriodId}    #making global in order to update scoring period for all othe json files
    &{swap_players_payload}=    Load JSON from file    resource/SwapPlayer_template.json
    ${save_scoringperiod}    Update value to JSON    ${swap_players_payload}    $.scoringPeriodId  ${scoringPeriodId}
    Save JSON to file    ${save_scoringperiod}  resource/SwapPlayer_template.json


Send a Post Request to swap the position of players
    set test variable    ${MovePlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    Update/Add values to swapplayerlist jsontemplate file
    &{swap_players_payload}=    Load JSON from file    resource/SwapPlayer_template.json
    #if a user wants to move a player in current scoringperiod then type should be roster and for future scoring period type should be future roster
    ${response}         A post request to ${MovePlayer_url} using ${headers} with ${swap_players_payload} should respond with 200
    [Return]    ${response}

#validation to check whether the players positions are swapped
Validate ${response} to check whether the players have swapped their positions
    [Documentation]    whenever we swap players position then player1's "fromLineupSlotId" will be equal to player2's "toLineupSlotId" or player1's "toLineupSlotId" will be equal to player2's "fromLineupSlotId"
    ${Player1s_fromLineupSlotId}  Get value from JSON     ${response.json()}     $.items[0].fromLineupSlotId    #fetching the fromLineupSlotId of player1
    ${Player2s_toLineupSlotId}    Get value from JSON     ${response.json()}    $.items[1].toLineupSlotId       #fetching the toLineupSlotId of player2
    should be equal as integers    ${Player1s_fromLineupSlotId}    ${Player2s_toLineupSlotId}

Update/Add Values to Move to bench jsontemplate file
    ${Move_to_Bench_payload}=    Load JSON from file    resource/MovetoBench_template.json
    ${save_scoringperiod}    Update value to JSON    ${Move_to_Bench_payload}    $.scoringPeriodId  ${scoringPeriodId}
    Save JSON to file    ${save_scoringperiod}     resource/MovetoBench_template.json

Send a Post Request to Move any Player to Bench
    set test variable    ${MovePlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    Update/Add Values to Move to bench jsontemplate file
    ${Move_to_Bench_payload}=    Load JSON from file    resource/MovetoBench_template.json
    #if a user wants to move a player in current scoringperiod then type should be roster and for future scoring period type should be future roster
    ${response}     A post request to ${MovePlayer_url} using ${headers} with ${Move_to_Bench_payload} should respond with 200
    [Return]    ${response}

#validation to check whether the player is moved to bench
Validate ${response} to check whether the player is moved to Bench
    [Documentation]    whenever any player is moved to bench "toLineupSlotId" attribute value will be 12
    ${toLineupSlotId}    Get value from JSON    ${response.json()}    $.items[0].toLineupSlotId
    should be equal as integers    ${toLineupSlotId}    12




