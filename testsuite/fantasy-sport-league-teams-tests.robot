*** Settings ***
Resource    resource/FantasyResource.robot

*** Test Cases ***
Validate User Steps to Create Teams within Leagues
    [Documentation]    ESPN Fantasy League and teams creation within leagues
    [Tags]    valid    fantasy    CSEAUTO-28333    CSEAUTO-28396
    Initialize the user cookie
    Create a League and validate the response schema
    Send Invitations to team members
    Accept the Invitation send by the inviter
    Create Teams and validate the response schema