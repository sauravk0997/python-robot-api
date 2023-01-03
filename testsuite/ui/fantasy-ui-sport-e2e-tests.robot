*** Settings ***
Resource    resource/UI/FantasyUIcommon.resource

*** Variables ***
${BASKETBALL_CREATE_LEAGUE_SLUG}    basketball/welcome?addata=fantasy_dropdown_fba2-22

*** Test Cases ***
E2E - UI- Validate User Steps to Create Empty Teams within Leagues
    [Documentation]    Create - ESPN Fantasy League and empty teams creation without players within leagues
    [Tags]    valid    fantasy-ui    CSEAUTO-29459    CSEAUTO-28396
    Launch the Browser and Navigate to the ${FANTASY_URL}${BASKETBALL_CREATE_LEAGUE_SLUG} site
    Log in to the Fantasy Application
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Delete the league

E2E - Validate User Steps as League Creator user to Create Teams with players within Leagues
    [Documentation]    Create - ESPN Fantasy League and teams creation with players as League Creator User
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Launch the Browser and Navigate to the ${FANTASY_URL}${BASKETBALL_CREATE_LEAGUE_SLUG} site
    Log in to the Fantasy Application
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    # Delete the league

E2E - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to Team2, Team3 and Team4 owners
    [Documentation]    Create - ESPN Fantasy League, Teams and assign LM roles to all team owners
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Launch the Browser and Navigate to the ${FANTASY_URL}${BASKETBALL_CREATE_LEAGUE_SLUG} site
    Log in to the Fantasy Application
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Delete the league

E2E - Validate User Steps as League Creator user to Create Teams and assign League Manager Power roles to Team2, Team3, and Team4 owners and add Players to own teams as team owners
    [Documentation]    Create - ESPN Fantasy League, Teams and assign LM roles to all team owners, add players to teams as respective team owners
    [Tags]    valid    fantasy-ui    CSEAUTO-29715    CSEAUTO-28396
    Launch the Browser and Navigate to the ${FANTASY_URL}${BASKETBALL_CREATE_LEAGUE_SLUG} site
    Log in to the Fantasy Application
    Create a league
    Send invitations, Accept Invitation send by the inviter and create teams
    Delete the league