*** Settings ***
Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library  ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/JSON/xpaths.json    WITH NAME  FLM

*** Variables ***
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         test_api@gmail.com
${password}     test_api
${greeting}     TestUser!

*** Keywords ***
Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    [Return]    ${espn_cookie}

Auth with user log in and capturing Cookie 
    [Arguments]    ${user}    ${password}    ${greeting}
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    [Return]    ${espn_cookie}

 Browser Shutdown
    FLM.Browser shutdown