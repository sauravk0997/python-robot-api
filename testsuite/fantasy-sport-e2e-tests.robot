*** Settings ***
Resource    resource/FantasyResource.robot
Suite Setup     Run Keywords    Initialize the user cookie
...        AND     Get all the user cookies
...        AND      Close the current Browser
#Suite Teardown     Close the current Browser

*** Test Cases ***
E2E - Validate User Steps to Create Empty Teams within Leagues
    [Documentation]    Create - ESPN Fantasy League and empty teams creation without players within leagues
    ...    Http Methods used - POST, DELETE
    [Tags]    valid    fantasy    CSEAUTO-28333    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Delete the created league
 
E2E - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    Create - ESPN Fantasy League and teams creation with players as League Creator User
    ...    Http Methods used - POST, DELETE
    [Tags]    valid    fantasy    CSEAUTO-28628    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    Delete the created league

E2E - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to Team2, Team3 and Team4 owners
    [Documentation]    Create - ESPN Fantasy League, Teams and assign LM roles to all team owners
    ...    Http Methods used - POST, DELETE, PUT
    [Tags]    valid    fantasy    CSEAUTO-28628    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Assign League Manager Roles to Team2, Team3 and Team4 owners
    Delete the created league

E2E - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to Team2, Team3, and Team4 owners and add Players to own teams as team owners
    [Documentation]    Create - ESPN Fantasy League, Teams and assign LM roles to all team owners, add players to teams as respective team owners
    ...    Http Methods used - POST, DELETE, PUT
    [Tags]    valid    fantasy    CSEAUTO-28628    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Assign League Manager Roles to Team2, Team3 and Team4 owners
    Add players to team 1 as League creator user
    Add players to team 2 as team owner 2
    Add players to team 3 as team owner 3
    Add players to team 4 as team owner 4
    Save the roster
    Delete the created league

E2E - Validate User Steps to create a league as non-league creator user
    [Documentation]    create an league as non-league creator user
    ...    Http Methods used - POST
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a league as a non-league creator user

E2E - Validate User Steps as League Creator user to create a league with an invalid team count
    [Documentation]    create a league with an invalid team count
    ...    Http Methods used - POST
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League with an invalid team count

E2E - Validate User Steps as League Creator user to create a league with invalid draft settings
    [Documentation]    create a league with invalid draft settings
    ...    Http Methods used - POST, DELETE
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft with invalid payload
    Delete the created league

E2E - Validate User Steps as League Creator user to create a league with an invalid fantasy team name
    [Documentation]    create a league with an invalid fantasy team name
    ...    Http Methods used - POST
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League with an invalid fantasy team name

E2E - Validate User Steps to Create a league and Begin the Draft with an invalid payload
    [Documentation]    Create a league and Begin the Draft with an invalid payload
    ...    Http Methods used - POST, DELETE
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft with an invalid payload
    Delete the created league

E2E - Validate User Steps to Create a league and Save the draft with an invalid payload
    [Documentation]    Create a league and Save the draft with an invalid payload
    ...    Http Methods used - POST, DELETE
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster with invalid payload
    Delete the created league

E2E - Validate User Steps as League Creator user to delete an league with an invalid league id
    [Documentation]    Delete an league with an invalid league id
    ...    Http Methods used - POST, DELETE
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Delete the invalid league

E2E - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to invalid users
    [Documentation]    Assign League Manager Power roles to invalid users
    ...    Http Methods used - POST, DELETE, PUT
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Assign League Manager Roles to invalid users
    Delete the created league

E2E - Validate User Steps as League Creator user Start drafting players without begin draft
    [Documentation]   Start drafting players without begin draft
    ...    Http Methods used - POST, DELETE
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Add players to all teams as league creator user and save the roster before draft begin
    Delete the created league

E2E - Validate User Steps as League Creator user to Create a Teams within the league with more than accepted characters for the name, abbreviation, and location fields
    [Documentation]   Create a Teams within the league with more than accepted characters for the name, abbreviation, and location fields
    ...    Http Methods used - POST, DELETE
    [Tags]    invalid    fantasy    CSEAUTO-29015    CSEAUTO-28396
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams within the league with more than accepted characters for the name, abbreviation, and location fields
    Delete the created league