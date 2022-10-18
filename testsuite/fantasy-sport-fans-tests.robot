*** Settings ***
Library             RequestsLibrary
Library             lib.validators.FantasySportFansValidator
Library             OperatingSystem
Resource            resource/FantasySportFansAPIResource.robot

*** Test Cases ***
Validate Fantasy Sports Fans API Base Schema
    [Documentation]    ESPN Fantasy sport Fans API GET call
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    SEAUTO-27885
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid

Validate Fantasy Sports Fans API Base Schema attribute values are not null
    [Documentation]    ESPN Fantasy sports Fans API Base schema attribute values not null check
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27931
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    validate the id value from fantasy fans schema is not null ${response.json()}
    validate the anon value from fantasy fans schema is not null ${response.json()}
    validate the lastAccessDate value from fantasy fans schema is not null ${response.json()}
    validate the createDate value from fantasy fans schema is not null ${response.json()}
    validate the createSource value from fantasy fans schema is not null ${response.json()}
    validate the lastAccessDate value from fantasy fans schema is not null ${response.json()}
    validate the lastUpdateDate value from fantasy fans schema is not null ${response.json()}
    validate the lastUpdateSource value from fantasy fans schema is not null ${response.json()}

Validate Fantasy Sports Fans API Preferences and Profile exist
    [Documentation]    ESPN Fantasy sports Fans API attribute exists check
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27932
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    validate preferences exists ${response.json()}
    validate profile exists ${response.json()}

Get and Validate the count of Fantasy Sports Fans API preferences schema objects
    [Documentation]    Gets the count of preferences schema objects and validates their value
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27933
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    ${preferences_object_length}=     get the number of objects in the preferences schema ${response.json()}
    validate the ${preferences_object_length} count

Get and Validate the count of Fantasy Sports Fans API profile schema objects
    [Documentation]    Gets the count of preferences schema objects and validates their value
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27934
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    ${profile_object_length}=     get the number of objects in the profile schema ${response.json()}
    validate the ${profile_object_length} count

Validate Fantasy Sports Fans API profile schema attribute values are not null
    [Documentation]    ESPN Fantasy sports Fans API profile schema attribute values not null check
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27935
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    validate the id value from fantasy profile schema is not null ${response.json()}
    validate the createDate value from fantasy profile schema is not null ${response.json()}

Validate Deep links of Fantasy Sports Fans preferences entry schema
    [Documentation]    Gets Deep links under preferences-entry schema
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27936
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    @{logoUrl_links}=    get the logoUrl links of entry preferences schema ${response.json()}
    validate ${logoUrl_links} should respond with 200
    @{entryURL_links}=    get the entryURL links of entry preferences schema ${response.json()}
    validate ${entryURL_links} should respond with 200
    @{logoURL_links}=    get the logoURL links of entry preferences schema ${response.json()}
    validate ${logoURL_links} should respond with 200
    @{signupURL_links}=    get the signupURL links of entry preferences schema ${response.json()}
    validate ${signupURL_links} should respond with 200
    @{href_links}=    get the href links of entry preferences schema ${response.json()}
    validate ${href_links} should respond with 200
    ${scoreboardFeedURL_links}=    get the scoreboardFeedURL links of entry preferences schema ${response.json()}
    #Not doing validation for scoreboardFeedURL links because it results in a 'You are not authorized to view this League' error message
    #Validate ${scoreboardFeedURL_links} should respond with 200

Validate Deep links of Fantasy Sports Fans preferences groups schema under the entry object
    [Documentation]    Gets Deep links under preferences-entry-groups schema
    [Tags]  fantasy  valid    fantasy-fans    CSEAUTO-27358    CSEAUTO-27937
    ${response}=        A GET request to ${API_BASE} should respond with 200
    Fantasy Fans Sports Schema from ${response} should be valid
    @{href_links}=    get the href links of entry groups preferences schema ${response.json()}
    Validate ${href_links} should respond with 200
    @{fantasyCastHref_links}=    get the fantasyCastHref links of entry groups preferences schema ${response.json()}
    Validate ${fantasyCastHref_links} should respond with 200
