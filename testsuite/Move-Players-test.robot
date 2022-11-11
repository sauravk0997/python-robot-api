*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Resource    resource/FantasyLeagueResource.Robot


*** Test Cases ***
Test League Creation
    Authenticate with captured Cookie
    ${data1}=    get file   /Users/yusufmubarakm/Documents/yusuf/fantasy/espn-fantasy-api/resource/create.json
    ${object}=   Evaluate  json.loads('''${data1}''')
    &{data}=    create dictionary    cookie=${espn_cookie}
    A post request to ${CreateLeague_url} and ${data} and ${object} should respond with 200

Draft Begin
    ${leagueid}     Extract LeagueId from fantasy league API Response   ${response.json()}
    set global variable    ${leagueid}
    set test variable    ${request_url}     https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/draftDetail
    &{data}=    create dictionary    cookie=${espn_cookie}
    &{object}   create dictionary    inProgress=true
    A post request to ${request_url} and ${data} and ${object} should respond with 200

Add Player
    set test variable    ${addPlayer_url}   https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/${leagueid}/transactions/
    ${data1}=    get file  /Users/yusufmubarakm/Documents/yusuf/fantasy/espn-fantasy-api/resource/PlayersList.json
    ${object}=   Evaluate  json.loads('''${data1}''')
    &{data}=    create dictionary    cookie=${espn_cookie}
    A post request to ${addPlayer_url} and ${data} and ${object} should respond with 200






