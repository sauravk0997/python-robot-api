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
${API_KEY_URL}                                https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/api-key?langPref=en-US
${CREATE_ACCOUNT_URL}                         https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/guest/register?autogeneratePassword=false&autogenerateUsername=true&langPref=en-US

*** Keywords ***
Create a account and a league
    [Documentation]    Create - ESPN Fantasy User,League and teams creation and adding players to team
    Create a test account and signup and sign in to the application
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    set suite variable    ${MovePlayer_url}   ${FANTASY_URL}/apis/v3/games/${BASKETBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${league_id}/transactions/

Delete League and Account
   Delete the created league
   Delete the created test account

Generate a API KEY
  ${response}     POST       url=${API_KEY_URL}      expected_status=200
  ${api_key}      get from dictionary    ${response.headers}     api-key
  [Return]        ${api_key}

Create a test account and signup and sign in to the application
    ${API_KEY}                    Generate a API KEY
    &{Authorization}              create dictionary    Authorization=APIKEY ${API_KEY}
    &{create_account_payload}     load json from file    resource/JSON/signUp.json
    ${random_email}               generate a random email
    ${update_test_email}          Update value to JSON      ${create_account_payload}     $.profile.email             ${random_email}
    save json to file             ${update_test_email}      resource/JSON/signUp.json     2
    ${create_account_response}    POST                      url=${create_account_url}     headers=&{Authorization}    json=${create_account_payload}    expected_status=200
    ${email}                      Get value from JSON       ${create_account_payload}     $.profile.email
    ${Password}                   Get value from JSON       ${create_account_payload}     $.password
    ${espn_cookie}                Login to the application and get the user cookie    ${email}            ${Password}     Test Api Account!
    &{header_value}               create dictionary         cookie=${espn_cookie}
    Get SWID of the user ${espn_cookie}
    set global variable           ${espn_cookie}
    set global variable           &{header_value}
    set global variable           ${create_account_response}

Delete the created test account
    ${token}                   Get value from JSON    ${create_account_response.json()}     $.data.token.access_token
    &{Authorization}           create dictionary      Authorization=BEARER ${token}
    ${delete_response}         DELETE                 url=https://registerdisney.go.com/jgc/v6/client/ESPN-ONESITE.WEB-PROD/guest/${SWID}?langPref=en-US    headers=${Authorization}    expected_status=200