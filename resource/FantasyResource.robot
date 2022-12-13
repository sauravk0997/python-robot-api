*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             DateTime
Library             RPA.JSON
Library             Collections
Library             String
Library             lib/validators/FantasyCreateLeagueValidator.py
Library             lib/fantasyUI/FantasyUtils.py
Resource            resource/sel-based-login.robot


*** Variables ***
${TOKEN}=    %7B6E458CFC-7B0E-4811-8B3D-504CF5F7D4C0%7D
${QUERY_PARAM}=    displayHiddenPrefs=true&context=fantasy&useCookieAuth=true&source=fantasyapp-ios&featureFlags=challengeEntries
${API_BASE}=        https://fan.api.espn.com/apis/v2/fans/${TOKEN}?${QUERY_PARAM}
${FANTASY_BASE_URL}    https://fantasy.espn.com
${BASEBALL_SPORT}    fba
${SEASON}    2023
${SEGMENT}    0
${LEAGUES_SLUG}          apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues
${LEAGUE_CREATE_SLUG}    ${LEAGUES_SLUG}?createAsTypeId=2
${MEMBER_INVITE_SLUG}     invites?copyLMOnInvite=false&notifyUnjoined=false
${DRAFT_SETTINGS_SLUG}    settings?scoringPeriodId=0
${DRAFT_DETAILS_SLUG}     draftDetail
${TRANSACTIONS_SLUG}    transactions/
@{user_emails}        test_api_user1@test.com    test_api_user2@test.com    test_api_user3@test.com
#user cookies
${user1_cookie}    SWID={DADA6BC1-6F16-4B4C-9E34-526B4870B891};espn_s2=AEAqx51yoqQ+9D/bdVjfB6Vqk60qbd9N4ksqclsl1YDg0YfakxNUOm7PZlZT+GkUAxvxf6VcUSwnhGNh51VAl7bE2+s7TZX+8uvmlhj3hSBVnLy8nXVyLPrDj1rDP6PF+OLvPQaiZtSbIU39EwPQDMatVBuoU1Fcu/yKOTmnZ0LiUhDRoMHti+jdDVhsDgDYVl8DOaJ4i6sfAtOOwIvcH49MiRFzqLR/t8mDI6oAyO8oLBuxXmnQVbaIDyrYSHj/1js/2Y7VlOf12JwcXn8cb1968h0eo2SNyOBI2VN5mwEdZw==;
${user2_cookie}    SWID={F53C173D-F557-4E6E-B576-B12C9BE2C80F};espn_s2=AEAr93yzMIUA7cbl4sI/Jq56zp7bzYIoSrGcUYnMu8BC+gaiWIVSQzJmEjmzw3rmybzS7ZvcMBdmxMk/uJ9CeMd8QDLlPbhr0TPlorN4Q2vvUlNun/KeJ7UQt7cLTgFHumwH8TCD/8W2TbL4AFTuNBEDltlfWnVixzIdxkKnESKEzCwvBwmgo21fITKCOJsZEmMwWF4dc7koYWkxZX8SR30423njQ76iUTWv58HIFRYj8O2f0dPuKVpEIu2x89tMJmcfbIVZtjksWktkZDYEs4iw+GzZS1xmzNbaCf3lJxg3zQ==;
${user3_cookie}    SWID={4E0A1098-59AA-492E-ABE1-32C3A44B0233};espn_s2=AEB8pEruBWboxDncWhpikJeM4XdvIuu+9qcz4LTldeKeHAZkl4ndAdaGwuW1w8ruMmv1KDa18fYV5xKHIhhuXFyIFOU3lAN9XD022VkjjRwj2WcyfzUQaP/uyNbRYRs77usFjcLpmncYpF2SqqfYgXB4p841z9LvAuw5oWt1JyuJ2FSNxbctilcj0ibVPWlqI4Mcy99Ge0QwHSdC4K4K12XDT5xRxSlrLRJyaiwkOABhnezYk2ca9Tk3Qs3I3kl0Zn9d/iwZtQB5iya5OeyDiUE8PMuNQWFQ29cYKZUaIi2VvQ==;
@{user_cookies}       ${user1_cookie}    ${user2_cookie}    ${user3_cookie}
@{member_ids}         DADA6BC1-6F16-4B4C-9E34-526B4870B891    F53C173D-F557-4E6E-B576-B12C9BE2C80F    4E0A1098-59AA-492E-ABE1-32C3A44B0233
@{display_name}       ESPNFAN3016725091    ESPNFAN3292075826    ESPNFAN4644965931

