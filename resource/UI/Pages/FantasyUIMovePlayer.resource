*** Settings ***
Documentation    All the page objects and keywords of landing page
Library          SeleniumLibrary    run_on_failure=None
Library          Collections
Library          lib/fantasyUI/FantasyUIutils.py
Library          String

*** Variables ***
${My_TEAM_ACTIVE}                         xpath://li[@class='myTeam active NavSecondary__Item']
${MOVEABLE_LINEUP_PLAYER}                 xpath://div[not(@title='Bench') and @class='jsx-2810852873 table--cell']//ancestor::tr//descendant::button
${LINEUP_PLAYERS_ELIGIBLE_SLOTS}          xpath://div[not(@title='Bench') and @class='jsx-2810852873 table--cell']//ancestor::tr//child::button//preceding::td[1]//descendant::span[@class='playerinfo__playerpos ttu']
${LINEUP_MOVEABLE_PLAYER_NAME}            xpath://button[@title='MOVE']//preceding::td[2]/div[not(text()='Bench')]//following::div[1]
${LINEUP_PLAYERS_ON_SLOT_PREFIX}          xpath://button[@title='MOVE']//preceding::td[2]/div[not(text()='Bench')]
${EMPTY_BENCH_LOCATOR}                    xpath://div[@title='Bench']//following::div[contains(@title,"Player")]//following::button
${MOVEABLE_BENCH_PLAYER}                  xpath://div[@title='Bench']//following::button[@title="MOVE"]
${EMPTY_LINEUP_SLOT}                      xpath://div[@title='Player']//preceding::td[@style='width: 60px;']/div[not(text()='IR')]//following::div[@aria-label="Move"]//descendant::button
${LINEUP_PLAYER_HERE_BUTTON}              xpath://button[@title='HERE']
${BENCH_MOVEABLE_PLAYER_NAME}             xpath://button[@title='MOVE']//preceding::div[text()='Bench']//following::div[contains(@class,'cell player__column') and not(@title='Player')]
${DROPDOWNS}                              xpath://select[@class='dropdown__select']
${CONTINUE_BUTTON}                        xpath://button[text()='Continue']
${FUTURE_DATES}                           xpath://div[contains(@class,'custom--day is-current')]//following::div[contains(@class,'custom--day')]/span[contains(@class,'day day--date')]
${MY_TEAM}                                xpath://span[text() ='My Team']

*** Keywords ***
Navigate to Fantasy Team Page
     wait until element is visible    ${MY_TEAM}       timeout=10s
     click element                    ${MY_TEAM}

Select any team in the league from edit roster page
    @{options}     get webelements    ${DROPDOWNS}
    wait until element is visible     ${options}[0]
    select from list by value         ${options}[0]        editRoster
    ${random_value}    generate random string            1        234
    wait until element is visible     ${options}[1]
    select from list by value         ${options}[1]        ${random_value}
    click button                      ${CONTINUE_BUTTON}

validate the user is navigated to the teams page
    wait until element is visible  ${My_TEAM_ACTIVE}
    page should contain element    ${My_TEAM_ACTIVE}
    page should contain            My Team
    execute javascript             window.scrollTo(0, document.body.scrollHeight)

Check for the players in the team who are available to move from there existing positions
    @{move_button_players}    Get WebElements    ${MOVEABLE_LINEUP_PLAYER}
    ${move}            get length                ${move_button_players}
    IF  ${move} == 0
      log    Lineup transaction could not be completed, as lineup is locked
      ${status}         convert to boolean    false
    ELSE
      ${status}         convert to boolean    true
    END
    set global variable   ${status}

Swap the Position of the players in the current scoring period
    IF  ${status} == True
       @{move_button_lineup_player}       Get WebElements     ${MOVEABLE_LINEUP_PLAYER}
       @{locators}          create list         ${move_button_lineup_player}    ${LINEUP_PLAYERS_ELIGIBLE_SLOTS}  ${LINEUP_MOVEABLE_PLAYER_NAME}  ${LINEUP_PLAYERS_ON_SLOT_PREFIX}
       @{player_details}    get the player details    ${locators}
       @{Before_swapping_player_details}    Get the details of the players before swapping and then swap their position    ${player_details}
       set global variable    ${Before_swapping_player_details}
    END

Select any Future Date
    @{future_dates}     get webelements        ${FUTURE_DATES}
    ${length_of_future_dates}  get length      ${future_dates}
    ${random_date}      Get random player no in range of ${future_dates}
    Scroll Element Into View    ${future_dates}[${random_date}]
    ${get_date}         get text   ${future_dates}[${random_date}]
    Reload Page
    register keyword to run on failure    Get the Web element based on the ${length_of_future_dates} and ${get_date}
    ${element}   Get the Web element based on the ${length_of_future_dates} and ${get_date}
    click element         ${element}
    sleep    2


