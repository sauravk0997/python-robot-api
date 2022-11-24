*** Settings ***
Resource    resource/FantasyResource.robot

*** Test Cases ***
#Working
E2E - Validate User Steps to Create Empty Teams within Leagues
    [Documentation]    ESPN Fantasy League and empty teams creation without players within leagues
    [Tags]    valid    fantasy    CSEAUTO-28333    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    #Send Invitations to team members
    Send Invitations, Accept Invitation send by inviter and Create teams
    #Accept the Invitation send by the inviter
    #Create Teams and validate the response schema
    #Delete the created league
 
 #Working
E2E - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    ESPN Fantasy League and teams creation within leagues
    [Tags]    valid    fantasy    CSEAUTO-28333    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    #Send Invitations to team members
    #Accept the Invitation send by the inviter
    Send Invitations, Accept Invitation send by inviter and Create teams
    #Create Teams and validate the response schema
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator and save the roster
    # Add players to team 1 as league creator user and save the roster
    # Add players to team 2 as team owner 2 and save the roster
    # Add players to team 3 as team owner 3 and save the roster
    # Add players to team 4 as team owner 4 and save the roster
    Delete the created league

E2E - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    ESPN Fantasy League and teams creation within leagues
    [Tags]    valid    fantasy    CSEAUTO-28333    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    #Send Invitations to team members
    #Accept the Invitation send by the inviter
    Send Invitations, Accept Invitation send by inviter and Create teams
    #Create Teams and validate the response schema
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator and save the roster
    # Add players to team 1 as league creator user and save the roster
    # Add players to team 2 as team owner 2 and save the roster
    # Add players to team 3 as team owner 3 and save the roster
    # Add players to team 4 as team owner 4 and save the roster
    Delete the created league