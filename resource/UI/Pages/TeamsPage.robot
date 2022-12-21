*** Settings ***
Documentation    All the page objects and keywords of landing page
Library          SeleniumLibrary
Library          Collections


*** Variables ***
${Move_Button}                     //button[@title='MOVE']
${My_team_Button_active}          //li[@class='myTeam active NavSecondary__Item']
${Eligible_slots_of_players}     //*[@class="playerinfo__playerpos ttu"]

*** Keywords ***
User is navigated to teams page
    page should contain            My Team
    wait until element is visible  ${My_team_Button_active}
    page should contain element    ${My_team_Button_active}

Check for the players in the team who are available to move
    @{move_button}     Get WebElements   ${Move_Button}
    ${move}            get length    ${move_button}
    IF  ${move} == 0
      log to console    Lineup transaction could not be completed, as lineup is locked
      ${status}    Convert To Boolean    false
    ELSE
      ${status}    Convert To Boolean    true
    END
    set global variable    ${status}
    set global variable    ${move_button}

check for the players who can swap their positions based on the availability of players who are eligible for move
    IF    ${status} == True
       ${index}=   Set Variable    0
       @{slots}     get webelements     ${Eligible_slots_of_players}
       @{slot_prefix_of_all_players}    create list
       FOR    ${element}    IN    @{move_button}
              ${slot_prefix_of_player}    get text    ${slots}[${index}]
              Append to List    ${slot_prefix_of_all_players}    ${slot_prefix_of_player}
              ${index}     evaluate    ${index} + 1
       END
        ${slot_prefix_length}    get length    ${slot_prefix_of_all_players}
    ELSE
       Log to Console   Players are not available
    END