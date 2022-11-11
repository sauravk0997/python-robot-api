*** Settings ***
Library             RequestsLibrary
Library             OperatingSystem
Library             Collections
Library             DateTime

*** Variables ***
${TOKEN}=    %7B6E458CFC-7B0E-4811-8B3D-504CF5F7D4C0%7D
${QUERY_PARAM}=    displayHiddenPrefs=true&context=fantasy&useCookieAuth=true&source=fantasyapp-ios&featureFlags=challengeEntries
${API_BASE}=        https://fan.api.espn.com/apis/v2/fans/${TOKEN}?${QUERY_PARAM}


*** Keywords ***
A GET request to ${endpoint} should respond with ${status}
    [Documentation]     Custom GET keyword with status validation.
    ${api_response}=    GET  url=${endpoint}  expected_status=${status}
    [Return]    ${api_response}

A POST request to ${endpoint} should respond with ${status}
    [Documentation]     Custom POST keyword with status validation.
    ${api_response}=    POST  url=${endpoint}  expected_status=${status}
    [Return]    ${api_response}