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
${BENCH_SLOT_ID}                              12
${INVALID_TEAM_ID}                            5
${INVALID_PLAYER_ID}                          12345
${INVALID_SLOT}                               18
${LINEUP_LOCK_MESSAGE}                        Lineup transaction could not be completed, as lineup is locked
#error type for negative scenarios
${SAME_SLOT_ERROR_TYPE}                       TRAN_ROSTER_SAME_SLOT
${INELIGIBLE_SLOT_ERROR_TYPE}                 TRAN_ROSTER_INELIGIBLE_SLOT
${INCORRECT_TYPE_FOR_CURRENT_SCORING}         TRAN_INVALID_SCORINGPERIOD_NOT_FUTURE
${INCORRECT_TYPE_FOR_FUTURE_SCORING}          TRAN_INVALID_SCORINGPERIOD_NOT_CURRENT
${PLAYER_NOT_ON_TEAM_ERROR_TYPE}              TRAN_ROSTER_PLAYER_NOT_ON_ROSTER
${NOT_AUTH_ERROR_TYPE}                        AUTH_UNAUTHORIZED_FOR_TEAM
${TEAM_NOT_FOUND_ERROR_TYPE}                  TEAM_NOT_FOUND
${GENERAL_UNKNOWN_ERROR_TYPE}                 GENERAL_UNKNOWN_ERROR

*** Keywords ***
#Post request for Performing various transactions like move,add,delete,drop..etc
A post request to ${endpoint} using ${header} and ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${header}     json=${payload}    expected_status=${status}
    [Return]        ${response}

