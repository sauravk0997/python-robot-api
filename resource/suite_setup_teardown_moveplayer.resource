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

*** Keywords ***
Get a Fantasy League details
    [Documentation]    Create - ESPN Fantasy League and teams creation and adding players to team
    Intialize user cookie and Create a league
    Send Invitations, Accept Invitation send by inviter and Create teams
    Start offline draft
    Add players to all teams as league creator user and save the roster

Intialize user cookie and Create a league
    [Documentation]     fetches user cookies and creates a legue
    &{headers}  create dictionary    cookie=${user_cookie}
    set global variable    ${headers}
    ${create_league_payload}=    Load JSON from file    resource/JSON/create.json
    Invoke league create api ${create_league_url} using cookie ${headers} with ${create_league_payload} should respond with 200

Invoke league create api ${endpoint} using cookie ${header} with ${payload} should respond with ${status}
    [Documentation]    Invokes League create API endpoint to create a league
    ${response}       POST    url=${endpoint}   headers=${headers}     json=${payload}    expected_status=${status}
    ${leagueid}       GET FROM DICTIONARY    ${response.json()}  id
    ${invite_id}      Get COPY TO CLIPBOARD invite id    ${response.json()}
    #getting the league id value and setting it global, so that it can used whenever required
    Set Global Variable    ${invite_id}
    set global variable     ${leagueid}

Start offline draft
    [Documentation]    Invoke offline draft API endpoint to start offline draft
    set suite variable      ${offline_draft_begin_url}     ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail
    &{BeginDraft_payload}   create dictionary     inProgress=true
    ${response}     POST    url=${offline_draft_begin_url}   headers=${headers}     json=${BeginDraft_payload}    expected_status=200

Send Invitations, Accept Invitation send by inviter and Create teams
    [Documentation]    Invokes Members Accept API endpoint.
    Validate Invitation Accept, Team Creation endpoints responds with successful status code

Validate Invitation Accept, Team Creation endpoints responds with successful status code
    [Documentation]    Accept League Invite sent by inviter, fetch team id, update team information, invoke team creation API endpoint and validate the response schema
    #Member Invitation Accept for all 3 users
    FOR    ${index}    IN RANGE    0    3
        &{league_invite_accept_json_template}    Load JSON from file    resource/JSON/leagueInviteAccept.json
        ${id_updated}=                           Update value to JSON    ${league_invite_accept_json_template}    $.id   ${invite_id}
        Save JSON to file    ${id_updated}    resource/JSON/leagueInviteAccept.json    2
        #Make post request and send json payload to accept invitation -
        ${memberInvitationAccepation}    POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}/invites/${invite_id}?memberId={${member_ids}[${index}]}&join=true    headers=${headers}    json=${league_invite_accept_json_template}       expected_status=201
        #fetch team id
        ${team_id}                       Get value from JSON    ${memberInvitationAccepation.json()}    $.teamId
        &{team_create_json_template}=    Load JSON from file    resource/JSON/teamCreateTemplate.json
        #Team abbreviation update
        ${team_abbreviation_updated}=    Update value to JSON    ${team_create_json_template}    $.abbrev     FL${index}
        #Team nickname update
        ${nick_name_updated}=            Update value to JSON    ${team_create_json_template}    $.nickname   FN${index}
        #Team location update
        ${location_updated}=             Update value to JSON    ${team_create_json_template}    $.location   FTM${index}
        Save JSON to file    ${team_abbreviation_updated}     resource/JSON/teamCreateTemplate.json    2
        Save JSON to file    ${nick_name_updated}             resource/JSON/teamCreateTemplate.json    2
        Save JSON to file    ${location_updated}              resource/JSON/teamCreateTemplate.json    2
        &{header_user_cookie}            Create Dictionary    cookie=${user_cookies}[${index}]
        #Team create API invocation
        ${team_response}=     POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}/teams/${team_id}   headers=${headers}     json=${team_create_json_template}   expected_status=200
    END

Add players to all teams as league creator user and save the roster
    &{offline_draft_save_json_template}=         Load JSON from file    resource/JSON/offlineDraftSave.json
    FOR    ${index}    IN RANGE    1    5
        &{offline_draft_teams_json_template}     Load JSON from file    resource/JSON/offlineDraftTeam${index}.json
        ${offline_draft_team1_response}          POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/   headers=${headers}    json=${offline_draft_teams_json_template}     expected_status=200
    END
    ${offline_draft_save_response}               POST    url=${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/draftDetail  headers=${headers}    json=${offline_draft_save_json_template}     expected_status=200

Delete the created league
    [Documentation]    Invoke delete API endpoint to delete the created league
    #Delete call to delete the created league
    ${delete_response}=     DELETE    url= ${fantasy_url}/apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}  headers=${headers}     expected_status=204