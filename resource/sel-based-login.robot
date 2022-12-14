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

 Browser Shutdown
    FLM.Browser shutdown

Auth with Cookie Capture test
     [Arguments]     ${email}     ${Password}      ${greet}
     FLM.Login Fantasy User    username=${email}    password=${password}  expected_profile_name_span_value=${greet}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    [Return]    ${espn_cookie}