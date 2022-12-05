*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library             RequestsLibrary
Library             RPA.JSON
Library             Collections
Library             String
Library             OperatingSystem
Library             lib/validators/FantasyMovePlayerValidator.py

*** Variables ***
${fantasy_url}                   https://fantasy.espn.com
${BASEBALL_SPORT}                fba
${SEASON}                        2023
${SEGMENT}                       0
${teaminfo_query_param}          view=mDraftDetail&view=mTeam&view=mNav&view=mRoster
${BenchSlotId}                   12
${lineup_lock_message}           Lineup transaction could not be completed, as lineup is locked
${same_slot_error_type}          TRAN_ROSTER_SAME_SLOT
${ineligible_slot_error_type}    TRAN_ROSTER_INELIGIBLE_SLOT

*** Keywords ***
#Post request for Performing various transactions like move,add,delete,drop..etc
A post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${header}     json=${payload}    expected_status=${status}
    [Return]        ${response}

Get the league details from League_info_url for current scoring Period
        set test variable    ${League_info_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?${teaminfo_query_param}
        ${league_info_response}         GET   url=${League_info_url}     headers=${header_value}
        ${current_scoringPeriodId}      get from dictionary  ${league_info_response.json()}      scoringPeriodId
        ${final_scoringPeriodId}        get value from json  ${league_info_response.json()}      $. status.finalScoringPeriod
        #making global in order to use whenever required in the testcases
        set global variable        ${current_scoringPeriodId}
        set global variable        ${final_scoringPeriodId}
        [Return]        ${league_info_response}

Get the league details of any from League_info_url for any future scoring period ${futurescoring_period_id}
     set test variable    ${League_info_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?scoringPeriodId=${futurescoring_period_id}&view=mRoster
     ${league_info_response}         GET   url=${League_info_url}     headers=${header_value}
     [Return]        ${league_info_response}

Get any different team_id
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    ${team_id}                  get any different team id from response   ${league_info_response.json()}    ${SWID}
    [Return]    ${team_id}

Swap the position of players of team ${team_id} in a current scoring period and validate the response
    ${current_scoring_period_league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Players_details_list}                            Get the Eligible players details who can swap their positions from response  ${team_id}    ${current_scoring_period_league_info_response.json()}
    ${len_player_details}       get length    ${Players_details_list}
    IF   ${len_player_details} !=0
         # creating a payload and sending a post request to swap players
         &{swap_player_payload}                      Load JSON from file    resource/JSON/swap_player_template.json
         ${player_id1}                               Update value to JSON   ${swap_player_payload}     $.items[0].playerId                    ${Players_details_list}[0]
         ${player_id2}                               Update value to JSON   ${swap_player_payload}     $.items[1].playerId                    ${Players_details_list}[1]
         ${player1s_from_lineup_slot_id}             Update value to JSON   ${swap_player_payload}     $.items[0].fromLineupSlotId            ${Players_details_list}[2]
         ${player2s_from_lineup_slot_id}             Update value to JSON   ${swap_player_payload}     $.items[1].fromLineupSlotId            ${Players_details_list}[3]
         ${player1s_to_lineup_slot_id}               Update value to JSON   ${swap_player_payload}     $.items[1].toLineupSlotId              ${Players_details_list}[2]
         ${player2s_to_lineup_slot_id}               Update value to JSON   ${swap_player_payload}     $.items[0].toLineupSlotId              ${Players_details_list}[3]
         ${type}                                     Update value to JSON   ${swap_player_payload}     $.type                                 ROSTER
         ${team}                                     Update value to JSON   ${swap_player_payload}     $.teamId                               ${team_id}
         ${scoring_period}                           Update value to JSON   ${swap_player_payload}      $.scoringPeriodId                     ${current_scoringPeriodId}
         Save JSON to file    ${player_id1}                                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player_id2}                                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player1s_from_lineup_slot_id}                resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player2s_from_lineup_slot_id}                resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player1s_to_lineup_slot_id}                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player2s_to_lineup_slot_id}                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${type}                                        resource/JSON/swap_player_template.json    2
         Save JSON to file    ${scoring_period}                              resource/JSON/swap_player_template.json    2
         Save JSON to file    ${team}                                        resource/JSON/swap_player_template.json    2
         set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
         ${swap_player_response}    A post request to ${MovePlayer_url} using ${header_value} with ${swap_player_payload} should respond with 200
         Move Player Schema from ${swap_player_response} should be valid
         Validate players changed their positions ${swap_player_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any lineup player to bench of ${team_id} in current scoring and validate the response
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{values}   Get any lineup player details of team ${team_id} from ${league_info_response.json()} to move on bench
    ${player_details}       get length    ${values}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{move_to_bench_payload}        load json from file    resource/JSON/move_to_bench_template.json
        ${player_id}                    Update value to JSON   ${move_to_bench_payload}     $.items[0].playerId                    ${values}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${move_to_bench_payload}     $.items[0].fromLineupSlotId            ${values}[1]
        ${type}                         Update value to JSON   ${move_to_bench_payload}     $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${move_to_bench_payload}     $.scoringPeriodId                      ${current_scoringPeriodId}
        ${team}                         Update value to JSON    ${move_to_bench_payload}     $.teamId                               ${team_id}
        save json to file    ${player_id}                         resource/JSON/move_to_bench_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/move_to_bench_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/move_to_bench_template.json    2
        save json to file    ${type}                              resource/JSON/move_to_bench_template.json    2
        save json to file    ${team}                              resource/JSON/move_to_bench_template.json    2
        set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
        ${lineup_to_bench_response}     A post request to ${MovePlayer_url} using ${header_value} with ${Move_to_Bench_payload} should respond with 200
        Move Player Schema from ${lineup_to_bench_response} should be valid
        Validate player is moved to bench ${lineup_to_bench_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move the eligible Bench Player of ${team_id} to lineup in current scoring and validate the response
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Bench_players_details}    Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Eligible_players_details}      check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
    ${length_of_Eligible_players}    get length    ${Eligible_players_details}
    IF   ${length_of_Eligible_players} !=0
         &{move_from_bench_to_lineup_payload}          Load JSON from file    resource/JSON/move_from_bench_to_lineup_template.json
         ${player_id}                                  Update value to JSON   ${move_from_bench_to_lineup_payload}      $.items[0].playerId             ${Eligible_players_details}[0]
         ${lineup_player_id}                           Update value to JSON   ${move_from_bench_to_lineup_payload}     $.items[1].playerId     ${Eligible_players_details}[1]
         ${slot}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}      $.items[0].toLineupSlotId      ${Eligible_players_details}[2]
         ${lineup_slot}                                Update value to JSON   ${move_from_bench_to_lineup_payload}      $.items[1].fromLineupSlotId    ${Eligible_players_details}[2]
         ${type}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}      $.type                                   ROSTER
         ${team}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}      $.teamId                               ${team_id}
         ${scoring_period}                             Update value to JSON   ${move_from_bench_to_lineup_payload}     $.scoringPeriodId           ${current_scoringPeriodId}
         Save JSON to file    ${player_id}             resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${lineup_player_id}      resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${slot}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${lineup_slot}           resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${type}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${team}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
         ${bench_to_lineup_response}    A post request to ${MovePlayer_url} using ${header_value} with ${move_from_bench_to_lineup_payload} should respond with 200
         Move Player Schema from ${bench_to_lineup_response} should be valid
         Validate players changed their positions ${bench_to_lineup_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Swap the position of players of team ${team_id} in a future scoring period and validate the response
    Get the league details from League_info_url for current scoring Period
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}        Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{Players_details_list}        Get the Eligible players details who can swap their positions from response  ${team_id}    ${league_info_response.json()}
    ${len_player_details}          get length    ${Players_details_list}
    IF   ${len_player_details} !=0
         # creating a payload and sending a post request to swap players
         &{swap_player_payload}                      Load JSON from file    resource/JSON/swap_player_template.json
         ${player_id1}                               Update value to JSON   ${swap_player_payload}     $.items[0].playerId                    ${Players_details_list}[0]
         ${player_id2}                               Update value to JSON   ${swap_player_payload}     $.items[1].playerId                    ${Players_details_list}[1]
         ${player1s_from_lineup_slot_id}             Update value to JSON   ${swap_player_payload}     $.items[0].fromLineupSlotId            ${Players_details_list}[2]
         ${player2s_from_lineup_slot_id}             Update value to JSON   ${swap_player_payload}     $.items[1].fromLineupSlotId            ${Players_details_list}[3]
         ${player1s_to_lineup_slot_id}               Update value to JSON   ${swap_player_payload}     $.items[1].toLineupSlotId              ${Players_details_list}[2]
         ${player2s_to_lineup_slot_id}               Update value to JSON   ${swap_player_payload}     $.items[0].toLineupSlotId              ${Players_details_list}[3]
         ${type}                                     Update value to JSON   ${swap_player_payload}     $.type                                 FUTURE_ROSTER
         ${team}                                     Update value to JSON   ${swap_player_payload}     $.teamId                               ${team_id}
         ${scoring_period}                           Update value to JSON   ${swap_player_payload}      $.scoringPeriodId                     ${future_scoring_period_id}
         Save JSON to file    ${player_id1}                                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player_id2}                                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player1s_from_lineup_slot_id}                resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player2s_from_lineup_slot_id}                resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player1s_to_lineup_slot_id}                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player2s_to_lineup_slot_id}                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${type}                                        resource/JSON/swap_player_template.json    2
         Save JSON to file    ${scoring_period}                              resource/JSON/swap_player_template.json    2
         Save JSON to file    ${team}                                        resource/JSON/swap_player_template.json    2
         set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
         ${swap_player_response}    A post request to ${MovePlayer_url} using ${header_value} with ${swap_player_payload} should respond with 200
         Move Player Schema from ${swap_player_response} should be valid
         Validate players changed their positions ${swap_player_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any lineup player to bench of ${team_id} in future scoring and validate the response
    ${future_scoring_period_id}     Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}         Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{lineup_player_details_list}   Get any lineup player details of team ${team_id} from ${league_info_response.json()}
    ${player_details}               get length    ${lineup_player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{move_to_bench_payload}        load json from file    resource/JSON/move_to_bench_template.json
        ${player_id}                    Update value to JSON   ${move_to_bench_payload}     $.items[0].playerId                    ${lineup_player_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${move_to_bench_payload}     $.items[0].fromLineupSlotId            ${lineup_player_details_list}[1]
        ${type}                         Update value to JSON   ${move_to_bench_payload}     $.type                                 FUTURE_ROSTER
        ${scoring_period}               Update value to JSON   ${move_to_bench_payload}     $.scoringPeriodId                      ${future_scoring_period_id}
        ${team}                         Update value to JSON    ${move_to_bench_payload}     $.teamId                              ${team_id}
        save json to file    ${player_id}                         resource/JSON/move_to_bench_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/move_to_bench_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/move_to_bench_template.json    2
        save json to file    ${type}                              resource/JSON/move_to_bench_template.json    2
        save json to file    ${team}                              resource/JSON/move_to_bench_template.json    2
        set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
        ${lineup_to_bench_response}     A post request to ${MovePlayer_url} using ${header_value} with ${Move_to_Bench_payload} should respond with 200
        Move Player Schema from ${lineup_to_bench_response} should be valid
        Validate player is moved to bench ${lineup_to_bench_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move the eligible Bench Player of ${team_id} to lineup in future scoring and validate the response
    ${future_scoring_period_id}      Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}          Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{Bench_players_details}         Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Eligible_players_details}      check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
    ${length_of_Eligible_players}    get length    ${Eligible_players_details}
    IF   ${length_of_Eligible_players} !=0
         &{move_from_bench_to_lineup_payload}          Load JSON from file    resource/JSON/move_from_bench_to_lineup_template.json
         ${player_id}                                  Update value to JSON   ${move_from_bench_to_lineup_payload}      $.items[0].playerId             ${Eligible_players_details}[0]
         ${lineup_player_id}                           Update value to JSON   ${move_from_bench_to_lineup_payload}     $.items[1].playerId              ${Eligible_players_details}[1]
         ${slot}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}      $.items[0].toLineupSlotId       ${Eligible_players_details}[2]
         ${lineup_slot}                                Update value to JSON   ${move_from_bench_to_lineup_payload}      $.items[1].fromLineupSlotId     ${Eligible_players_details}[2]
         ${type}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}      $.type                          FUTURE_ROSTER
         ${team}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}      $.teamId                        ${team_id}
         ${scoring_period}                             Update value to JSON   ${move_from_bench_to_lineup_payload}     $.scoringPeriodId                ${future_scoring_period_id}
         Save JSON to file    ${player_id}             resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${lineup_player_id}      resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${slot}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${lineup_slot}           resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${type}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${team}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
         ${bench_to_lineup_response}    A post request to ${MovePlayer_url} using ${header_value} with ${move_from_bench_to_lineup_payload} should respond with 200
         Move Player Schema from ${bench_to_lineup_response} should be valid
         Validate players changed their positions ${bench_to_lineup_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any Player of team ${team_id} to same slot and validate the response
    ${league_info_response}    Get the league details from League_info_url for current scoring Period
    @{Player_details_list}     Get any lineup player details of team ${team id} from ${league_info_response.json()}
    ${player_details}               get length    ${player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{same_slot_payload}        load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${same_slot_payload}         $.items[0].playerId                      ${player_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${same_slot_payload}         $.items[0].fromLineupSlotId              ${player_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${same_slot_payload}         $.items[0].toLineupSlotId                ${player_details_list}[1]
        ${type}                         Update value to JSON   ${same_slot_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${same_slot_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${same_slot_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
        ${same_slot_response}     A post request to ${MovePlayer_url} using ${header_value} with ${same_slot_payload} should respond with 409
        log to console    ${same_slot_response.json()}
        Invalid Move Player Schema from ${same_slot_response} should be valid
        Validate the ${same_slot_response} to contain ${same_slot_error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any Player of team ${team_id} to ineligible slot and validate the response
    ${league_info_response}    Get the league details from League_info_url for current scoring Period
    @{Player_details_list}     Get any Lineup Player id along with ineligible slot of a player of team ${team id} from the ${league_info_response.json()}
    ${player_details}               get length    ${player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{Ineligible_slot_payload}        load json from file     resource/JSON/Invalid_move_player_template.json
        ${player_id}                      Update value to JSON    ${Ineligible_slot_payload}         $.items[0].playerId                      ${player_details_list}[0]
        ${from_lineup_slot_id}            Update value to JSON    ${Ineligible_slot_payload}         $.items[0].fromLineupSlotId              ${player_details_list}[1]
        ${to_lineup_slot_id}              Update value to JSON    ${Ineligible_slot_payload}         $.items[0].toLineupSlotId                ${player_details_list}[2]
        ${type}                           Update value to JSON    ${Ineligible_slot_payload}         $.type                                   ROSTER
        ${scoring_period}                 Update value to JSON    ${Ineligible_slot_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                           Update value to JSON    ${Ineligible_slot_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/
        ${ineligible_slot_response}     A post request to ${MovePlayer_url} using ${header_value} with ${Ineligible_slot_payload} should respond with 409
        log to console    ${ineligible_slot_response.json()}
        Invalid Move Player Schema from ${ineligible_slot_response} should be valid
        Validate the ${ineligible_slot_response} to contain ${ineligible_slot_error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

#validation to check whether the players positions are swapped
Validate players changed their positions ${response}
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

Validate the ${response} to contain ${error type}
     [Documentation]    whenever any send incorrect data in json payload response will throw error
     ${error_type_from_response}      Get value from JSON    ${response.json()}    $.details[0].type
     should be equal    ${error_type_from_response}     ${error_type}