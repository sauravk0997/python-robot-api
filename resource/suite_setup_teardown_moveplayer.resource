*** Settings ***
Documentation       A resource robot file which includes all comm utils/functions and variables related to Fantasy League
Library             RequestsLibrary
Library             RPA.JSON
Library             Collections
Library             String
Library             OperatingSystem
Library             lib/validators/FantasyMovePlayerValidator.py
Resource            resource/FantasyResource.robot
*** Variables ***
${FANTASY_URL}                                https://fantasy.espn.com
${BASKETBALL_SPORT}                           fba
${SEASON}                                     2023
${SEGMENT}                                    0

*** Keywords ***
Get a Fantasy League details
    [Documentation]    Create - ESPN Fantasy League and teams creation and adding players to team
    Initialize the user cookie
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    set global variable    &{header_value}
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster
    set suite variable    ${MovePlayer_url}   ${FANTASY_URL}/apis/v3/games/${BASKETBALL_SPORT}/seasons/${SEASON}/segments/${SEGMENT}/leagues/${leagueid}/transactions/

Delete League
    Delete the created league


