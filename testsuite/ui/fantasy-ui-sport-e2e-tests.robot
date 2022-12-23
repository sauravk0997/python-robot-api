*** Settings ***
Resource    resource/UI/FantasyUIcommon.resource

*** Variables ***
${FANTASY_URL}     https://fantasy.espn.com/
${BASKETBALL_CREATE_LEAGUE_SLUG}    basketball/welcome?addata=fantasy_dropdown_fba2-22


*** Keywords ***


*** Test Cases ***
E2E - UI- Validate User Steps to Create Empty Teams within Leagues
    Launch the Browser and Navigate to the ${FANTASY_URL}${BASKETBALL_CREATE_LEAGUE_SLUG} site
    Log in to the Fantasy Application
    Create a league