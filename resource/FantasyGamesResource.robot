*** Settings ***
Documentation       All Common robot utils/functions and variables with respect to
...                 ESPN Fantasy Games API are maintained here
Library             RequestsLibrary
Library             OperatingSystem

*** Variables ***
${API_BASE}=        https://fantasy.espn.com/apis/v3/games/FFL/?platform=cinco_18914&view=cinco_wl_gameState&rand=27741223  # tests default to the sandbox environment
${cleanup}=         ${False}  # False is a built-in RF variable
${EXP_CURRENT_SEASON_ID}=   2022

*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    ${api_response}=    GET  url=${endpoint}  expected_status=${status}
    [Return]    ${api_response}