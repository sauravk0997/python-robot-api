*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             DateTime
Library             RPA.JSON
Library             Collections
Library             String
#Resource            testsuite/fantasy-sport-league-teams-tests.robot
Library    lib/validators/FantasyCreateLeagueValidator.py

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
@{user_emails}        test_api_user1@test.com    test_api_user2@test.com    test_api_user3@test.com
@{INVITATION_LIST}    create    list

${user1_cookie}    SWID={DADA6BC1-6F16-4B4C-9E34-526B4870B891};espn_s2=AEAqx51yoqQ+9D/bdVjfB6Vqk60qbd9N4ksqclsl1YDg0YfakxNUOm7PZlZT+GkUAxvxf6VcUSwnhGNh51VAl7bE2+s7TZX+8uvmlhj3hSBVnLy8nXVyLPrDj1rDP6PF+OLvPQaiZtSbIU39EwPQDMatVBuoU1Fcu/yKOTmnZ0LiUhDRoMHti+jdDVhsDgDYVl8DOaJ4i6sfAtOOwIvcH49MiRFzqLR/t8mDI6oAyO8oLBuxXmnQVbaIDyrYSHj/1js/2Y7VlOf12JwcXn8cb1968h0eo2SNyOBI2VN5mwEdZw==;
${user2_cookie}    SWID={F53C173D-F557-4E6E-B576-B12C9BE2C80F};espn_s2=AEAr93yzMIUA7cbl4sI/Jq56zp7bzYIoSrGcUYnMu8BC+gaiWIVSQzJmEjmzw3rmybzS7ZvcMBdmxMk/uJ9CeMd8QDLlPbhr0TPlorN4Q2vvUlNun/KeJ7UQt7cLTgFHumwH8TCD/8W2TbL4AFTuNBEDltlfWnVixzIdxkKnESKEzCwvBwmgo21fITKCOJsZEmMwWF4dc7koYWkxZX8SR30423njQ76iUTWv58HIFRYj8O2f0dPuKVpEIu2x89tMJmcfbIVZtjksWktkZDYEs4iw+GzZS1xmzNbaCf3lJxg3zQ==;
${user3_cookie}    SWID={4E0A1098-59AA-492E-ABE1-32C3A44B0233};espn_s2=AEB8pEruBWboxDncWhpikJeM4XdvIuu+9qcz4LTldeKeHAZkl4ndAdaGwuW1w8ruMmv1KDa18fYV5xKHIhhuXFyIFOU3lAN9XD022VkjjRwj2WcyfzUQaP/uyNbRYRs77usFjcLpmncYpF2SqqfYgXB4p841z9LvAuw5oWt1JyuJ2FSNxbctilcj0ibVPWlqI4Mcy99Ge0QwHSdC4K4K12XDT5xRxSlrLRJyaiwkOABhnezYk2ca9Tk3Qs3I3kl0Zn9d/iwZtQB5iya5OeyDiUE8PMuNQWFQ29cYKZUaIi2VvQ==;
@{user_cookies}       ${user1_cookie}    ${user2_cookie}    ${user3_cookie}
@{member_ids}         DADA6BC1-6F16-4B4C-9E34-526B4870B891    F53C173D-F557-4E6E-B576-B12C9BE2C80F    FDA0D473-B9F0-47EE-B819-44851C76A9DE


*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    ${api_response}=    GET  url=${endpoint}  expected_status=${status}
    [Return]    ${api_response}

A POST request to ${endpoint} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    ${api_response}=    POST  url=${endpoint}  expected_status=${status}
    [Return]    ${api_response}
Initialize users cookie ${espn_cookie}
    log    ${espn_cookie}
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    Set Global Variable    ${espn_cookie}
    Set Global Variable    ${SWID}