Get the league details
    set test variable    ${League_info_url}   ${FANTASY_URL}/apis/v3/games/${BASKETBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?${teaminfo_query_param}
    ${league_info_response}         GET   url=${League_info_url}     headers=${header_value}
    ${current_scoringPeriodId}      get from dictionary  ${league_info_response.json()}      scoringPeriodId
    ${final_scoringPeriodId}        get value from json  ${league_info_response.json()}      $. status.finalScoringPeriod
    #making global in order to use whenever required in the testcases
    set global variable        ${current_scoringPeriodId}
    set global variable        ${final_scoringPeriodId}
    [Return]        ${league_info_response}

Get the team details in ${future_scoring_period}
     set test variable    ${team_details_url}   ${FANTASY_URL}/apis/v3/games/${BASKETBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}?scoringPeriodId=${future_scoring_period}&view=mRoster
     ${team_details_response}         GET   url=${team_details_url}     headers=${header_value}
     [Return]        ${team_details_response}

Get any different team_id
    ${league_info_response}     Get the league details
    ${team_id}                  get any different team id from response   ${league_info_response.json()}    ${SWID}
    [Return]    ${team_id}

Create a Payload to Swap the position of players using ${Players_details_list} on ${roster_type} for the team ${team_id} in the ${scoring period},send a post request and validate the response
    ${len_player_details}       get length    ${Players_details_list}
    IF   ${len_player_details} !=0
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
         ${swap_player_response}    A post request to ${MovePlayer_url} using ${header_value} and ${swap_player_payload} should respond with 200
         Move Player Schema from ${swap_player_response} should be valid
         Validate players changed their positions ${swap_player_response}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

Create a Payload to move any lineup player to bench using ${Players_details_list} on ${roster_type} for the team ${team_id} in the ${scoring period},send a post request and validate the response
    ${player_details}       get length    ${Players_details_list}
    IF  ${player_details} != 0
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
        ${lineup_to_bench_response}     A post request to ${MovePlayer_url} using ${header_value} and ${Move_to_Bench_payload} should respond with 200
        Move Player Schema from ${lineup_to_bench_response} should be valid
        Validate player is moved to bench ${lineup_to_bench_response}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

Create a Payload to move any eligible Bench Player to lineup using ${Players_details_list} on ${roster_type} for the team ${team_id} in ${scoring period},send a post request and validate the response
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
         ${bench_to_lineup_response}    A post request to ${MovePlayer_url} using ${header_value} and ${move_from_bench_to_lineup_payload} should respond with 200
         Move Player Schema from ${bench_to_lineup_response} should be valid
         Validate players changed their positions ${bench_to_lineup_response}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

Create a Payload using ${Players_details_list} and ${incorrect_slot} for team ${team_id},send a post request which will respond with ${status} and validate the response along with ${error_type}
    ${player_details}               get length    ${players_details_list}
    IF    ${player_details} != 0
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
        ${invalid_slot_response}     A post request to ${MovePlayer_url} using ${header_value} and ${same_slot_payload} should respond with ${status}
        Invalid Move Player Schema from ${invalid_slot_response} should be valid
        Validate the ${invalid_slot_response} to contain ${error_type}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

Create a Payload for ${invalid_type} using ${Players_details_list} for team ${team_id} in ${scoring period} send a post request and validate the response along with ${error_type}
    ${player_details}               get length    ${Players_details_list}
    IF    ${player_details} != 0
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
        ${incorrect_type_response}     A post request to ${MovePlayer_url} using ${header_value} and ${incorrect_type_current_scoring_payload} should respond with 409
        Invalid Move Player Schema from ${incorrect_type_response} should be valid
        Validate the ${incorrect_type_response} to contain ${error_type}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

Create a Payload using ${Players_details_list} and ${incorrect_team},send a post request and validate the response along with ${error_type}
    ${player_details}               get length    ${Players_details_list}
    IF    ${player_details} != 0
        &{incorrect_type_current_scoring_payload}        load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].playerId                      ${Players_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].fromLineupSlotId              ${Players_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].toLineupSlotId                ${Players_details_list}[1]
        ${type}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${incorrect_type_current_scoring_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.teamId                                 ${incorrect_team}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${invalid_team_response}     A post request to ${MovePlayer_url} using ${header_value} and ${incorrect_type_current_scoring_payload} should respond with 409
        Invalid Move Player Schema from ${invalid_team_response} should be valid
        Validate the ${invalid_team_response} to contain ${error_type}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

create a payload to move any invalid player using ${Players_details_list} in team ${team_id},send post request and validate the response along with error type
    ${player_details}               get length    ${Players_details_list}
    IF    ${player_details} != 0
        &{incorrect_type_current_scoring_payload}        load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].playerId                      ${INVALID_PLAYER_ID}
        ${from_lineup_slot_id}          Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].fromLineupSlotId              ${Players_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${incorrect_type_current_scoring_payload}         $.items[0].toLineupSlotId                ${Players_details_list}[1]
        ${type}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${incorrect_type_current_scoring_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${incorrect_type_current_scoring_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${invalid_player_response}     A post request to ${MovePlayer_url} using ${header_value} and ${incorrect_type_current_scoring_payload} should respond with 500
        Invalid Move Player Schema from ${invalid_player_response} should be valid
        Validate the ${invalid_player_response} to contain ${GENERAL_UNKNOWN_ERROR_TYPE}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

create a payload to move players of different team ${team_id} as a team owner using ${Players_details_list} and ${team_owner_cookie},send post request and validate the response along with error type
    ${player_details}              get length    ${Players_details_list}
    IF    ${player_details} != 0
        &{player_not_on_team_payload}            load json from file    resource/JSON/Invalid_move_player_template.json
        ${player_id}                    Update value to JSON   ${player_not_on_team_payload}         $.items[0].playerId                      ${Players_details_list}[0]
        ${from_lineup_slot_id}          Update value to JSON   ${player_not_on_team_payload}         $.items[0].fromLineupSlotId              ${Players_details_list}[1]
        ${to_lineup_slot_id}            Update value to JSON   ${player_not_on_team_payload}         $.items[0].toLineupSlotId                ${Players_details_list}[1]
        ${type}                         Update value to JSON   ${player_not_on_team_payload}         $.type                                   ROSTER
        ${scoring_period}               Update value to JSON   ${player_not_on_team_payload}         $.scoringPeriodId                        ${current_scoring_period_id}
        ${team}                         Update value to JSON   ${player_not_on_team_payload}         $.teamId                                 ${team_id}
        save json to file    ${player_id}                         resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${from_lineup_slot_id}               resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${to_lineup_slot_id}                 resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${scoring_period}                    resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${type}                              resource/JSON/Invalid_move_player_template.json    2
        save json to file    ${team}                              resource/JSON/Invalid_move_player_template.json    2
        ${team_owner_move_player_other_team_response}    A post request to ${MovePlayer_url} using ${team_owner_cookie} and ${player_not_on_team_payload} should respond with 401
        Invalid Move Player Schema from ${team_owner_move_player_other_team_response} should be valid
        validate the ${team_owner_move_player_other_team_response} to contain ${Not_auth_error_type}
    ELSE
        Log     ${LINEUP_LOCK_MESSAGE}
    END

Move the players of any team ${team_id} as a team owner and validate the response
    ${league_info_response}    Get the league details
    @{Players_details_list}    Get any lineup player details of team ${team id} from ${league_info_response.json()}
    ${random_number}    generate random string    1    123
    ${decremented_index}    Evaluate    ${random_number}-1
    ${any_other_team_owner_cookie}    Create Dictionary    cookie=${cookies}[${decremented_index}]
    create a payload to move players of different team ${team_id} as a team owner using ${Players_details_list} and ${any_other_team_owner_cookie},send post request and validate the response along with error type

Move any invalid player to team ${team_id} and validate the response
    ${league_info_response}     Get the league details
    @{Players_details_list}     Get any lineup player details of team ${team id} from ${league_info_response.json()}
    create a payload to move any invalid player using ${Players_details_list} in team ${team_id},send post request and validate the response along with error type

Swap the position of players of team ${team_id} in a current scoring period and validate the response
    ${league_info_response}     Get the league details
    @{Players_details_list}     Get the Eligible players details who can swap their positions from response  ${team_id}    ${league_info_response.json()}
    Create a Payload to Swap the position of players using ${Players_details_list} on ROSTER for the team ${team_id} in the ${current_scoringPeriodId},send a post request and validate the response

Move any lineup player to bench of ${team_id} in current scoring and validate the response
    ${league_info_response}        Get the league details
    @{Players_details_list}        Get any lineup player details of team ${team_id} from ${league_info_response.json()}
    Create a Payload to move any lineup player to bench using ${Players_details_list} on ROSTER for the team ${team_id} in the ${current_scoringPeriodId},send a post request and validate the response

Move the eligible Bench Player of ${team_id} to lineup in current scoring and validate the response
    ${league_info_response}        Get the league details
    @{Bench_players_details}       Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Players_details_list}        check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
    Create a Payload to move any eligible Bench Player to lineup using ${Players_details_list} on ROSTER for the team ${team_id} in ${current_scoringPeriodId},send a post request and validate the response

Swap the position of players of team ${team_id} in a future scoring period and validate the response
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}        Get the league details
    ${team_info_response}          Get the team details in ${future_scoring_period_id}
    @{Players_details_list}        Get the Eligible players details who can swap their positions from response  ${team_id}    ${team_info_response.json()}
    Create a Payload to Swap the position of players using ${Players_details_list} on FUTURE_ROSTER for the team ${team_id} in the ${future_scoring_period_id},send a post request and validate the response

Move any lineup player to bench of ${team_id} in future scoring and validate the response
    ${future_scoring_period_id}     Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}         Get the league details
    ${team_info_response}          Get the team details in ${future_scoring_period_id}
    @{Players_details_list}         Get any lineup player details of team ${team_id} from ${team_info_response.json()}
    Create a Payload to move any lineup player to bench using ${Players_details_list} on FUTURE_ROSTER for the team ${team_id} in the ${future_scoring_period_id},send a post request and validate the response

