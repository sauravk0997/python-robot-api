*** Settings ***
Resource    resource/UI/FantasyUIcommon.resource
Test Setup    Run Keywords     Launch the Browser and Navigate to the ${FANTASY_URL}basketball/welcome?addata=fantasy_dropdown_fba2-22 site
...    AND    Log in to the Fantasy Application

*** Test Cases ***
E2E - UI- Validate User Steps to Create Empty Teams within Leagues
    [Documentation]    Create - ESPN Fantasy League and empty teams creation without players within leagues
    [Tags]    valid    fantasy-ui    CSEAUTO-29459    CSEAUTO-28396
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Delete the league

E2E - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    Create - ESPN Fantasy League and teams creation with players as League Creator User
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    Delete the league