*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    ${api_response}=    GET  url=${endpoint}  expected_status=${status}
    [Return]    ${api_response}

Initialize the user cookie
    [Documentation]     fetches user cookies and SWID of the user and sets it as global.
    ${espn_cookie}=    Auth with Cookie Capture
    Set Global Variable      ${espn_cookie}
    Get SWID of the user ${espn_cookie}

Get SWID of the user ${espn_cookie}
    [Documentation]    Extracts SWID from the user cookie.
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    Set Global Variable    ${SWID}

Create a League and validate the response schema
    [Documentation]    Invokes League create API endpoint and validates the response schema.
    ${response}=    Validate Fantasy create league endpoint responds with status code 200
    Fantasy Create League Schema from ${response} should be valid

Create a League with an invalid team count
    [Documentation]    Invokes League create API endpoint with an invalid team count value in payload
    Validate Fantasy create league endpoint with invalid team count responds with status code 409

Create a League with an invalid fantasy team name
    [Documentation]    Invokes League create API endpoint with an invalid team count value in payload
    Validate Fantasy create league endpoint with invalid fantasy team name responds with status code 400

Create a league as a non-league creator user
    [Documentation]    Invokes League create API endpoint with an invalid team count value in payload
    Validate Fantasy create league endpoint as non-league creator user responds with status code 400

Assign League Manager Roles to Team2, Team3 and Team4 owners
    [Documentation]    Assigns League Manager Roles to Team2, Team3 and Team4 owners
    FOR    ${index}    IN RANGE    1    4
        &{lm_json_template}=     Load JSON from file    resource/JSON/leagueManagerPowerAccess.json
        ${decremented_index}=    Evaluate    ${index}-1
        ${display_name_updated}=    Update value to JSON    ${lm_json_template}    $.displayName   ${display_name}[${decremented_index}]
        Save JSON to file    ${display_name_updated}    resource/JSON/leagueManagerPowerAccess.json    2
        ${first_name_updated}=    Update value to JSON    ${lm_json_template}    $.firstName    User${index}
        Save JSON to file    ${first_name_updated}    resource/JSON/leagueManagerPowerAccess.json    2
        ${id_updated}=    Update value to JSON    ${lm_json_template}    $.id    {${member_ids}[${decremented_index}]}
        Save JSON to file    ${id_updated}    resource/JSON/leagueManagerPowerAccess.json    2
        &{header_value}=    create dictionary     cookie=${espn_cookie}
        ${lm_response}=     PUT    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/members/%7B${member_ids}[${decremented_index}]%7D  headers=${header_value}    json=${lm_json_template}     expected_status=200      
    END

