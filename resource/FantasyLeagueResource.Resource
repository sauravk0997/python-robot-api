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
${teaminfo_query_param}           view=mDraftDetail&view=mTeam&view=mNav&view=mRoster
${user_cookie}                    SWID={95096766-E11A-4C94-BB21-2BA8F8C0D3EF}; espn_s2=AECrGNEO5w1VlDOoJEgL1wquDjPrYr1r0XR9A5zJln93t968%2BICfJi3k32jhzzwTZpEzvBWbOf0%2FFx0ObwGqatXTiooE1n3SkjICYmcbiqCYUJjHQp6e9JyUT67qTYAVlmpWwiir8Auj6AMyk5Du%2BySpeboBjJLUm%2BPGsk7ajvLy26t8PgyzWpnbM8EzazCCLqAkeLNjEe1PdV6%2FmHj9t2fZgfusdIAns%2FpsBtgNQtBnzwhFUhrJ6JvyLFF0syVwv%2FGszPfVEzIwfOtXGHbSkdsI3WlAqQc61wm6q%2BkLeUxVnw%3D%3D;
${BROWSER}                        Chrome
${user}                           test_api@gmail.com
${password}                       test_api
${greeting}                       TestUser!
${BenchSlotId}                    12
${lineup_lock_message}            Lineup transaction could not be completed, as lineup is locked
${leagueid}                       1221281732
${league_creator_swid}            {95096766-E11A-4C94-BB21-2BA8F8C0D3EF}

*** Keywords ***
#Post request for creating a legaue
Invoke league create api ${endpoint} using cookie ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${headers}     json=${payload}    expected_status=${status}
    ${leagueid}      get from dictionary    ${response.json()}  id
    #getting the league id value and setting it global, so that it can used whenever required
    set global variable     ${leagueid}

#Post request for Performing various transactions like move,add,delete,drop..etc
A post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${header}     json=${payload}    expected_status=${status}
    [Return]    ${response}

