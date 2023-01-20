*** Settings ***
Resource    resource/UI/FantasyUIcommon.resource
Test Setup    Run Keywords     Launch the Browser and Navigate to the ${FANTASY_URL}basketball/welcome?addata=fantasy_dropdown_fba2-22 site
...    AND    Log in to the Fantasy Application

*** Test Cases ***
E2E - UI - Validate User Steps to Create Empty Teams within Leagues
    [Documentation]    Create - ESPN Fantasy League and empty teams creation without players within leagues
    [Tags]    valid    fantasy-ui    CSEAUTO-29459    CSEAUTO-28396
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Delete the league

E2E - UI - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    Create - ESPN Fantasy League and teams creation with players as League Creator User
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    Delete the league

E2E - UI - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to Team2, Team3 and Team4 owners
    [Documentation]    Create - ESPN Fantasy League, Teams and assign LM roles to all team owners
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Schedule Offline Draft
    Begin Offline Draft
    Assign League Manager Roles to Team2, Team3 and Team4 owners
    Delete the league

E2E - UI - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to Team2, Team3, and Team4 owners and add Players to own teams as team owners
    [Documentation]    Create - ESPN Fantasy League, Teams and assign LM roles to all team owners, add players to teams as respective team owners
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Schedule Offline Draft
    Assign League Manager Roles to Team2, Team3 and Team4 owners
    Begin Offline Draft
    Add players to team 1 as League creator user
    Add players to team 2 as team owner 2
    Add players to team 3 as team owner 3
    Add players to team 4 as team owner 4
    Delete the league

Validate User steps as a League Creator user to Create a Fantasy League with a lengthy league name
    [Documentation]   Validate invalid league id present
    [Tags]    invalid    fantasy-ui    CSEAUTO-28396    CSEAUTO-30052
    Create a Fantasy League with a lengthy league name and validate the error message

Validate User steps as Team Owner to Join the Fantasy League with an invalid invite Id
    [Documentation]    Join the league as an invalid user
    [Tags]    invalid    fantasy-ui    CSEAUTO-28396    CSEAUTO-30052
    Create a league
    Join invalid invite id and valid the error message
    Delete the league

Validate User steps to Join the Fantasy League as an invalid user
    [Documentation]    Join the league with an invalid invite id
    [Tags]    invalid    fantasy-ui    CSEAUTO-28396    CSEAUTO-30052
    Create a league
    Join the league as an invalid user and valid the error message
    Delete the league

Validate User steps to identify the invalid league id should not exist
    [Documentation]    Create a fantasy league with a lengthy fantasy league name
    [Tags]    invalid    fantasy-ui    CSEAUTO-28396    CSEAUTO-30052
    validate that the invalid league id is not present
