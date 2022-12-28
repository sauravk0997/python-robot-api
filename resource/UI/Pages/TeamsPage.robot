*** Settings ***
Documentation    All the page objects and keywords of landing page
Library          SeleniumLibrary
Library          Collections
Library          lib/fantasyUI/FantasyUICustomKeywords.py

*** Variables ***
${My_team_Button_active}                 xpath://li[@class='myTeam active NavSecondary__Item']
${moveable_lineup_player}                xpath://div[not(@title='Bench') and @class='jsx-2810852873 table--cell']//ancestor::tr//child::td[3]//descendant::button
${lineup_players_eligible_slots}         xpath://button[@title='MOVE']//ancestor::td//preceding::td[2]/div[not(text()='Bench')]//following::div[7]/span[2]
${lineup_moveable_player_name}           xpath://button[@title='MOVE']//ancestor::td//preceding::td[2]/div[not(text()='Bench')]//following::div[1]
${here_player_name}                      xpath://button[@title='HERE']//ancestor::td//preceding::td[1]/div
${lineup_player_on_slot_prefix}          xpath://button[@title='MOVE']//ancestor::td//preceding::td[2]/div[not(text()='Bench')]
${empty_bench_locator}                   xpath://div[@title='Bench']//following::div[1][contains(@title,"Player")]//following::button
${lineup_player_locator}                 xpath://button[@title='MOVE']//ancestor::td//preceding::td[2]/div[not(text()='Bench')]     #wrong
${moveable_bench_player_locator}         xpath://div[@title='Bench']//following::div[1]//following::button
${empty_lineup_slot}                     xpath://div[@title='Player']//parent::td//preceding::td[1]/div[not(text()='IR')]//following::div[6]/button[@title="HERE"]
${lineup_player_here_button}             xpath://button[@title='HERE']
${moveable_bench_player_name}            xpath://button[@title='MOVE']//ancestor::td//preceding::td[2]/div[text()='Bench']//following::div[1]

*** Keywords ***
User is navigated to teams page
    execute javascript             window.scrollTo(0, document.body.scrollHeight)
    page should contain            My Team
    wait until element is visible  ${My_team_Button_active}
    page should contain element    ${My_team_Button_active}

Check for the players in the team who are available to move from there existing positions
    wait until element is visible                ${moveable_lineup_player}     10s
    @{move_button_players}    Get WebElements    ${moveable_lineup_player}
    ${move}            get length                ${move_button_players}
    IF  ${move} == 0
      log to console    Lineup transaction could not be completed, as lineup is locked
      ${status}         convert to boolean    false
    ELSE
      ${status}         convert to boolean    true
    END
    set global variable   ${status}

Swap the Position of the players in the current scoring period
    IF  ${status} == True
       @{move_button}       Get WebElements     ${moveable_lineup_player}
       @{locators}          create list         ${move_button}   ${lineup_players_eligible_slots}  ${lineup_moveable_player_name}  ${lineup_player_on_slot_prefix}
       @{player_details}    get the player details    ${locators}
       @{Before_swapping_player_details}    Get the details of the players before swapping and then swap their position    ${player_details}
       set global variable    ${Before_swapping_player_details}
    END

Verify whether the player swapped their Position
  IF  ${status} == True
  ${length}    get length    ${Before_swapping_player_details}
    IF    ${length} != 0
       Assert whether the player swapped their Position      ${Before_swapping_player_details}
    ELSE
       log to console    currently no players are available to swap their positions
    END
  END

Check and Move any eligible existing lineup player to Bench
       wait until element is visible          ${lineup_player_locator}    10s
       @{move_button_lineup_players}       Get WebElements    ${moveable_lineup_player}
       ${length_moveable_lineup_Player}    get length        ${move_button_lineup_players}
       IF   ${length_moveable_lineup_Player} != 0
           ${random_player}     Get random player no in range of ${move_button_lineup_players}
           ${player_names}      Get WebElements         ${lineup_moveable_player_name}
           ${Player_name_for_moving_to_Bench}       get element attribute    ${player_names}[${random_player}]     title
           scroll element into view    ${move_button_lineup_players}[${random_player}]
           click button     ${move_button_lineup_players}[${random_player}]
           ${bench_status}    RUN KEYWORD AND RETURN STATUS    wait until element is visible    ${empty_bench_locator}     10s
           IF    ${bench_status} == True
              scroll element into view    ${empty_bench_locator}
              click button    ${empty_bench_locator}
              set global variable    ${Player_name_for_moving_to_Bench}
              set global variable    ${bench_status}
           ELSE
              log to console    currently no lineup player can be moved to Bench
              ${bench_status}    convert to boolean    false
              set global variable    ${bench_status}
           END
       ELSE
          log to console        Lineup transaction could not be completed, as lineup is locked
       END

Verify whether the Player is Moved to Bench
    IF    ${bench_status} == True
        ${slot_of_player}    get text    //div[@title="${Player_name_for_moving_to_Bench}"]//preceding::div[1][contains(@class,"table--cell")]
        should be equal    ${slot_of_player}        Bench
    END

Move any eligible Bench Player to lineup
    wait until element is visible            ${moveable_bench_player_locator}      10s
    @{bench_players}      get webelements    ${moveable_bench_player_locator}
    ${length_of_moveable_bench_player}    get length    ${bench_players}
    set global variable    ${length_of_moveable_bench_player}
    IF    ${length_of_moveable_bench_player} != 0
        ${random_no}     Get random player no in range of ${bench_players}
        @{player}      get webelements       ${moveable_bench_player_name}
        scroll element into view    ${bench_players}[${random_no}]
        click button    ${bench_players}[${random_no}]
        ${bench_player_moved_lineup}    get element attribute   ${player}[${random_no}]     title
        set global variable     ${bench_player_moved_lineup}
        ${empty_lineup}    run keyword and return status   wait until element is visible    ${empty_lineup_slot}     10s
        IF    ${empty_lineup} == True
           scroll element into view    ${empty_lineup_slot}
           click button    ${empty_lineup_slot}
           ${bench_player_moved_lineup_status}    convert to boolean    true
           set global variable    ${bench_player_moved_lineup_status}
        ELSE
          wait until element is visible            ${lineup_player_here_button}    10s
          @{lineup_players}     Get WebElements    ${lineup_player_here_button}
          ${length_of_moveable_lineup_player}     get length    ${lineup_players}
          IF    ${length_of_moveable_lineup_player} != 0
             ${random_player}    Get random player no in range of ${lineup_players}
             scroll element into view    ${lineup_players}[${random_player}]
             click button    ${lineup_players}[${random_player}]
             sleep    5s
             ${bench_player_moved_lineup_status}    convert to boolean    true
             set global variable    ${bench_player_moved_lineup_status}
          ELSE
            ${bench_player_moved_lineup_status}      convert to boolean    false
            log to console    currently no Bench player can be moved to lineup
          END
        END
    END

Verify whether the Player is Moved to Lineup
   IF   ${length_of_moveable_bench_player} != 0
      IF   ${bench_player_moved_lineup_status} == True
         ${slot_of_player}    get text    //div[@title="${bench_player_moved_lineup}"]//preceding::div[1][contains(@class,"table--cell")]
         should not be equal    ${slot_of_player}     Bench
      END
   END

