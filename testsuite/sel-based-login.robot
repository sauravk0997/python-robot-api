*** Settings ***
Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library  ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM

*** Variables ***
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}        
${password}    
${greeting}    

*** Keywords ***
Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    [Return]    ${espn_cookie}
