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
${create_league_url}             ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues?createAsTypeId=2
${teaminfo_query_param}          view=mDraftDetail&view=mTeam&view=mNav&view=mRoster
${user_cookie}                   SWID={95096766-E11A-4C94-BB21-2BA8F8C0D3EF}; espn_s2=AECrGNEO5w1VlDOoJEgL1wquDjPrYr1r0XR9A5zJln93t968%2BICfJi3k32jhzzwTZpEzvBWbOf0%2FFx0ObwGqatXTiooE1n3SkjICYmcbiqCYUJjHQp6e9JyUT67qTYAVlmpWwiir8Auj6AMyk5Du%2BySpeboBjJLUm%2BPGsk7ajvLy26t8PgyzWpnbM8EzazCCLqAkeLNjEe1PdV6%2FmHj9t2fZgfusdIAns%2FpsBtgNQtBnzwhFUhrJ6JvyLFF0syVwv%2FGszPfVEzIwfOtXGHbSkdsI3WlAqQc61wm6q%2BkLeUxVnw%3D%3D;
@{user_emails}                   test_api1@gmail.com    test_api2@gmail.com    test_api4@gmail.com
#@{INVITATION_LIST}    create    list
@{INVITATION_LIST}
#user cookies
${user1_cookie}                  SWID={AC5DB45D-C80A-4B64-A7DA-D25B83936E45}; espn_s2=AEAnq02o%2BmcWRL1vB2%2FQj5gYOwu8ZYEFzj97kPkEJjWrX2JqZlhAukxaSf308PGzqXta9uldsBHyoxAVPWhOQsrAp%2F4xMl%2BDl07zjL6xh8jjmmUjwzHjcLdMwM%2Bfh1XEDU%2BzC0v5pICJf2HGtMcMmum6utt88mNEYMh%2Fm%2BixxrkKndc4ae%2BxOT3YHlMG1JLX5CoL9fFAh0gFPcFOpOXggZApDQ12t2%2BuZs4DYMsn8dVEnJGBooFXljha0tGH%2BJuvw2sjrJsxLYfSPJ%2BghS5pb%2F67m9bx9UqakBStk2%2F74%2FFezA%3D%3D;
${user2_cookie}                  SWID={6EBEDA15-DD50-4FE1-8D90-C545FA0FC4CB}; espn_s2=AEAx73D5mfBaX6wHYeaQvFZUVpH4EXKkfEkN01oNUw8CQ69qMq6eLixM39zMMRS6N%2FC1qYxRES3RqE2xZ8uyJFUW1H6qCSyN52AyNGFrOWIVIYPEgobJN%2F39yZ6K5jMvqe1ej7autxNulTn%2BzhuIQvs7ignT5uieYKxO0Sp8mv3wgPjgsocSdGfmB%2FrE%2B7zJIUSdpYQeTGxX4qfge5v8Q3otf1xRhHCjrG4j8bMvAwgR1wwE7hXjzUFayYxPf%2FueNRyamAApfbl44PgVYyivc0iGrc4LQze%2FrJZquazy2IXvtw%3D%3D;
${user3_cookie}                  SWID={E3272EB1-815C-4FEB-8165-748347B78631}; espn_s2=AECtI0H4%2FD%2B0yBHczkmtSxsDTfNlK%2BrjIlvOpmEAYGA%2FKq43Sb4iZQlXh5IHOJsfCIIE6aZ7lNbqw8QZ2WFCwX9bP5hn4es5ozLtCUZ%2FeDEPzfxZ%2FpbRvSNRTmlsVbqZGcnK3nj4GvpRm0F84IYRSxeSzDJpVlrSKqHOvfI1IpfJjMousk%2B1Cj%2BvYZQ8g2dSIUF0FAlqft3muCyNb3c%2B7PJfU3EDmVdSRbQDti5muduaBacxUi8jpQvZRC5Rblr0TA6d1J2xvNbcGfQyMmCZuIIrW478ok0A%2B%2Butr5774Dkt6g%3D%3D;
@{user_cookies}                  ${user1_cookie}    ${user2_cookie}    ${user3_cookie}
@{user_cookies_reverse}          ${user3_cookie}    ${user2_cookie}    ${user1_cookie}
@{member_ids}                    AC5DB45D-C80A-4B64-A7DA-D25B83936E45    6EBEDA15-DD50-4FE1-8D90-C545FA0FC4CB    E3272EB1-815C-4FEB-8165-748347B78631
${BROWSER}                       Chrome
${user}                          test_api@gmail.com
${password}                      test_api
${greeting}                      TestUser!
${BenchSlotId}                   12
${lineup_lock_message}           Lineup transaction could not be completed, as lineup is locked
${league_creator_swid}           {95096766-E11A-4C94-BB21-2BA8F8C0D3EF}

