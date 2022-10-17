*** Settings ***
Library             RequestsLibrary
Library             lib.validators.FantasySportFansValidator
Library             OperatingSystem
Resource            resource/FantasySportFansAPIResource.robot

*** Test Cases ***
Get Fantasy Sport Fans API Responses
    [Documentation]    ESPN Fantasy sport Fans API GET call
    [Tags]  fantasy  valid    fantasy-fans
    ${response}=        A GET request to ${API_BASE} should respond with 200
    #JSON Schema validation
    Fantasy Fans Sports Schema from ${response} should be valid
    #key exists or not
    Is preferences present in ${response.json()}
    Is profile present in ${response.json()}
    #get number of objects
    get the count of preferences objects in preferences from ${response.json()}
    get the count of profile objects in profile from ${response.json()}
    #Fans Schema validation
    get the id from fantasy fans schema ${response.json()}
    get the anon from fantasy fans schema ${response.json()}
    get the lastAccessDate from fantasy fans schema ${response.json()}
    get the createDate from fantasy fans schema ${response.json()}
    get the createSource from fantasy fans schema ${response.json()}
    get the lastAccessDate from fantasy fans schema ${response.json()}
    get the lastAccessSource from fantasy fans schema ${response.json()}
    get the lastUpdateDate from fantasy fans schema ${response.json()}
    get the lastUpdateSource from fantasy fans schema ${response.json()}
    #profile Schema validation
    get the id from fantasy profile schema ${response.json()}
    get the createDate from fantasy profile schema ${response.json()}