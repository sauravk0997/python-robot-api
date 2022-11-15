*** Settings ***
Documentation       Moving players form a fantasy league Positive tests are executing along with schema validation
...                 to run: robot --pythonpath $PWD ./testsuite/Move-Players-test.robot
Metadata    Author      Yusuf Mubarak M
Metadata    Date        14-11-2022
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    ../lib/validators/FantasyLeagueCoreValidator.py
Library     RPA.JSON
Resource    resource/FantasyLeagueResource.Robot

*** Test Cases ***
Move the Players by swaping the position of the players
    [Tags]    swap players  valid CSEAUTO-28392
    Create a League
    start offline draft
    Add Players to a team
    After adding players save the team
    ${response}    Send a Post Request to swap the position of players
    move player schema from ${response} should be valid
    Validate ${response} to check whether the players have swapped their positions

Move the Players to Bench
    [Tags]    move players to Bench  valid  CSEAUTO-28395
    ${response}     Send a Post Request to Move any Player to Bench
    move player schema from ${response} should be valid
    Validate ${response} to check whether the player is moved to Bench