*** Keywords ***
#Post request for creating a legaue
Invoke league create api ${endpoint} using cookie ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${headers}     json=${payload}    expected_status=${status}
    ${leagueid}      get from dictionary    ${response.json()}  id
    ${invite_id}    Get COPY TO CLIPBOARD invite id    ${response.json()}
    Set Global Variable    ${invite_id}
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

Get a Fantasy League details
    Intialize user cookie and Create a league
    Send Invitations, Accept Invitation send by inviter and Create teams
    Start offline draft
    Add players to all teams as league creator user and save the roster

Intialize user cookie and Create a league
    &{headers}  create dictionary    cookie=${user_cookie}
    set global variable    ${headers}
    ${create_league_payload}=    Load JSON from file    resource/create.json
    Invoke league create api ${create_league_url} using cookie ${headers} with ${create_league_payload} should respond with 200


Start offline draft
    set suite variable    ${offline_draft_begin_url}     ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail
    &{BeginDraft_payload}   create dictionary     inProgress=true
    A post request to ${offline_draft_begin_url} using ${headers} with ${BeginDraft_payload} should respond with 200

Send Invitations, Accept Invitation send by inviter and Create teams
    [Documentation]    Invokes Members Accept API endpoint.
    Validate Invitation Accept, Team Creation endpoints responds with successful status code

Validate Invitation Accept, Team Creation endpoints responds with successful status code
    [Documentation]    Accept League Invite sent by inviter, fetch team id, update team information, invoke team creation API endpoint and validate the response schema
    #Member Invitation Accept for all 3 users
    FOR    ${index}    IN RANGE    0    3
        &{league_invite_accept_json_template}=    Load JSON from file    resource/leagueInviteAccept.json
        ${id_updated}=    Update value to JSON    ${league_invite_accept_json_template}    $.id   ${invite_id}
        Save JSON to file    ${id_updated}    resource/leagueInviteAccept.json    2
        &{header_user_cookie}    Create Dictionary    cookie=${user_cookies}[${index}]
        #Make post request and send json payload to accept invitation -
        ${memberInvitationAccepation}=    POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}/invites/${invite_id}?memberId={${member_ids}[${index}]}&join=true    headers=${headers}    json=${league_invite_accept_json_template}       expected_status=201
        #fetch team id
        ${team_id}=    Get value from JSON    ${memberInvitationAccepation.json()}    $.teamId
        &{team_create_json_template}=    Load JSON from file    resource/teamCreateTemplate.json
        #Team abbreviation update
        ${team_abbreviation_updated}=    Update value to JSON    ${team_create_json_template}    $.abbrev   FL${index}
        Save JSON to file    ${team_abbreviation_updated}    resource/teamCreateTemplate.json    2
        #Team nickname update
        ${nick_name_updated}=    Update value to JSON    ${team_create_json_template}    $.nickname   FN${index}
        Save JSON to file    ${nick_name_updated}    resource/teamCreateTemplate.json    2
        #Team location update
        ${location_updated}=    Update value to JSON    ${team_create_json_template}    $.location   FTM${index}
        Save JSON to file    ${location_updated}    resource/teamCreateTemplate.json    2
        #Team create API invocation
        ${team_response}=     POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}/teams/${team_id}   headers=${headers}     json=${team_create_json_template}   expected_status=200
    END

