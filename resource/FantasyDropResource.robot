*** Settings ***
Documentation       All Common robot utils/functions and variables with respect to
...                 ESPN Fantasy Games API are maintained here
Library             RequestsLibrary
Library             OperatingSystem

*** Variables ***
${TEAMS_API}=        https://fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070?view=mDraftDetail&view=mLiveScoring&view=mMatchupScore&view=mPendingTransactions&view=mPositionalRatings&view=mRoster&view=mSettings&view=mTeam&view=modular&view=mNav  # tests default to the sandbox environment
${DELETE_API}=       https://lm-api-writes.fantasy.espn.com/apis/v3/games/fba/seasons/2023/segments/0/leagues/748489070/transactions/
${cleanup}=         ${False}  # False is a built-in RF variable
# ${EXP_CURRENT_SEASON_ID}=       2022
# ${SWID}=      2575812E-8058-4D83-9486-CDD9149938CA
# ${ESPNS2}=    AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA
# ${ck}=          SWID={${SWID}};espn_s2=${ESPNS2}==
# ${headers}       Create Dictionary      Content-Type=application/json      Cookie=${ck}

*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    ${api_response}=    GET  url=${endpoint}  headers=${headers}   expected_status=200 
    [Return]    ${api_response}

*** Test Cases ***
A POST request to ${DELETE_API} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    # &{playerdetails}=     Create Dictionary    playerId=3155942     type=DROP    fromTeamId=5
    # @{items}=    Create List
    ${pjs}=    Get file     /Users/abdul/Disney/espn-fantasy-api/dropplayer.json
    ${object}=    Evaluate     json.loads('''${pjs}''')    json
    Log To Console    ${object} 
    &{headers}=        Create Dictionary    Content-Type=application/json   Cookie=SWID={2575812E-8058-4D83-9486-CDD9149938CA};espn_s2=AEAHRfKrt7NnGesv/TJuJsEUkEI46F6gVRGITxMzRm4eSpzQWnhOZjAliZGtXp9vPGVwM1lwNtDOKJSeDOmK01tmsHrt2lM7gw3HFunGo4swhRFvb1OgUNZ6oneUMdjlzS3Ilu7ZW12fzMMw3Fy/8kxfKMPDbWgwTTfP6/vuTDKySjqjtjHy4eNexWsmZhEf3au0RReaMLKuaUEZzI+hyf9ZmVultkCn6b4TtPGdm87dNMa0OUkqgB18t2/96ZdOl83EBPmrqWfowAthxlBrHJ4bXEqo/F/ophqUCwTDmD/+GA==
    # &{payload}=        Create Dictionary     teamId=5    type=ROSTER    memberId={107F4FFD-2902-4067-80ED-1B60E523AEA6}    scoringPeriodId=23    executionType=EXECUTE    items=${items}  
    ${api_response}=    POST  url=${DELETE_API}  headers=${headers}    json=${object}    expected_status=200 
    Log To Console    ${api_response} 