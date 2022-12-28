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