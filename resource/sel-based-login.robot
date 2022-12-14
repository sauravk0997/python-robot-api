*** Settings ***
Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library  lib/fantasyUI/FantasyLoginManager.py

*** Variables ***
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         test_user_dummy1@test.com
${password}     APIuser@ESPN
${greeting}     API!

*** Keywords ***
Auth with Cookie Capture
    Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     Fantasy API Cookie
    [Return]    ${espn_cookie}

 Close the current active browser
    Browser shutdown