Assign League Manager Roles to invalid users
    [Documentation]    Assigns League Manager Roles to invalid user display names
    #${random_string}=    Generate Random String    25    0123456789
    FOR    ${index}    IN RANGE    1    4
        &{lm_json_template}=     Load JSON from file    resource/JSON/leagueManagerPowerAccess.json
        ${decremented_index}=    Evaluate    ${index}-1
        ${display_name_updated}=    Update value to JSON    ${lm_json_template}    $.displayName   ${display_name}[${decremented_index}]
        #${display_name_updated}=    Update value to JSON    ${lm_json_template}    $.displayName   None
        Save JSON to file    ${display_name_updated}    resource/JSON/leagueManagerPowerAccess.json    2
        ${first_name_updated}=    Update value to JSON    ${lm_json_template}    $.firstName    User${index}
        Save JSON to file    ${first_name_updated}    resource/JSON/leagueManagerPowerAccess.json    2
        ${id_updated}=    Update value to JSON    ${lm_json_template}    $.id    {${member_ids}[${decremented_index}]}
        Save JSON to file    ${id_updated}    resource/JSON/leagueManagerPowerAccess.json    2
        #&{header_value}=    create dictionary     cookie=${espn_cookie}
        ${lm_response}=     PUT    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/members/%7B${member_ids}[${decremented_index}]%7D    json=${lm_json_template}     expected_status=401
        Invalid Schema from ${lm_response} should be valid     
    END

Send Invitations, Accept Invitation send by inviter and Create teams
    [Documentation]    Invokes Members Accept API endpoint.
    Validate Invitation Accept, Team Creation endpoints responds with successful status code

Send Invitations, Accept Invitation send by inviter and Create teams within the league with more than accepted characters for the name, abbreviation, and location fields
    [Documentation]    Invokes Members Accept API endpoint.
    Validate Invitation Accept, Team Creation within the league with more than accepted characters for the name, abbreviation, and location fields

Delete the created league
    [Documentation]    Invoke delete API endpoint to delete the created league
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Delete call to delete the created league
    ${delete_response}=     DELETE    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}  headers=${header_value}     expected_status=204

Delete the invalid league
    [Documentation]    Invoke delete API endpoint to delete the invalid league
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    ${delete_response}=     DELETE    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/123456789  headers=${header_value}     expected_status=404
    Invalid Schema from ${delete_response} should be valid

Schedule Offline Draft
    [Documentation]    Draft settings Changes to start Online drafting
    #Get unix time stamp time
    ${unixtimestamp}=    Get unixtimestamp time
    #Load Draft settings payload
    &{draft_json_template}=     Load JSON from file    resource/JSON/draftSettings.json
    #update draft settings date to current unix timestamp
    ${id_updated}=    Update value to JSON    ${draft_json_template}    $.draftSettings.date    ${unixtimestamp}
    #Save the draft setting changes
    Save JSON to file    ${id_updated}    resource/JSON/draftSettings.json    2
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Post call for draft settings changes
    ${schedule_draft_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_SETTINGS_SLUG}  headers=${header_value}    json=${draft_json_template}     expected_status=200

Schedule Offline Draft with invalid payload
    [Documentation]    Draft settings Changes to start Online drafting
    #Get unix time stamp time
    #${unixtimestamp}=    Get unixtimestamp time
    #Load Draft settings payload
    &{draft_json_template}=     Load JSON from file    resource/JSON/draftSettings.json
    ${positive_value}=    Convert To Integer    1234567
    #update draft settings date to current unix timestamp
    ${date_updated}=    Update value to JSON    ${draft_json_template}    $.draftSettings.date    dummyValue
    #Save the draft setting changes
    Save JSON to file    ${date_updated}    resource/JSON/draftSettings.json    2
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Post call for draft settings changes
    ${schedule_draft_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_SETTINGS_SLUG}  headers=${header_value}    json=${draft_json_template}     expected_status=400
    ${date_reupdated}=    Update value to JSON    ${draft_json_template}    $.draftSettings.date    ${positive_value}
    Save JSON to file    ${date_reupdated}    resource/JSON/draftSettings.json    2

Begin Offline Draft
    [Documentation]    Start Offline Drafting
    #Load payload
    &{begin_offline_draft_json_template}=     Load JSON from file    resource/JSON/beginOfflineDraft.json
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Post call to start offline drafting
    ${begin_offline_draft_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_DETAILS_SLUG}  headers=${header_value}    json=${begin_offline_draft_json_template}     expected_status=200

