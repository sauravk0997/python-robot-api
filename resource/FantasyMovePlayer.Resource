*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library             RequestsLibrary
Library             RPA.JSON
Library             Collections
Library             String
Library             OperatingSystem
Library             lib/validators/FantasyMovePlayerValidator.py
Resource            resource/FantasyResource.robot

*** Variables ***
${teaminfo_query_param}                       view=mDraftDetail&view=mTeam&view=mNav&view=mRoster
${BenchSlotId}                                12
${invalid_team_id}                            5
${invalid_player_id}                          12345
${invalid_slot}                               18
${lineup_lock_message}                        Lineup transaction could not be completed, as lineup is locked
#error type for negative scenarios
${same_slot_error_type}                       TRAN_ROSTER_SAME_SLOT
${ineligible_slot_error_type}                 TRAN_ROSTER_INELIGIBLE_SLOT
${Incorrect_type_for_current_scoring}         TRAN_INVALID_SCORINGPERIOD_NOT_FUTURE
${Incorrect_type_for_future_scoring}          TRAN_INVALID_SCORINGPERIOD_NOT_CURRENT
${player_not_on_team_error_type}              TRAN_ROSTER_PLAYER_NOT_ON_ROSTER
${Not_auth_error_type}                        AUTH_UNAUTHORIZED_FOR_TEAM
${team_not_found_error_type}                  TEAM_NOT_FOUND
${general_unknow_error_type}                  GENERAL_UNKNOWN_ERROR

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