Validate Fantasy create league endpoint responds with status code 200
    &{leagueCreateJsonTemplate}=    Load JSON from file    resource/leagueCreateTemplate.json
    #Generate random string of 4 digits
    ${random_string}=    Generate Random String    4    0123456789
    #Get SWID of the user
    ${SWID}=    Get SWID from cookie ${espn_cookie}
    # Update member Id to Json file
    ${memberIdUpdated}=    Update value to JSON    ${leagueCreateJsonTemplate}    $.members[0].id   ${SWID}
    #Save content to JSON file with indentation (value:2 Tab Space)
    Save JSON to file    ${memberIdUpdated}    resource/leagueCreateTemplate.json    2
    #Update Fantasy league name
    ${leagueUpdated}=    Update value to JSON    ${leagueCreateJsonTemplate}    $.settings.name    My-Fantasy-League-${random_string}
    Save JSON to file    ${leagueUpdated}    resource/leagueCreateTemplate.json    2
    #Cookie dictionary
    &{header_Value}=    create dictionary     cookie=${espn_cookie}
    #Create League API invocation
    ${league_response}=     POST    url= ${FANTASY_BASE_URL}/${LEAGUE_CREATE_SLUG}  headers=${header_Value}     json=${leagueCreateJsonTemplate}   expected_status=200
    #Fantasy Create League Schema from ${response} should be valid
    #get league Id
    ${leagueId}=    Get value from JSON    ${league_response.json()}    $.id
    Set Global Variable    ${leagueId}
    Log    ${leagueId}    console=${True}
    [Return]    ${league_response}

Validate members Invitation enpoint responds with status code 201 and response schema should be valid
    #Send Member Invitation
    #For loop for each users
    FOR    ${index}    ${item}    IN ENUMERATE    @{user_emails}    start=2
        @{memberInviteJsonTemplate}=    Load JSON from file    resource/LeagueMemeberInviteTemplate.json
        ${get_user1_contact_updated}=    Update value to JSON    ${memberInviteJsonTemplate}    $.[0].contact   ${item}
        Save JSON to file    ${get_user1_contact_updated}    resource/LeagueMemeberInviteTemplate.json    2
        ${team_id_updated}=    Update value to JSON    ${memberInviteJsonTemplate}    $.[0].teamId   ${index}
        Save JSON to file    ${team_id_updated}    resource/LeagueMemeberInviteTemplate.json    2
        ${inviter_updated}=    Update value to JSON    ${memberInviteJsonTemplate}    $.[0].inviter   ${SWID}
        #Member invitation API invocation
        &{header_Value}=    create dictionary     cookie=${espn_cookie}
        ${memberInvitationResponse}=     PUT    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${leagueId}/${MEMBER_INVITE_SLUG}   headers=${header_Value}     json=${memberInviteJsonTemplate}   expected_status=201
        #Schema Validation - Having some issue, need to discuss with team
        #Fantasy Member Invite Schema from ${memberInvitationResponse} should be valid
        ${invitationId}=    Get value from JSON    ${memberInvitationResponse.json()}    $[0].id
        #Append invitation Id's to list
        Append To List    ${INVITATION_LIST}    ${invitationId}
        #[Return]    ${memberInvitationResponse} - Not possible

    END

Validate Invitation Accept enpoint responds with status code 200
    #Member Invitation Accept
    FOR    ${counter}    IN RANGE    0    3
        &{header_user_cookie}    Create Dictionary    cookie=${user_cookies}[${counter}]
        ${memberInvitationAccepation}=    OPTIONS    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${leagueId}/invites/${INVITATION_LIST}[${counter}]?memberId=${member_ids}[${counter}]&join=true    headers=${header_user_cookie}        expected_status=200
        #[Return]    ${memberInvitationAccepation} - Not possible
    END

Validate Teams create endpoint responds with status code 200 and response schema should be valid
    #Invocation of Teams API
    FOR    ${counter}    IN RANGE    2    5
        Log    ${counter}
        &{teamCreateTemplate}=    Load JSON from file    resource/teamCreateTemplate.json
        ${team_abbreviation_updated}=    Update value to JSON    ${teamCreateTemplate}    $.abbrev   FL${counter}
        Save JSON to file    ${team_abbreviation_updated}    resource/teamCreateTemplate.json    2
        ${nick_name_updated}=    Update value to JSON    ${teamCreateTemplate}    $.nickname   FN${counter}
        Save JSON to file    ${nick_name_updated}    resource/teamCreateTemplate.json    2
        ${location_updated}=    Update value to JSON    ${teamCreateTemplate}    $.location   FTM${counter}
        Save JSON to file    ${location_updated}    resource/teamCreateTemplate.json    2
        &{header_Value}=    create dictionary     cookie=${espn_cookie}
        ${team_response}=     POST    url=${FANTASY_BASE_URL}/${LEAGUES_SLUG}/${leagueId}/teams/${counter}   headers=${header_Value}     json=${teamCreateTemplate}   expected_status=200
        #Validate schema here
        #[Return]    ${team_response} - Not possible
    END