Add players to all teams as league creator user and save the roster
    &{offline_draft_save_json_template}=     Load JSON from file    resource/offlineDraftSave.json
    FOR    ${index}    IN RANGE    1    5
        &{offline_draft_teams_json_template}=     Load JSON from file    resource/offlineDraftTeam${index}.json
        ${offline_draft_team1_response}=     POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/   headers=${headers}    json=${offline_draft_teams_json_template}     expected_status=200
    END
    ${offline_draft_save_response}=     POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail  headers=${headers}    json=${offline_draft_save_json_template}     expected_status=200

Delete the created league
    [Documentation]    Invoke delete API endpoint to delete the created league
    #Delete call to delete the created league
    ${delete_response}=     DELETE    url= ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}  headers=${headers}     expected_status=204

Swap the position of players of team ${team_id} in a current scoring period and validate the response
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{values}      Get the Eligible players details who can swap their positions from response  ${team_id}    ${league_info_response.json()}
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
     &{headers}  create dictionary    cookie=${user_cookie}
    set global variable    ${headers}
    ${league_info_response}     Get the league details from League_info_url for current scoring Period
    @{Bench_players_details}    Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Eligible_players_details}      check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
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
         ${type}            Update value to JSON   ${payload1}      $.type                                   ROSTER
         ${team}            Update value to JSON   ${payload1}      $.teamId                               ${team_id}
         ${scoring_period}  Update value to JSON   ${payload1}      $.scoringPeriodId           ${current_scoringPeriodId}
         Save JSON to file    ${player_id}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${lineup_player_id}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${slot}     resource/move-from-bench-to-lineup-template.json    2
         Save JSON to file    ${lineup_slot}     resource/move-from-bench-to-lineup-template.json    2
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
    &{headers}  create dictionary    cookie=${user_cookie}
    Set Global Variable    ${headers}
    Get the league details from League_info_url for current scoring Period
    ${future_scoring_period_id}    Generate a random future scoring period between ${current_scoringPeriodId} and ${final_scoringPeriodId}
    ${league_info_response}     Get the league details of any from League_info_url for any future scoring period ${future_scoring_period_id}
    @{values}      Get the Eligible players details who can swap their positions from response  ${team_id}    ${league_info_response.json()}
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
    Save JSON to file    ${scoring_period}     resource/swapplayer_template.json    2
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
    @{Bench_players_details}       Get the bench players details of team ${team_id} from ${league_info_response.json()}
    @{Eligible_players_details}    check for ${Bench_players_details} eligibility of team ${team_id} for moving to lineup from ${league_info_response.json()}
    IF    ${team_id} == 0
      ${team_id}  evaluate    ${team_id} + 1
      set global variable   ${team_id}
    END
    &{payload1}=    Load JSON from file    resource/move-from-bench-to-lineup-template.json
    ${player_id}    Update value to JSON   ${payload1}     $.items[0].playerId             ${Eligible_players_details}[0]
    ${lineup_player_id}     Update value to JSON   ${payload1}     $.items[1].playerId     ${Eligible_players_details}[1]
    ${slot}         Update value to JSON   ${payload1}      $.items[0].toLineupSlotId      ${Eligible_players_details}[2]
    Save JSON to file    ${slot}     resource/move-from-bench-to-lineup-template.json    2
    ${lineup_slot}  Update value to JSON   ${payload1}      $.items[1].fromLineupSlotId    ${Eligible_players_details}[2]
    Save JSON to file    ${lineup_slot}     resource/move-from-bench-to-lineup-template.json    2
    ${scoring_period}  Update value to JSON   ${payload1}      $.scoringPeriodId           ${future_scoring_period_id}
    ${type}            Update value to JSON   ${payload1}     $.type                                 FUTURE_ROSTER
    ${team}            Update value to JSON   ${payload1}     $.teamId                     ${team_id}
    Save JSON to file    ${player_id}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${lineup_player_id}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${slot}     resource/move-from-bench-to-lineup-template.json    2
    Save JSON to file    ${lineup_slot}     resource/move-from-bench-to-lineup-template.json    2
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