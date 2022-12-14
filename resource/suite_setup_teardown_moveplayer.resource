*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library             RequestsLibrary
Library             RPA.JSON
Library             Collections
Library             String
Library             OperatingSystem
Library             lib/validators/FantasyMovePlayerValidator.py
Library             lib/fantasyUI/FantasyUtils.py
Resource            resource/FantasyResource.robot

*** Variables ***
${FANTASY_URL}                                https://fantasy.espn.com
${BASKETBALL_SPORT}                           fba
${SEASON}                                     2023
${SEGMENT}                                    0
${api_key_url}                                https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/api-key?langPref=en-US
${Create_account_url}                         https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/guest/register?autogeneratePassword=false&autogenerateUsername=true&langPref=en-US

*** Keywords ***
Get a Fantasy League details
    [Documentation]    Create - ESPN Fantasy League and teams creation and adding players to team
    Create a Test ESPN ACCOUNT
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    set suite variable    ${MovePlayer_url}   ${FANTASY_URL}/apis/v3/games/${BASKETBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}/transactions/

Delete League
    Delete the created league

Generate a API KEY from ${url} to create a test espn account
  ${response}     POST       url=${url}      expected_status=200
  ${api_key}    get from dictionary    ${response.headers}     api-key
  [Return]    ${api_key}

Create a Test ESPN ACCOUNT
    ${API_KEY}     Generate a API KEY from ${api_key_url} to create a test espn account
    &{Auth_header}  create dictionary    Authorization=APIKEY ${API_KEY}
    &{create_account_payload}     load json from file    resource/JSON/signUp.json
    ${random_email}          generate a random email
    ${update_test_email}          Update value to JSON    ${create_account_payload}     $.profile.email             ${random_email}
    save json to file    ${update_test_email}      resource/JSON/signUp.json     2
    ${response}    POST     url=${create_account_url}       headers=&{Auth_header}    json=${create_account_payload}    expected_status=200
    ${email}     Get value from JSON    ${create_account_payload}     $.profile.email
    ${Password}  Get value from JSON    ${create_account_payload}     $.password
    ${espn_cookie}     Auth with Cookie Capture test    ${email}    ${Password}     Test Api Account!
    Get SWID of the user ${espn_cookie}
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    set global variable    ${espn_cookie}
    set global variable    &{header_value}