Get the league details from League_info_url for current scoring Period
        set test variable    ${League_info_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?${teaminfo_query_param}
        ${league_info_response}         GET   url=${League_info_url}     headers=${headers}
        ${current_scoringPeriodId}      get from dictionary  ${league_info_response.json()}      scoringPeriodId
        ${final_scoringPeriodId}        get value from json  ${league_info_response.json()}      $. status.finalScoringPeriod
        #making global in order to use whenever required in the testcases
        set global variable        ${current_scoringPeriodId}
        set global variable        ${final_scoringPeriodId}
        [Return]        ${league_info_response}

Get the league details of any from League_info_url for any future scoring period ${id}
     set test variable    ${League_info_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?scoringPeriodId=${id}&view=mRoster
     ${league_info_response}         GET   url=${League_info_url}     headers=${headers}
     [Return]        ${league_info_response}

Intialize user cookie and Create a league
    &{headers}  create dictionary    cookie=${user_cookie}
    set global variable    ${headers}
    ${create_league_payload}=    Load JSON from file    resource/create.json
    Invoke league create api ${create_league_url} using cookie ${headers} with ${create_league_payload} should respond with 200


Start offline draft
    set test variable    ${offline_draft_begin_url}     ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail
    &{BeginDraft_payload}   create dictionary     inProgress=true
    A post request to ${offline_draft_begin_url} using ${headers} with ${BeginDraft_payload} should respond with 200

Add players to a team
    set test variable    ${addPlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    ${Players_payload}=    Load JSON from file    resource/PlayerList.json
    A post request to ${addPlayer_url} using ${headers} with ${players_payload} should respond with 200

Save the added players to the team
    set test variable    ${save_team_url}     ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail
    &{CompleteDraft_payload}   create dictionary    drafted=true   inProgress=false
    A post request to ${save_team_url} using ${headers} with ${CompleteDraft_payload} should respond with 200

Swap the position of players of ${team_id} in current scoring period and validate the response schema and check whether the players changed their positions
    &{headers}  create dictionary    cookie=${user_cookie}
    set global variable    ${headers}
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{values}      Get the Eligible players details who can swap their positions from response  ${current_scoringPeriodId}    ${team_id}    ${league_info_response.json()}
    ${player_details}       get length    ${values}
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    IF   ${player_details} !=0
         # creating a payload and sending a post request to swap players
         &{swap_player_payload}=       Load JSON from file    resource/swapplayer_template.json
         ${player_id1}      Update value to JSON   ${swap_player_payload}     $.items[0].playerId                    ${values}[0]
         ${player_id2}      Update value to JSON   ${swap_player_payload}     $.items[1].playerId                    ${values}[1]
         ${id1}             Update value to JSON   ${swap_player_payload}     $.items[0].fromLineupSlotId            ${values}[2]
         ${id2}             Update value to JSON   ${swap_player_payload}     $.items[1].toLineupSlotId              ${values}[2]
         ${id3}             Update value to JSON   ${swap_player_payload}     $.items[0].toLineupSlotId              ${values}[3]
         ${id4}             Update value to JSON   ${swap_player_payload}     $.items[1].fromLineupSlotId            ${values}[3]
         ${type}            Update value to JSON   ${swap_player_payload}     $.type                                 ROSTER
         ${team}            Update value to JSON   ${swap_player_payload}     $.teamId                               ${team_id}
         ${scoring_period}  Update value to JSON   ${swap_player_payload}      $.scoringPeriodId                     ${current_scoringPeriodId}
         Save JSON to file    ${player_id1}     resource/swapplayer_template.json    2
         Save JSON to file    ${player_id2}     resource/swapplayer_template.json    2
         Save JSON to file    ${id1}            resource/swapplayer_template.json    2
         Save JSON to file    ${id2}            resource/swapplayer_template.json    2
         Save JSON to file    ${id3}            resource/swapplayer_template.json    2
         Save JSON to file    ${id4}            resource/swapplayer_template.json    2
         Save JSON to file    ${type}            resource/swapplayer_template.json    2
         Save JSON to file    ${scoring_period}    resource/swapplayer_template.json     2
         Save JSON to file    ${team}     resource/swapplayer_template.json    2
         set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
         ${swap_player_response}    A post request to ${MovePlayer_url} using ${headers} with ${swap_player_payload} should respond with 200
         Move Player Schema from ${swap_player_response} should be valid
         Validate players changed their positions   ${swap_player_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any lineup player to bench of ${team_id} in current scoring period and validate the response schema and check whether the player is moved to bench
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{values}   Get any random lineup player details of team ${team_id} from ${league_info_response.json()} to move on bench
    ${player_details}       get length    ${values}
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{move_to_bench_payload}        load json from file    resource/movetobench_template.json
        ${player_id1}      Update value to JSON   ${move_to_bench_payload}     $.items[0].playerId                    ${values}[0]
        ${id1}             Update value to JSON   ${move_to_bench_payload}     $.items[0].fromLineupSlotId            ${values}[1]
        ${type}            Update value to JSON   ${move_to_bench_payload}     $.type                                   ROSTER
        ${scoring_period}  Update value to JSON   ${move_to_bench_payload}     $.scoringPeriodId                      ${current_scoringPeriodId}
        ${team}            Update value to JSON    ${move_to_bench_payload}     $.teamId                               ${team_id}
        save json to file    ${player_id1}        resource/movetobench_template.json    2
        save json to file    ${id1}               resource/movetobench_template.json    2
        save json to file    ${scoring_period}    resource/movetobench_template.json    2
        save json to file    ${type}    resource/movetobench_template.json    2
        save json to file    ${team}    resource/movetobench_template.json    2
        set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
        ${lineup_to_bench_response}     A post request to ${MovePlayer_url} using ${headers} with ${Move_to_Bench_payload} should respond with 200
        Move Player Schema from ${lineup_to_bench_response} should be valid
        Validate player is moved to bench ${lineup_to_bench_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move the eligible Bench Player of ${team_id} to lineup in current scoring period and validate the response schema and check whether the players changed their positions
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Bench_players_details}    Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Eligible_players_details}      check for ${Bench_players_details} eligibility for moving to lineup from ${league_info_response.json()}
    ${length_of_Eligible_players}    get length    ${Eligible_players_details}
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    IF   ${length_of_Eligible_players} !=0
         &{payload1}=    Load JSON from file    resource/move-from-bench-to-lineup-template.json
         ${player_id}    Update value to JSON   ${payload1}     $.items[0].playerId             ${Eligible_players_details}[0]
         ${lineup_player_id}     Update value to JSON   ${payload1}     $.items[1].playerId     ${Eligible_players_details}[1]
         ${slot}         Update value to JSON   ${payload1}      $.items[0].toLineupSlotId      ${Eligible_players_details}[2]
         ${lineup_slot}  Update value to JSON   ${payload1}      $.items[1].fromLineupSlotId    ${Eligible_players_details}[2]
         ${id}           Update value to JSON     ${payload1}      $.items[0].fromLineupSlotId    12
         ${id1}          Update value to JSON     ${payload1}      $.items[1].toLineupSlotId     12
         ${type}            Update value to JSON   ${payload1}      $.type                                   ROSTER
         ${team}            Update value to JSON   ${payload1}      $.teamId                               ${team_id}
         ${scoring_period}  Update value to JSON   ${payload1}      $.scoringPeriodId           ${current_scoringPeriodId}
         Save JSON to file    ${player_id}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${lineup_player_id}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${slot}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${lineup_slot}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${id}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${id1}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${type}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${team}     resource/move-from-bench-to-lineup-template.json    2
         set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
         ${bench_to_lineup_response}    A post request to ${MovePlayer_url} using ${headers} with ${payload1} should respond with 200
         Move Player Schema from ${bench_to_lineup_response} should be valid
         Validate players changed their positions   ${bench_to_lineup_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Swap the position of players of ${team_id} in future scoring period and validate the response schema
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}     Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{values}      Get the Eligible players details who can swap their positions from response  ${future_scoring_period_id}    ${team_id}    ${league_info_response.json()}
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    # creating a payload and sending a post request to swap players
    &{swap_player_payload}=       Load JSON from file    resource/swapplayer_template.json
    ${player_id1}      Update value to JSON   ${swap_player_payload}     $.items[0].playerId                    ${values}[0]
    ${player_id2}      Update value to JSON   ${swap_player_payload}     $.items[1].playerId                    ${values}[1]
    ${id1}             Update value to JSON   ${swap_player_payload}     $.items[0].fromLineupSlotId            ${values}[2]
    ${id2}             Update value to JSON   ${swap_player_payload}     $.items[1].toLineupSlotId              ${values}[2]
    ${id3}             Update value to JSON   ${swap_player_payload}     $.items[0].toLineupSlotId              ${values}[3]
    ${id4}             Update value to JSON   ${swap_player_payload}     $.items[1].fromLineupSlotId            ${values}[3]
    ${type}            Update value to JSON   ${swap_player_payload}     $.type                                 FUTURE_ROSTER
    ${team}            Update value to JSON   ${swap_player_payload}     $.teamId                               ${team_id}
    ${scoring_period}  Update value to JSON   ${swap_player_payload}      $.scoringPeriodId                     ${future_scoring_period_id}
    Save JSON to file    ${player_id1}     resource/swapplayer_template.json    2
    Save JSON to file    ${player_id2}     resource/swapplayer_template.json    2
    Save JSON to file    ${id1}            resource/swapplayer_template.json    2
    Save JSON to file    ${id2}            resource/swapplayer_template.json    2
    Save JSON to file    ${id3}            resource/swapplayer_template.json    2
    Save JSON to file    ${id4}            resource/swapplayer_template.json    2
    Save JSON to file    ${scoring_period}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${type}       resource/swapplayer_template.json    2
    save json to file    ${team}     resource/swapplayer_template.json      2
    set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    ${swap_player_response}    A post request to ${MovePlayer_url} using ${headers} with ${swap_player_payload} should respond with 200
    Move Player Schema from ${swap_player_response} should be valid
    [Return]     ${swap_player_response}

Move any lineup player to bench of ${team_id} in future scoring period and validate the response schema
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}        Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{values}   Get any random lineup player details of team ${team_id} from ${league_info_response.json()} to move on bench
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    &{move_to_bench_payload}        load json from file    resource/movetobench_template.json
    ${player_id1}      Update value to JSON   ${move_to_bench_payload}     $.items[0].playerId                    ${values}[0]
    ${id1}             Update value to JSON   ${move_to_bench_payload}     $.items[0].fromLineupSlotId            ${values}[1]
    ${type}            Update value to JSON   ${move_to_bench_payload}     $.type                                 FUTURE_ROSTER
    ${team}            Update value to JSON   ${move_to_bench_payload}     $.teamId                               ${team_id}
    ${scoring_period}  Update value to JSON   ${move_to_bench_payload}     $.scoringPeriodId                      ${future_scoring_period_id}
    save json to file    ${player_id1}    resource/movetobench_template.json    2
    save json to file    ${id1}           resource/movetobench_template.json    2
    Save JSON to file    ${type}          resource/movetobench_template.json    2
    set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    ${lineup_to_bench_response}     A post request to ${MovePlayer_url} using ${headers} with ${Move_to_Bench_payload} should respond with 200
    Move Player Schema from ${lineup_to_bench_response} should be valid
    [Return]    ${lineup_to_bench_response}

Move the eligible Bench Player of ${team_id} to lineup in future scoring period and validate the response schema
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}        Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{Bench_players_details}    Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Eligible_players_details}      check for ${Bench_players_details} eligibility for moving to lineup from ${league_info_response.json()}
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    &{payload1}=    Load JSON from file    resource/move-from-bench-to-lineup-template.json
    ${player_id}    Update value to JSON   ${payload1}     $.items[0].playerId             ${Eligible_players_details}[0]
    ${lineup_player_id}     Update value to JSON   ${payload1}     $.items[1].playerId     ${Eligible_players_details}[1]
    ${slot}         Update value to JSON   ${payload1}      $.items[0].toLineupSlotId      ${Eligible_players_details}[2]
    ${lineup_slot}  Update value to JSON   ${payload1}      $.items[1].fromLineupSlotId    ${Eligible_players_details}[2]
    ${id}           Update value to JSON     ${payload1}      $.items[0].fromLineupSlotId    12
    ${id1}          Update value to JSON     ${payload1}      $.items[1].toLineupSlotId     12
    ${scoring_period}  Update value to JSON   ${payload1}      $.scoringPeriodId           ${future_scoring_period_id}
    ${type}            Update value to JSON   ${payload1}     $.type                                 FUTURE_ROSTER
    ${team}            Update value to JSON   ${payload1}     $.teamId                     ${team_id}
    Save JSON to file    ${player_id}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${lineup_player_id}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${slot}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${lineup_slot}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${id}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${id1}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${type}        resource/move-from-bench-to-lineup-template.json      2
    Save JSON to file    ${team}        resource/move-from-bench-to-lineup-template.json      2
    set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
    ${bench_to_lineup_response}    A post request to ${MovePlayer_url} using ${headers} with ${payload1} should respond with 200
    Move Player Schema from ${bench_to_lineup_response} should be valid
    [Return]    ${bench_to_lineup_response}