Move the eligible Bench Player of ${team_id} to lineup in future scoring and validate the response
    ${future_scoring_period_id}      Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}          Get the league details
    ${team_info_response}          Get the team details in ${future_scoring_period_id}
    @{Bench_players_details}         Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Players_details_list}          check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${team_info_response.json()}
    Create a Payload to move any eligible Bench Player to lineup using ${Players_details_list} on FUTURE_ROSTER for the team ${team_id} in ${future_scoring_period_id},send a post request and validate the response

Move any Player of team ${team_id} to same slot and validate the response
    ${league_info_response}    Get the league details
    @{Players_details_list}    Get any Lineup Player id along with ineligible slot of a player of team ${team id} from the ${league_info_response.json()}
    ${same_slot}               get from list    ${Players_details_list}     1
    Create a Payload using ${Players_details_list} and ${same_slot} for team ${team_id},send a post request which will respond with 409 and validate the response along with ${SAME_SLOT_ERROR_TYPE}

Move any Player of team ${team_id} to ineligible slot and validate the response
    ${league_info_response}    Get the league details
    @{Players_details_list}    Get any Lineup Player id along with ineligible slot of a player of team ${team id} from the ${league_info_response.json()}
    ${ineligible_slot}         get from list    ${Players_details_list}     2
    Create a Payload using ${Players_details_list} and ${ineligible_slot} for team ${team_id},send a post request which will respond with 409 and validate the response along with ${INELIGIBLE_SLOT_ERROR_TYPE}