Check and Move any eligible existing lineup player to Bench
       @{move_button_lineup_players}       Get WebElements    ${MOVEABLE_LINEUP_PLAYER}
       ${length_moveable_lineup_Player}    get length        ${move_button_lineup_players}
       IF   ${length_moveable_lineup_Player} != 0
           ${random_player}     Get random player no in range of ${move_button_lineup_players}
           ${player_names}      Get WebElements         ${LINEUP_MOVEABLE_PLAYER_NAME}
           scroll element into view    ${move_button_lineup_players}[${random_player}]
           ${Player_name_for_moving_to_Bench}       get element attribute    ${player_names}[${random_player}]     title
           click button     //div[@title="${Player_name_for_moving_to_Bench}"]//following::button[contains(@aria-label,"${Player_name_for_moving_to_Bench}")]
           ${bench_status}    RUN KEYWORD AND RETURN STATUS    wait until element is visible    ${EMPTY_BENCH_LOCATOR}     timeout=10s
           IF    ${bench_status} == True
              scroll element into view    ${EMPTY_BENCH_LOCATOR}
              click button    ${EMPTY_BENCH_LOCATOR}
              set global variable    ${Player_name_for_moving_to_Bench}
              set global variable    ${bench_status}
           ELSE
              log    currently no lineup player can be moved to Bench
              ${bench_status}    convert to boolean    false
              set global variable    ${bench_status}
           END
       ELSE
          log        Lineup transaction could not be completed, as lineup is locked
          ${bench_status}    convert to boolean    false
          set global variable    ${bench_status}
       END

Move any eligible Bench Player to lineup
    @{bench_players}      get webelements    ${MOVEABLE_BENCH_PLAYER}
    ${length_of_moveable_bench_player}    get length    ${bench_players}
    set global variable    ${length_of_moveable_bench_player}
    IF    ${length_of_moveable_bench_player} != 0
        ${random_no}     Get random player no in range of ${bench_players}
        @{player}      get webelements       ${BENCH_MOVEABLE_PLAYER_NAME}
        scroll element into view    ${bench_players}[${random_no}]
        ${bench_player_moved_lineup}    get element attribute   ${player}[${random_no}]     title
        click button    ${bench_players}[${random_no}]
        set global variable     ${bench_player_moved_lineup}
        ${empty_lineup}    run keyword and return status   wait until element is visible    ${EMPTY_LINEUP_SLOT}     timeout=10s
        IF    ${empty_lineup} == True
           scroll element into view    ${EMPTY_LINEUP_SLOT}
           click button    ${EMPTY_LINEUP_SLOT}
           ${bench_player_moved_lineup_status}    convert to boolean    true
           set global variable    ${bench_player_moved_lineup_status}
        ELSE
          wait until element is visible            ${LINEUP_PLAYER_HERE_BUTTON}    timeout=10s
          @{lineup_players}     Get WebElements    ${LINEUP_PLAYER_HERE_BUTTON}
          ${length_of_moveable_lineup_player}     get length    ${lineup_players}
          IF    ${length_of_moveable_lineup_player} != 0
             ${random_player}    Get random player no in range of ${lineup_players}
             scroll element into view    ${lineup_players}[${random_player}]
             click button    ${lineup_players}[${random_player}]
             ${bench_player_moved_lineup_status}    convert to boolean    true
             set global variable    ${bench_player_moved_lineup_status}
          ELSE
            ${bench_player_moved_lineup_status}      convert to boolean    false
            log   currently no Bench player can be moved to lineup
          END
        END
    END

Verify whether the player swapped their Position
  IF  ${status} == True
  ${length}    get length    ${Before_swapping_player_details}
    IF    ${length} != 0
       Assert whether the player swapped their Position      ${Before_swapping_player_details}
    ELSE
       log    currently no players are available to swap their positions
    END
  END

Verify whether the Player is Moved to Bench
    IF  ${bench_status} == True
        ${slot_of_player}    get text    //div[@title="${Player_name_for_moving_to_Bench}"]//preceding::div[1][contains(@class,"table--cell")]
        should be equal    ${slot_of_player}        Bench
    END

Verify whether the Player is Moved to Lineup
   IF  ${bench_player_moved_lineup_status} == True
       ${slot_of_player}    get text    //div[@title="${bench_player_moved_lineup}"]//preceding::div[1][contains(@class,"table--cell")]
       should not be equal    ${slot_of_player}     Bench
   END


    
