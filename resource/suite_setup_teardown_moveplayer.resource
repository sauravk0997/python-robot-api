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
${espn_cookie}           SWID={95096766-E11A-4C94-BB21-2BA8F8C0D3EF}; espn_s2=AECrGNEO5w1VlDOoJEgL1wquDjPrYr1r0XR9A5zJln93t968%2BICfJi3k32jhzzwTZpEzvBWbOf0%2FFx0ObwGqatXTiooE1n3SkjICYmcbiqCYUJjHQp6e9JyUT67qTYAVlmpWwiir8Auj6AMyk5Du%2BySpeboBjJLUm%2BPGsk7ajvLy26t8PgyzWpnbM8EzazCCLqAkeLNjEe1PdV6%2FmHj9t2fZgfusdIAns%2FpsBtgNQtBnzwhFUhrJ6JvyLFF0syVwv%2FGszPfVEzIwfOtXGHbSkdsI3WlAqQc61wm6q%2BkLeUxVnw%3D%3D;

*** Keywords ***
Get a Fantasy League details
    [Documentation]    Create - ESPN Fantasy League and teams creation and adding players to team
    &{header_value}=    create dictionary     cookie=${espn_cookie}
    set global variable    &{header_value}
    Create a League and validate the response schema
    Send Invitations, Accept Invitation send by inviter and Create teams
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster

Delete League
    Delete the created league


