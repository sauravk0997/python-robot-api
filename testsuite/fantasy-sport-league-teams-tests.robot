*** Settings ***
Library    Collections
Library    OperatingSystem
Library    RequestsLibrary
Library    ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM
Library    RPA.JSON
Library    String
Library    lib/fantasyUI/FantasyUtils.py
Library    lib/validators/FantasyCreateLeagueValidator.py
Resource    resource/FantasyResource.robot
*** Variables ***
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         apiuser@test.com
${password}     APIuser@ESPN
${greeting}     API!

*** Test Cases ***
Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    Set Global Variable      ${espn_cookie}

Create League Endpoint and Schema validations are successful
    Initialize users cookie ${espn_cookie}
    ${response}=    Validate Fantasy create league endpoint responds with status code 200
    Fantasy Create League Schema from ${response} should be valid
    
Invitation send to members and response schema validations are successful
    Validate members Invitation enpoint responds with status code 201 and response schema should be valid

Invitation Accepted by members are successful
    Validate Invitation Accept enpoint responds with status code 200


Teams created inside league and response schema validations are successful
    Validate Teams create endpoint responds with status code 200 and response schema should be valid

