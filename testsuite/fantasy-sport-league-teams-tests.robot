Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library  ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM

*** Variables ***
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}         apiuser@test.com
${password}     APIuser@ESPN
${greeting}     API!
${FANTASY_BASE_URL}    https://fantasy.espn.com
${BASEBALL_SPORT}    fba
${SEASON}    2023
${SEGMENT}    0
${LEAGUE_CREATE_SLUG}    /apis/v3/games/${BASEBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues?createAsTypeId=2


*** Test Cases ***
Auth with Cookie Capture
    FLM.Login Fantasy User    username=${user}    password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    log to console      ${espn_cookie}

Validate create league and Team creation
    # to do
    # Will invoke create league api endpoint from python functions
    # validate the response (status code)
    # validate schema validation using marshmallow
    # validate the value using robot inbuilt library
    