Create a Payload to Swap the position of players using ${Players_details_list} on ${roster_type} for the team ${team_id} in the ${scoring period},send a post request and validate the response
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
         ${type}                                     Update value to JSON   ${swap_player_payload}     $.type                                 ${roster_type}
         ${team}                                     Update value to JSON   ${swap_player_payload}     $.teamId                               ${team_id}
         ${scoring_period}                           Update value to JSON   ${swap_player_payload}     $.scoringPeriodId                      ${scoring period}
         Save JSON to file    ${player_id1}                                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player_id2}                                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player1s_from_lineup_slot_id}                resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player2s_from_lineup_slot_id}                resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player1s_to_lineup_slot_id}                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${player2s_to_lineup_slot_id}                  resource/JSON/swap_player_template.json    2
         Save JSON to file    ${type}                                        resource/JSON/swap_player_template.json    2
         Save JSON to file    ${scoring_period}                              resource/JSON/swap_player_template.json    2
         Save JSON to file    ${team}                                        resource/JSON/swap_player_template.json    2
         ${swap_player_response}    A post request to ${MovePlayer_url} using ${header_value} with ${swap_player_payload} should respond with 200
         Move Player Schema from ${swap_player_response} should be valid
         Validate players changed their positions ${swap_player_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Create a Payload to move any lineup player to bench using ${Players_details_list} on ${roster_type} for the team ${team_id} in the ${scoring period},send a post request and validate the response
    ${player_details}       get length    ${Players_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{move_to_bench_payload}        load json from file    resource/JSON/move_to_bench_template.json
        ${player_id}                    Update value to JSON   ${move_to_bench_payload}     $.items[0].playerId                    ${Players_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${move_to_bench_payload}     $.items[0].fromLineupSlotId            ${Players_details_list}[1]
        ${type}                         Update value to JSON   ${move_to_bench_payload}     $.type                                 ${roster_type}
        ${scoring_period}               Update value to JSON   ${move_to_bench_payload}     $.scoringPeriodId                      ${scoring period}
        ${team}                         Update value to JSON   ${move_to_bench_payload}     $.teamId                               ${team_id}
        save json to file    ${player_id}                         resource/JSON/move_to_bench_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/move_to_bench_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/move_to_bench_template.json    2
        save json to file    ${type}                              resource/JSON/move_to_bench_template.json    2
        save json to file    ${team}                              resource/JSON/move_to_bench_template.json    2
        ${lineup_to_bench_response}     A post request to ${MovePlayer_url} using ${header_value} with ${Move_to_Bench_payload} should respond with 200
        Move Player Schema from ${lineup_to_bench_response} should be valid
        Validate player is moved to bench ${lineup_to_bench_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Create a Payload to move the eligible Bench Player to lineup using ${Players_details_list} on ${roster_type} for the team ${team_id} in ${scoring period},send a post request and validate the response
    ${length_of_Eligible_players}    get length    ${Players_details_list}
    IF   ${length_of_Eligible_players} !=0
         &{move_from_bench_to_lineup_payload}          Load JSON from file    resource/JSON/move_from_bench_to_lineup_template.json
         ${player_id}                                  Update value to JSON   ${move_from_bench_to_lineup_payload}     $.items[0].playerId             ${Players_details_list}[0]
         ${lineup_player_id}                           Update value to JSON   ${move_from_bench_to_lineup_payload}     $.items[1].playerId             ${Players_details_list}[1]
         ${slot}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}     $.items[0].toLineupSlotId       ${Players_details_list}[2]
         ${lineup_slot}                                Update value to JSON   ${move_from_bench_to_lineup_payload}     $.items[1].fromLineupSlotId     ${Players_details_list}[2]
         ${type}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}     $.type                          ${roster_type}
         ${team}                                       Update value to JSON   ${move_from_bench_to_lineup_payload}     $.teamId                        ${team_id}
         ${scoring_period}                             Update value to JSON   ${move_from_bench_to_lineup_payload}     $.scoringPeriodId               ${scoring period}
         Save JSON to file    ${player_id}             resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${lineup_player_id}      resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${slot}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${lineup_slot}           resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${type}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         Save JSON to file    ${team}                  resource/JSON/move_from_bench_to_lineup_template.json    2
         ${bench_to_lineup_response}    A post request to ${MovePlayer_url} using ${header_value} with ${move_from_bench_to_lineup_payload} should respond with 200
         Move Player Schema from ${bench_to_lineup_response} should be valid
         Validate players changed their positions ${bench_to_lineup_response}
    ELSE
        Log     ${lineup_lock_message}
    END

Create a Payload using ${Players_details_list} and ${incorrect_slot} for team ${team_id},send a post request which will respond with ${status} and validate the response along with ${error_type}
    ${player_details}               get length    ${players_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{same_slot_payload}            load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${same_slot_payload}         $.items[0].playerId                      ${players_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${same_slot_payload}         $.items[0].fromLineupSlotId              ${players_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${same_slot_payload}         $.items[0].toLineupSlotId                ${incorrect_slot}
        ${type}                         Update value to JSON   ${same_slot_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${same_slot_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${same_slot_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${invalid_slot_response}     A post request to ${MovePlayer_url} using ${header_value} with ${same_slot_payload} should respond with ${status}
        log to console    ${invalid_slot_response.json()}
        Invalid Move Player Schema from ${invalid_slot_response} should be valid
        Validate the ${invalid_slot_response} to contain ${error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Create a Payload using ${invalid_type} for team ${team_id} using ${Players_details_list} and ${scoring period} send a post request and validate the response along with ${error_type}
    ${player_details}               get length    ${Players_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{incorrect_type_current_scoring_payload}        load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].playerId                      ${players_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].fromLineupSlotId              ${players_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].toLineupSlotId                ${players_details_list}[1]
        ${type}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.type                                   ${invalid_type}
        ${scoring_period}               Update value to JSON   ${incorrect_type_current_scoring_payload}         $.scoringPeriodId                        ${scoring period}
        ${team}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${incorrect_type_response}     A post request to ${MovePlayer_url} using ${header_value} with ${incorrect_type_current_scoring_payload} should respond with 409
        log to console    ${incorrect_type_response.json()}
        Invalid Move Player Schema from ${incorrect_type_response} should be valid
        Validate the ${incorrect_type_response} to contain ${error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Swap the position of players of team ${team_id} in a current scoring period and validate the response
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Players_details_list}     Get the Eligible players details who can swap their positions from response  ${team_id}    ${league_info_response.json()}
    Create a Payload to Swap the position of players using ${Players_details_list} on ROSTER for the team ${team_id} in the ${current_scoringPeriodId},send a post request and validate the response

Move any lineup player to bench of ${team_id} in current scoring and validate the response
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Players_details_list}     Get any lineup player details of team ${team_id} from ${league_info_response.json()} to move on bench
    Create a Payload to move any lineup player to bench using ${Players_details_list} on ROSTER for the team ${team_id} in the ${current_scoringPeriodId},send a post request and validate the response

Move the eligible Bench Player of ${team_id} to lineup in current scoring and validate the response
    ${league_info_response}      Get the league details from League_info_url for current scoring Period
    @{Bench_players_details}     Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Players_details_list}      check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
    Create a Payload to move the eligible Bench Player to lineup using ${Players_details_list} on ROSTER for the team ${team_id} in ${current_scoringPeriodId},send a post request and validate the response

Swap the position of players of team ${team_id} in a future scoring period and validate the response
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}        Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{Players_details_list}        Get the Eligible players details who can swap their positions from response  ${team_id}    ${league_info_response.json()}
    Create a Payload to Swap the position of players using ${Players_details_list} on FUTURE_ROSTER for the team ${team_id} in the ${future_scoring_period_id},send a post request and validate the response

Move any lineup player to bench of ${team_id} in future scoring and validate the response
    ${future_scoring_period_id}     Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}         Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{Players_details_list}         Get any lineup player details of team ${team_id} from ${league_info_response.json()}
    Create a Payload to move any lineup player to bench using ${Players_details_list} on FUTURE_ROSTER for the team ${team_id} in the ${future_scoring_period_id},send a post request and validate the response

Move the eligible Bench Player of ${team_id} to lineup in future scoring and validate the response
    ${future_scoring_period_id}      Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}          Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{Bench_players_details}         Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Players_details_list}          check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
    Create a Payload to move the eligible Bench Player to lineup using ${Players_details_list} on FUTURE_ROSTER for the team ${team_id} in ${future_scoring_period_id},send a post request and validate the response

Move any Player of team ${team_id} to same slot and validate the response
    ${league_info_response}    Get the league details from League_info_url for current scoring Period
    @{Players_details_list}     Get any lineup player details of team ${team id} from ${league_info_response.json()}
    ${same_slot}               get from list    ${Players_details_list}     1
    Create a Payload using ${Players_details_list} and ${same_slot} for team ${team_id},send a post request which will respond with 409 and validate the response along with ${same_slot_error_type}

Move any Player of team ${team_id} to ineligible slot and validate the response
    ${league_info_response}    Get the league details from League_info_url for current scoring Period
    @{Players_details_list}     Get any Lineup Player id along with ineligible slot of a player of team ${team id} from the ${league_info_response.json()}
    ${ineligible_slot}         get from list    ${Players_details_list}     2
    Create a Payload using ${Players_details_list} and ${ineligible_slot} for team ${team_id},send a post request which will respond with 409 and validate the response along with ${ineligible_slot_error_type}

Move any Player of team ${team_id} in a current scoring period by providing incorrect type in json payload and validate the response
    ${current_scoring_period_league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Players_details_list}     Get any lineup player details of team ${team id} from ${current_scoring_period_league_info_response.json()}
    Create a Payload using FUTURE_ROSTER for team ${team_id} using ${Players_details_list} and ${current_scoringPeriodId} send a post request and validate the response along with ${Incorrect_type_for_current_scoring}

Move any Player of team ${team_id} in a future scoring period by providing incorrect type in json payload and validate the response
    ${league_info_response}        Get the league details from League_info_url for current scoring Period
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    @{Players_details_list}         Get any lineup player details of team ${team id} from ${league_info_response.json()}
    Create a Payload using ROSTER for team ${team_id} using ${Players_details_list} and ${future_scoring_period_id} send a post request and validate the response along with ${Incorrect_type_for_future_scoring}

Move the player not available on team ${team_id} and validate the response
    ${league_info_response}        Get the league details from League_info_url for current scoring Period
    @{Player_details_list}         Get any lineup player details of team ${team id} from ${league_info_response.json()}
    ${different_team_id}           Get any different team_id
    ${player_details}              get length    ${player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{player_not_on_team_payload}            load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${player_not_on_team_payload}         $.items[0].playerId                      ${player_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${player_not_on_team_payload}         $.items[0].fromLineupSlotId              ${player_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${player_not_on_team_payload}         $.items[0].toLineupSlotId                ${player_details_list}[1]
        ${type}                         Update value to JSON   ${player_not_on_team_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${player_not_on_team_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${player_not_on_team_payload}         $.teamId                                 ${different_team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${player_not_on_team_response}    A post request to ${MovePlayer_url} using ${header_value} with ${player_not_on_team_payload} should respond with 409
        Invalid Move Player Schema from ${player_not_on_team_response} should be valid
        log to console    ${player_not_on_team_response.json()}
        Validate the ${player_not_on_team_response} to contain ${player_not_on_team_error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Move the players of any team ${team_id} as a team owner and validate the response
    ${league_info_response}        Get the league details from League_info_url for current scoring Period
    @{Player_details_list}         Get any lineup player details of team ${team id} from ${league_info_response.json()}
    ${random_number}               generate random string    1    012
    &{header_value}                create dictionary    cookie=${user_cookies}[${random_number}]
    ${player_details}              get length    ${player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{player_not_on_team_payload}            load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${player_not_on_team_payload}         $.items[0].playerId                      ${player_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${player_not_on_team_payload}         $.items[0].fromLineupSlotId              ${player_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${player_not_on_team_payload}         $.items[0].toLineupSlotId                ${player_details_list}[1]
        ${type}                         Update value to JSON   ${player_not_on_team_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${player_not_on_team_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${player_not_on_team_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        set test variable    ${MovePlayer_url}   ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions
        ${team_owner_move_player_other_team_response}    A post request to ${MovePlayer_url} using ${header_value} with ${player_not_on_team_payload} should respond with 401
        Invalid Move Player Schema from ${team_owner_move_player_other_team_response} should be valid
        log to console    ${team_owner_move_player_other_team_response.json()}
        validate the ${team_owner_move_player_other_team_response} to contain ${Not_auth_error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any player to an invalid team ${team_id} and validate the response
    ${current_scoring_period_league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Player_details_list}          Get any lineup player details of team ${team id} from ${current_scoring_period_league_info_response.json()}
    ${player_details}               get length    ${player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{incorrect_type_current_scoring_payload}        load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].playerId                      ${player_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].fromLineupSlotId              ${player_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].toLineupSlotId                ${player_details_list}[1]
        ${type}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${incorrect_type_current_scoring_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.teamId                                 ${invalid_team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${invalid_team_response}     A post request to ${MovePlayer_url} using ${header_value} with ${incorrect_type_current_scoring_payload} should respond with 409
        log to console    ${invalid_team_response.json()}
        Invalid Move Player Schema from ${invalid_team_response} should be valid
        Validate the ${invalid_team_response} to contain ${team_not_found_error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any invalid player to team ${team_id} and validate the response
    ${current_scoring_period_league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Player_details_list}          Get any lineup player details of team ${team id} from ${current_scoring_period_league_info_response.json()}
    ${player_details}               get length    ${player_details_list}
    IF    ${player_details} != 0
    # creating a payload and sending a post request to move a lineup player to bench
        &{incorrect_type_current_scoring_payload}        load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].playerId                      ${invalid_player_id}
        ${from_lineup_slot_id}          Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].fromLineupSlotId              ${player_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].toLineupSlotId                ${player_details_list}[1]
        ${type}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${incorrect_type_current_scoring_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${invalid_player_response}     A post request to ${MovePlayer_url} using ${header_value} with ${incorrect_type_current_scoring_payload} should respond with 500
        log to console    ${invalid_player_response.json()}
        Invalid Move Player Schema from ${invalid_player_response} should be valid
        Validate the ${invalid_player_response} to contain ${general_unknow_error_type}
    ELSE
        Log     ${lineup_lock_message}
    END

Move any player of team ${team_id} to invalid slot and validate the response
    ${current_scoring_period_league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Players_details_list}          Get any lineup player details of team ${team id} from ${current_scoring_period_league_info_response.json()}
    Create a Payload using ${Players_details_list} and ${invalid_slot} for team ${team_id},send a post request which will respond with 500 and validate the response along with ${general_unknow_error_type}

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