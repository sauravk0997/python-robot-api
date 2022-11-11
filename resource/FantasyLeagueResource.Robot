*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    ../lib/fantasyUI/FantasyLoginManager.py    driver=${BROWSER}    xpaths=${CURDIR}/../resource/xpaths.json    WITH NAME  FLM
Library    ../lib/validators/FantasyLeagueValidator.py

*** Variables ***
${HOMEPAGE}             https://www.espn.com/fantasy/
${CreateLeague_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues?createAsTypeId=2
${LeagueInvite_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/invites?copyLMOnInvite=false&notifyUnjoined=false
${LeagueInvitationAccept_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/invites/{leagueInviteId}?memberId=BC6305D7-5A17-4840-B231-8D34D45B1DCB&join=true
${TeamCreate_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/teams/{teamId}
${OfflineDraftStarting_url}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/draftDetail
${Transaction_url}   https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/transactions/     #This is the common url which will be perfoming different action like adding player,moving players..etc Based on the Json payload we send
${BROWSER}      Chrome
${user}         gagan.duddanahalli.rajaram.-nd@disney.com
${password}     ym1234
${greeting}     yusuf!
${espn_cookie}
${response}

*** Keywords ***
A post request to ${endpoint} and ${var1} and ${var2} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${var1}     json=${var2}    expected_status=${status}
    set global variable     ${response}

Authenticate with captured Cookie
    FLM.Login Fantasy User     username=${user}   password=${password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    ${espn_cookie}=     FLM.Fantasy API Cookie
    set global variable     ${espn_cookie}

Draft Begin
    A post request to ${endpoint} and ${var1} and ${var2} should respond with ${status}

Add