#validation to check whether the players positions are swapped
Validate players changed their positions
    [Arguments]       ${response}
    [Documentation]    whenever we swap players position then player1s "fromLineupSlotId" will be equal to player2s "toLineupSlotId" or player1s "toLineupSlotId" will be equal to player2s "fromLineupSlotId"
    #fetching the fromLineupSlotId of player1
    ${Player1s_fromLineupSlotId}  Get value from JSON     ${response.json()}     $.items[0].fromLineupSlotId
    #fetching the toLineupSlotId of player2
    ${Player2s_toLineupSlotId}    Get value from JSON     ${response.json()}    $.items[1].toLineupSlotId
    should be equal as integers    ${Player1s_fromLineupSlotId}    ${Player2s_toLineupSlotId}

#validation to check whether the player is moved to bench
Validate player is moved to bench ${response}
    [Documentation]    whenever any player is moved to bench "toLineupSlotId" attribute value will be ${BenchSlotId}
    ${toLineupSlotId}    Get value from JSON    ${response.json()}    $.items[0].toLineupSlotId
    should be equal as integers    ${toLineupSlotId}    ${BenchSlotId}

Get any different team_id
     &{headers}  create dictionary    cookie=${user_cookie}
     Set Global Variable    ${headers}
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    ${team_id}      get any different team id from response   ${league_info_response.json()}    ${league_creator_swid}
    [Return]    ${team_id}

Get any different team_id from future scoring period
    ${id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}     Get the league details of any from League_info_url for any future scoring period ${id}
    ${team_id}      get any different team id from response   ${league_info_response.json()}    ${league_creator_swid}
    [Return]    ${team_id}