Begin Offline Draft with an invalid payload
    [Documentation]    Start Offline Drafting with an invalid payload
    #Load payload
    &{begin_offline_draft_json_template}=     Load JSON from file    resource/JSON/beginOfflineDraft.json
    ${true}=     Convert To Boolean    true
    ${inProgress_updated}=    Update value to JSON    ${begin_offline_draft_json_template}    $.inProgress    dummyValue
    Save JSON to file    ${inProgress_updated}    resource/JSON/beginOfflineDraft.json    2
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Post call to start offline drafting
    ${begin_offline_draft_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_DETAILS_SLUG}  headers=${header_value}    json=${begin_offline_draft_json_template}     expected_status=400
    Invalid Schema from ${begin_offline_draft_response} should be valid
    ${inProgress_reupdated}=    Update value to JSON    ${begin_offline_draft_json_template}    $.inProgress    ${true}
    Save JSON to file    ${inProgress_reupdated}    resource/JSON/beginOfflineDraft.json    2

Add players to all teams as league creator user and save the roster
    [Documentation]    Add players to all teams as league creator user
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Load offline draft save payload
    &{offline_draft_save_json_template}=     Load JSON from file    resource/JSON/offlineDraftSave.json
    # Loop to iterate for Team1, Team2, Team3 and Team4
    FOR    ${index}    IN RANGE    1    5
        #Loads - offlineDraftTeam1.json, offlineDraftTeam2.json, offlineDraftTeam3.json, offlineDraftTeam4.json 
        &{offline_draft_teams_json_template}=     Load JSON from file    resource/JSON/offlineDraftTeam${index}.json
        #Post call to add team players
        ${offline_draft_team_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${TRANSACTIONS_SLUG}  headers=${header_value}    json=${offline_draft_teams_json_template}     expected_status=200  
    END
    #Post call to add players to the teams
    ${offline_draft_save_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_DETAILS_SLUG}  headers=${header_value}    json=${offline_draft_save_json_template}     expected_status=200

Add players to all teams as league creator user and save the roster before draft begin
    [Documentation]    Add players to all teams as league creator user
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    &{offline_draft_save_json_template}=     Load JSON from file    resource/JSON/offlineDraftSave.json
    # Loop to iterate for Team1, Team2, Team3 and Team4
    FOR    ${index}    IN RANGE    1    5
        &{offline_draft_teams_json_template}=     Load JSON from file    resource/JSON/offlineDraftTeam${index}.json
        ${offline_draft_team_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${TRANSACTIONS_SLUG}  headers=${header_value}    json=${offline_draft_teams_json_template}     expected_status=409
        Invalid Schema from ${offline_draft_team_response} should be valid
    END

Add players to all teams as league creator user and save the roster with invalid payload
    [Documentation]    Add players to all teams as league creator user
    ${false}=    Convert To Boolean    false
    ${true}=     Convert To Boolean    true
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    &{offline_draft_save_json_template}=     Load JSON from file    resource/JSON/offlineDraftSave.json
    FOR    ${index}    IN RANGE    1    5
        &{offline_draft_teams_json_template}=     Load JSON from file    resource/JSON/offlineDraftTeam${index}.json
        ${offline_draft_team_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${TRANSACTIONS_SLUG}  headers=${header_value}    json=${offline_draft_teams_json_template}     expected_status=200  
    END
    ${drafted_updated}=    Update value to JSON    ${offline_draft_save_json_template}    $.drafted    dummyValue
    Save JSON to file    ${drafted_updated}    resource/JSON/offlineDraftSave.json    2
    ${inProgress_updated}=    Update value to JSON    ${offline_draft_save_json_template}    $.inProgress    dummyValue
    Save JSON to file    ${inProgress_updated}    resource/JSON/offlineDraftSave.json    2
    ${offline_draft_save_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_DETAILS_SLUG}  headers=${header_value}    json=${offline_draft_save_json_template}     expected_status=400
    Invalid Schema from ${offline_draft_save_response} should be valid
    #Resave the JSON
    ${drafted_updated}=    Update value to JSON    ${offline_draft_save_json_template}    $.drafted    ${true}
    Save JSON to file    ${drafted_updated}    resource/JSON/offlineDraftSave.json    2
    ${inProgress_updated}=    Update value to JSON    ${offline_draft_save_json_template}    $.inProgress    ${false}
    Save JSON to file    ${inProgress_updated}    resource/JSON/offlineDraftSave.json    2

Add players to team ${team_id} as team owner ${team_owner_id}
    [Documentation]    Generic method to add team players to respective teams as team owners
    &{offline_draft_team_json_template}=     Load JSON from file    resource/JSON/offlineDraftTeam${team_id}.json
    ${decremented_index}=    Evaluate    ${team_id}-2
    &{header_value}=    create dictionary     cookie=${user_cookies}[${decremented_index}]
    ${offline_draft_team_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${TRANSACTIONS_SLUG}  headers=${header_value}    json=${offline_draft_team_json_template}     expected_status=200

Add players to team 1 as League creator user
    [Documentation]    Add players to team 1 as league creator user
    &{offline_draft_team1_json_template}=     Load JSON from file    resource/JSON/offlineDraftTeam1.json
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    ${offline_draft_team1_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${TRANSACTIONS_SLUG}  headers=${header_value}    json=${offline_draft_team1_json_template}     expected_status=200

Save the roster
    [Documentation]    Invoke draft save API to save the players to the roster
    &{offline_draft_save_json_template}=     Load JSON from file    resource/JSON/offlineDraftSave.json
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Post call to save the roster
    ${offline_draft_save_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/${DRAFT_DETAILS_SLUG}  headers=${header_value}    json=${offline_draft_save_json_template}     expected_status=200

Validate Fantasy create league endpoint responds with status code 200
    [Documentation]    create a league, make league id and invite id as global and returns the league response to the called keyword
    &{league_create_json_template}=    Load JSON from file    resource/JSON/leagueCreateTemplate.json
    #Generate random string of 4 digits
    ${random_string}=    Generate Random String    4    0123456789
    #Get SWID of the user
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    # Update member Id to Json file
    ${member_id_updated}=    Update value to JSON    ${league_create_json_template}    $.members[0].id   ${SWID}
    #Save content to JSON file with indentation (value:2 Tab Space)
    Save JSON to file    ${member_id_updated}    resource/JSON/leagueCreateTemplate.json    2
    #Update Fantasy league name
    ${league_updated}=    Update value to JSON    ${league_create_json_template}    $.settings.name    My-Fantasy-League-${random_string}
    Save JSON to file    ${league_updated}    resource/JSON/leagueCreateTemplate.json    2
    #Cookie dictionary
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    #Create League API invocation
    ${league_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUE_CREATE_SLUG}  headers=${header_value}     json=${league_create_json_template}   expected_status=200
    #get copy to clipboard invite id from response
    ${invite_id}=    Get COPY_TO_CLIPBOARD invite id from ${league_response.json()}
    Set Global Variable    ${invite_id}
    #get league Id
    ${league_id}=    Get value from JSON    ${league_response.json()}    $.id
    Set Global Variable    ${league_id}
    Log    ${league_id}    console=${True}
    [Return]    ${league_response}

Validate Fantasy create league endpoint with invalid team count responds with status code 409
    [Documentation]    create a league, make league id and invite id as global and returns the league response to the called keyword
    &{league_create_json_template}=    Load JSON from file    resource/JSON/leagueCreateTemplate.json
    ${random_string}=    Generate Random String    4    0123456789
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    ${member_id_updated}=    Update value to JSON    ${league_create_json_template}    $.members[0].id   ${SWID}
    Save JSON to file    ${member_id_updated}    resource/JSON/leagueCreateTemplate.json    2
    ${league_updated}=    Update value to JSON    ${league_create_json_template}    $.settings.name    My-Fantasy-League-${random_string}
    Save JSON to file    ${league_updated}    resource/JSON/leagueCreateTemplate.json    2
    ${size_updated}=    Update value to JSON    ${league_create_json_template}    $.settings.size    ${random_string}
    Save JSON to file    ${size_updated}    resource/JSON/leagueCreateTemplate.json    2
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    ${league_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUE_CREATE_SLUG}  headers=${header_value}     json=${league_create_json_template}   expected_status=409
    Invalid Schema from ${league_response} should be valid
    ${size_re_updated}=    Update value to JSON    ${league_create_json_template}    $.settings.size    4
    Save JSON to file    ${size_re_updated}    resource/JSON/leagueCreateTemplate.json    2

Validate Fantasy create league endpoint with invalid fantasy team name responds with status code 400
    [Documentation]    create a league, make league id and invite id as global and returns the league response to the called keyword
    &{league_create_json_template}=    Load JSON from file    resource/JSON/leagueCreateTemplate.json
    ${random_string}=    Generate Random String    25    0123456789
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    ${member_id_updated}=    Update value to JSON    ${league_create_json_template}    $.members[0].id   ${SWID}
    Save JSON to file    ${member_id_updated}    resource/JSON/leagueCreateTemplate.json    2
    ${league_updated}=    Update value to JSON    ${league_create_json_template}    $.settings.name    My-Fantasy-League-${random_string}
    Save JSON to file    ${league_updated}    resource/JSON/leagueCreateTemplate.json    2
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    ${team_response}=    POST    url= ${FANTASY_BASE_URL}/${LEAGUE_CREATE_SLUG}  headers=${header_value}     json=${league_create_json_template}   expected_status=400
    Invalid Schema from ${team_response} should be valid

Validate Fantasy create league endpoint as non-league creator user responds with status code 400
    [Documentation]    create a league, make league id and invite id as global and returns the league response to the called keyword
    ${false}=    Convert To Boolean    false
    ${true}=     Convert To Boolean    true
    &{league_create_json_template}=    Load JSON from file    resource/JSON/leagueCreateTemplate.json
    ${random_string}=    Generate Random String    4    0123456789
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    ${member_id_updated}=    Update value to JSON    ${league_create_json_template}    $.members[0].id   ${SWID}
    Save JSON to file    ${member_id_updated}    resource/JSON/leagueCreateTemplate.json    2
    ${isLeagueCreator_updated}=    Update value to JSON    ${league_create_json_template}    $.members[0].isLeagueCreator   ${false}
    Save JSON to file    ${isLeagueCreator_updated}    resource/JSON/leagueCreateTemplate.json    2
    ${league_updated}=    Update value to JSON    ${league_create_json_template}    $.settings.name    My-Fantasy-League-${random_string}
    Save JSON to file    ${league_updated}    resource/JSON/leagueCreateTemplate.json    2
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    ${response}=    POST    url= ${FANTASY_BASE_URL}/${LEAGUE_CREATE_SLUG}  headers=${header_value}     json=${league_create_json_template}   expected_status=400
    Invalid Schema from ${response} should be valid
    # Update isLeagueCreator value to true
    ${isLeagueCreator_reupdated}=    Update value to JSON    ${league_create_json_template}    $.members[0].isLeagueCreator   ${true}
    #Save content to JSON file with indentation (value:2 Tab Space)
    Save JSON to file    ${isLeagueCreator_reupdated}    resource/JSON/leagueCreateTemplate.json    2

Validate Invitation Accept, Team Creation endpoints responds with successful status code
    [Documentation]    Accept League Invite sent by inviter, fetch team id, update team information, invoke team creation API endpoint and validate the response schema
    #Member Invitation Accept for all 3 users
    FOR    ${index}    IN RANGE    0    3
        &{league_invite_accept_json_template}=    Load JSON from file    resource/JSON/leagueInviteAccept.json
        ${id_updated}=    Update value to JSON    ${league_invite_accept_json_template}    $.id   ${invite_id}
        Save JSON to file    ${id_updated}    resource/JSON/leagueInviteAccept.json    2
        &{header_user_cookie}    Create Dictionary    cookie=${user_cookies}[${index}]
        #Make post request and send json payload to accept invitation - 
        ${memberInvitationAccepation}=    POST    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/invites/${invite_id}?memberId={${member_ids}[${index}]}&join=true    headers=${header_user_cookie}    json=${league_invite_accept_json_template}       expected_status=201
        #fetch team id
        ${team_id}=    Get value from JSON    ${memberInvitationAccepation.json()}    $.teamId
        &{team_create_json_template}=    Load JSON from file    resource/JSON/teamCreateTemplate.json
        #Team abbreviation update
        ${team_abbreviation_updated}=    Update value to JSON    ${team_create_json_template}    $.abbrev   FL${index}
        Save JSON to file    ${team_abbreviation_updated}    resource/JSON/teamCreateTemplate.json    2
        #Team nickname update
        ${nick_name_updated}=    Update value to JSON    ${team_create_json_template}    $.nickname   FN${index}
        Save JSON to file    ${nick_name_updated}    resource/JSON/teamCreateTemplate.json    2
        #Team location update
        ${location_updated}=    Update value to JSON    ${team_create_json_template}    $.location   FTM${index}
        Save JSON to file    ${location_updated}    resource/JSON/teamCreateTemplate.json    2
        #Team create API invocation
        ${team_response}=     POST    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/teams/${team_id}   headers=${header_user_cookie}     json=${team_create_json_template}   expected_status=200
        #Schema validation
        Fantasy Teams Schema from ${team_response} should be valid
    END

Validate Invitation Accept, Team Creation within the league with more than accepted characters for the name, abbreviation, and location fields
    [Documentation]    Accept League Invite sent by inviter, fetch team id, update team information, invoke team creation API endpoint and validate the response schema
    ${random_string}=    Generate Random String    5    0123456789
    FOR    ${index}    IN RANGE    0    3
        &{league_invite_accept_json_template}=    Load JSON from file    resource/JSON/leagueInviteAccept.json
        ${id_updated}=    Update value to JSON    ${league_invite_accept_json_template}    $.id   ${invite_id}
        Save JSON to file    ${id_updated}    resource/JSON/leagueInviteAccept.json    2
        &{header_user_cookie}    Create Dictionary    cookie=${user_cookies}[${index}]
        ${memberInvitationAccepation}=    POST    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/invites/${invite_id}?memberId={${member_ids}[${index}]}&join=true    headers=${header_user_cookie}    json=${league_invite_accept_json_template}       expected_status=201
        ${team_id}=    Get value from JSON    ${memberInvitationAccepation.json()}    $.teamId
        &{team_create_json_template}=    Load JSON from file    resource/JSON/teamCreateTemplate.json
        ${team_abbreviation_updated}=    Update value to JSON    ${team_create_json_template}    $.abbrev   FL${index}${random_string}
        Save JSON to file    ${team_abbreviation_updated}    resource/JSON/teamCreateTemplate.json    2
        ${nick_name_updated}=    Update value to JSON    ${team_create_json_template}    $.nickname   FN${index}${random_string}
        Save JSON to file    ${nick_name_updated}    resource/JSON/teamCreateTemplate.json    2
        ${location_updated}=    Update value to JSON    ${team_create_json_template}    $.location   FTM${index}${random_string}
        Save JSON to file    ${location_updated}    resource/JSON/teamCreateTemplate.json    2
        ${team_response}=     POST    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${league_id}/teams/${team_id}   headers=${header_user_cookie}     json=${team_create_json_template}   expected_status=400
        Invalid Schema from ${team_response} should be valid
    END

Close the current Browser
    Browser Shutdown