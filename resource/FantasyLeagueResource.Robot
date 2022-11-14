*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem



*** Variables ***
${HOMEPAGE}             https://www.espn.com/fantasy/
${CreateLeague_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues?createAsTypeId=2
${LeagueInvite_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/invites?copyLMOnInvite=false&notifyUnjoined=false
${LeagueInvitationAccept_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/invites/{leagueInviteId}?memberId=BC6305D7-5A17-4840-B231-8D34D45B1DCB&join=true
${TeamCreate_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/teams/{teamId}
${OfflineDraftStarting_url}    https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/draftDetail
${Transaction_url}   https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/{leagueid}/transactions/     #This is the common url which will be perfoming different action like adding player,moving players..etc Based on the Json payload we send
${BROWSER}      Chrome
${user}         test_api@gmail.com
${password}     test_api
${greeting}     TestUser!



*** Keywords ***
To Create a league send a post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${headers}     json=${payload}    expected_status=${status}
    ${leagueid}      get from dictionary    ${response.json()}  id
    set global variable     ${leagueid}


A post request to ${endpoint} using ${header} with ${payload} should respond with ${status}
    ${response}     POST    url=${endpoint}   headers=${header}     json=${payload}    expected_status=${status}
    [Return]    ${response}







