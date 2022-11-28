*** Settings ***
Resource    resource/FantasyResource.robot

*** Test Cases ***
E2E - Validate User Steps to Create Empty Teams within Leagues
    [Documentation]    ESPN Fantasy League and empty teams creation without players within leagues
    [Tags]    valid    fantasy    CSEAUTO-28333    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Delete the created league
 
E2E - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    ESPN Fantasy League and teams creation within leagues as League Creator User
    [Tags]    valid    fantasy    CSEAUTO-28628    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    Delete the created league

E2E - Validate User Steps as League Creator user to Create Teams with players within Leaguesssssssssss
    [Documentation]    ESPN Fantasy League and teams creation within leagues
    [Tags]    valid    fantasy    CSEAUTO-28628    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    # Add players to all teams as league creator user and save the roster
    #To do
    Assign League Manager Roles to Team2, Team3 and Team4 owners
    # Add players to team 1 as league creator user and save the roster
    # Add players to team 2 as team owner 2 and save the roster
    # Add players to team 3 as team owner 3 and save the roster
    # Add players to team 4 as team owner 4 and save the roster
    Delete the created league