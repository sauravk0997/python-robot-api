*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             DateTime   

Library             ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM       

*** Variables ***

${API_BASE}=       https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/
                   #https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/season_id/segments/segment_id/leagues/league_id/transactions/
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         saurav.kumar@zucitech.com
${password}     Saurav@1103
${greeting}     Saurav!
#${espn_cookie}
*** Keywords ***

Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    Log To Console    ${espn_cookie}
    Set Global Variable     ${espn_cookie}
    #SWID={107F4FFD-2902-4067-80ED-1B60E523AEA6}; espn_s2=AECrJIHbu9mV9qfddT1xOnYOu8uJDtecBfWmVovhtTiAQDS%2BRnmu%2BogoFhsLon7g3F5J%2F7auRgBMdowDa3Osx%2Bictanm3UqXRwcMHia9zo16%2FfJU2133DjUYHwbA2GgqYYWyuW%2BCrQ4Pz4R233wLykCbAe8E2DHnFg6L7PkZ4jXydAMyvlIInjk19hbdV7tw05o3lSOCPOpKIXH022Lh0qbUZy6PN06r3GSr7Ct%2FqO5PiDV6NFMMuJlMlUAgKy7Zr%2BX9W1UrptN5vv3y5JKh61Sxpo0FmjcKlxcHpaMz%2BkxGyg%3D%3D;
    
A POST request to ${endpoint} add player to my team as a TO should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    
    ${payload}=  Get File  resource/AddPlayer.json
    ${data}=     Evaluate    json.loads('''${payload}''')   
    &{header}=   Create Dictionary      cookie=${espn_cookie}
    #${data}=    json.loads('''${payload}'''')
    ${api_response}=    POST  url=${endpoint}     headers=${header}    json=${data}     expected_status=${status}           
    [Return]    ${api_response}

# Validate ${links} should respond with ${status}
#     [Documentation]     Custom GET keyword with status validation.
#     FOR    ${link}    IN    @{links}
#         A GET request to ${link} should respond with 200   
#     END