Move any Player of team ${team_id} in a current scoring period by providing incorrect type in json payload and validate the response
    ${league_info_response}     Get the league details
    @{Players_details_list}     Get any lineup player details of team ${team id} from ${league_info_response.json()}
    Create a Payload for FUTURE_ROSTER using ${Players_details_list} for team ${team_id} in ${current_scoringPeriodId} send a post request and validate the response along with ${INCORRECT_TYPE_FOR_CURRENT_SCORING}

Move any Player of team ${team_id} in a future scoring period by providing incorrect type in json payload and validate the response
    ${league_info_response}        Get the league details
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    @{Players_details_list}        Get any lineup player details of team ${team id} from ${league_info_response.json()}
    Create a Payload for ROSTER using ${Players_details_list} for team ${team_id} in ${future_scoring_period_id} send a post request and validate the response along with ${INCORRECT_TYPE_FOR_FUTURE_SCORING}

Move the player not available on team ${team_id} and validate the response
    ${league_info_response}        Get the league details
    @{Players_details_list}        Get any lineup player details of team ${team id} from ${league_info_response.json()}
    ${different_team_id}           Get any different team_id
    Create a Payload using ${Players_details_list} and ${different_team_id},send a post request and validate the response along with ${PLAYER_NOT_ON_TEAM_ERROR_TYPE}

Move any player to an invalid team ${team_id} and validate the response
    ${league_info_response}     Get the league details
    @{Players_details_list}     Get any lineup player details of team ${team id} from ${league_info_response.json()}
    Create a Payload using ${Players_details_list} and ${INVALID_TEAM_ID} ,send a post request and validate the response along with ${TEAM_NOT_FOUND_ERROR_TYPE}

Move any player of team ${team_id} to invalid slot and validate the response
    ${league_info_response}     Get the league details
    @{Players_details_list}     Get any lineup player details of team ${team id} from ${league_info_response.json()}
    Create a Payload using ${Players_details_list} and ${INVALID_SLOT} for team ${team_id},send a post request which will respond with 500 and validate the response along with ${GENERAL_UNKNOWN_ERROR_TYPE}

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
    should be equal as integers    ${toLineupSlotId}    ${BENCH_SLOT_ID}

Validate the ${response} to contain ${error type}
     [Documentation]    whenever any send incorrect data in json payload response will throw error
     ${error_type_from_response}      Get value from JSON    ${response.json()}    $.details[0].type
     should be equal    ${error_type_from_response}     ${error_type}