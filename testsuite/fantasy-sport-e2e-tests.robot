*** Settings ***
Resource    resource/FantasyResource.robot
Test Setup    Initialize the user cookie
Test Teardown    Close the current Browser

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