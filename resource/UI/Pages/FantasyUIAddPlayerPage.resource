*** Settings ***
Documentation    All the Common objects and keywords for adding player in the fantasy league
Library          Collections
Resource         resource/UI/FantasyUIcommon.resource
Resource         resource/UI/FantasyUICommonMove.resource

*** Variables ***
${DROP_PLAYER_BUTTON}                    css:button[data-myteam-mode='drop']
${ALL_PLAYER_LIST}                       xpath://tbody[@class='Table__TBODY']//tr//div[@title='Action']//button
${CONTINUE_BUTTON}                       xpath://span[text()='Continue']/parent::button
${CONFIRM_BUTTON}                        xpath://span[text()='Confirm']
${ACTIVE_DROP_BUTTON}                    css:button[title='Drop Player']
${MY_TEAM_LINK}                          xpath://span[text()='My Team']
${ADD_PLAYER_LINK}                       xpath://span[text()='Add Player']
${FILTER_DROPDOWN}                       id:filterStatus
${ADD_ACTION_BUTTON}                     xpath://td//div[@title='Action']//button[1]
${CANCEL_BUTTON}                         xpath://span[text()='Cancel']
${LM_TOOL_BUTTON}                        xpath://span[text()='LM Tools']
${ROSTER_MOVES}                          xpath://a[normalize-space()='Roster Moves']
${ACTION_DROPDOWN}                       xpath:(//select[@class="dropdown__select"])[1]
${LM_CONTINUE_BUTTON}                    xpath://button[normalize-space()='Continue']
${TEAM_DROPDOWN}                         xpath:(//select[@class="dropdown__select"])[2]
${LEAGUE_DROPDOWN}                       xpath:(//span[text()='Team Kumar'])[1]
${POSITION_C_PLAYERS}                    xpath://span[starts-with(text(),'C') and @class='playerinfo__playerpos ttu']
${POSITION_C_PLAYERS_ADD_BUTTON}         xpath://span[starts-with(text(),'C') and @class='playerinfo__playerpos ttu']/ancestor::tr/td[3]/div/div/div/button[1]
${FILTER_C_BUTTON}                       xpath://label[normalize-space()='C']
${NON_POSITION_C_PLAYER_DROP_BUTTONS}    xpath://span[not(starts-with(text(),'C'))][@class='playerinfo__playerpos ttu']/ancestor::tr/td[3]/div/div/button[@title='Drop Player']
${OPPOSING_TEAMS}                        xpath://span[text()='Opposing Teams']

*** Keywords ***
validate the user is navigated to the teams page
  page should contain              My Team
  wait until element is visible    ${MY_TEAM_LINK}
  page should contain element      ${MY_TEAM_LINK}

Click on my team link
  wait until element is visible    ${MY_TEAM_LINK}        timeout=10s
  Click Element                    ${MY_TEAM_LINK}

Click on continue button
  wait until element is visible     ${CONTINUE_BUTTON}          timeout=10s
  Click Element                     ${CONTINUE_BUTTON}

Click on confirm button
  wait until element is visible     ${CONFIRM_BUTTON}            timeout=10s
  Click Element                     ${CONFIRM_BUTTON} 

Click on drop player button
  Sleep    5s
  Scroll up
  Wait Until Element Is Visible     ${DROP_PLAYER_BUTTON}        timeout=10s
  Click Element                     ${DROP_PLAYER_BUTTON}

Click on the add player button
  wait until element is visible    ${ADD_PLAYER_LINK} 
  Click Element                    ${ADD_PLAYER_LINK} 

Fetch all the Free agents
  wait until element is visible    ${FILTER_DROPDOWN}
  Select From List By Value        ${FILTER_DROPDOWN}        FREEAGENT

Click on the LM Tool button
  Wait Until Element Is Visible     ${LM_TOOL_BUTTON}
  click element                     ${LM_TOOL_BUTTON}

Click on the Roster Moves
  wait until element is visible    ${roster_moves}        timeout=10s
  Execute JavaScript               window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
  Click element                    ${roster_moves}

Fetch the size of roster of the team
  wait until element is visible    ${ALL_PLAYER_LIST}
  # Storing all the droppable player to the list
  @{player_before_dropping}=       Get WebElements    ${ALL_PLAYER_LIST}
  # Getting length of all the droopable players 
  ${player_before_dropping}        Get Length         ${player_before_dropping}
  Set Global Variable                                ${player_before_dropping}

Drop a player from my fantasy team
  Click on drop player button
  ${drop_players_status}    Run Keyword And Return Status    wait until element is visible            ${ACTIVE_DROP_BUTTON}    timeout=7s
  # Storing all the droppable player to the list
  IF    ${drop_players_status} == True
    @{drop_button}=       Get WebElements    ${ACTIVE_DROP_BUTTON}
    # Getting the length of all available players on the team
    ${drop}               Get Length         ${drop_button}
    wait until element is visible            ${ALL_PLAYER_LIST}
    # Getting the length of player before the player is dropped from the team
    @{players_before_dropping}=       Get WebElements    ${ALL_PLAYER_LIST}
    ${length_before_dropping}        Get Length         ${players_before_dropping}
    set global variable   ${length_before_dropping}
    IF    ${drop} != 0
      execute javascript             window.scrollTo(0, document.body.scrollHeight)
      # Selecting a player to be dropped from the team
      Click Button                      ${drop_button}[0]   
      Click on continue button  
      Click on confirm button  
    ELSE
      Log    Droppable players are not available 
    END
  ELSE
      Log    Please add players to your team!!
  END
  
Validate whether player is dropped from team
  Click on my team link
  Click on drop player button
  Fetch the size of roster of the team
  ${total_players_in_a_team}    Evaluate    ${length_before_dropping}-1
  IF    ${player_before_dropping} == ${total_players_in_a_team}
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  
  Click Element    ${CANCEL_BUTTON}

Add a player as Team Owner
  Click on the add player button
  Fetch all the Free agents
  wait until element is visible    ${ADD_ACTION_BUTTON}    timeout=8s
  # Storing all the free agent player to the list
  @{addable_players}=       Get WebElements    ${ADD_ACTION_BUTTON}
  ${addable_players_length}                Get Length         ${addable_players}
  IF    ${addable_players_length} != 0
    # Selecting a player for adding to the team
    Wait Until Element Is Visible    ${addable_players}[0]    timeout=8s
    Click Button    ${addable_players}[0]   
  ELSE
     Log    Free Agent players are not available 
  END
  
Add players to the team as a Team Owner
  Add a player as Team Owner
  Click on my team link

Navigate to LM tools, Click on Roster moves and do the ${action} on the Team ${team_id} 
  Click on the LM Tool button
  Click on the Roster Moves
  # Select action and team from the dropdown 
  wait until element is visible    ${ACTION_DROPDOWN}
  Select From List By Value        ${ACTION_DROPDOWN}       ${action}
  Select From List By Value        ${TEAM_DROPDOWN}         ${team_id}
  Wait Until Element Is Visible    ${LM_CONTINUE_BUTTON}
  click element                    ${LM_CONTINUE_BUTTON}

Add players to the team as an LM
  wait until element is visible               ${ADD_ACTION_BUTTON}        timeout=8s
  # Storing all free agents to the list
  @{lm_addable_players}=       Get WebElements    ${ADD_ACTION_BUTTON}
  ${lm_add_players_length}               Get Length          ${lm_addable_players}
  IF    ${lm_add_players_length} != 0
  # Adding a player to the team as league manager
    Click Button    ${lm_addable_players}[0]
  ELSE
     Log    Free Agent players are not available
  END 
  
Perform drop action to drop a player
  ${droppable_players_status}    Run Keyword And Return Status    wait until element is visible            ${ACTIVE_DROP_BUTTON}    timeout=7s 
  IF    ${droppable_players_status} == True
    Execute JavaScript               window.document.evaluate("(//button[@title='Drop Player'])[1]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Click Element      (//button[@title='Drop Player'])[1]
    Click on continue button 
    Click on confirm button 
  ELSE 
    log    Droppable players are not available.
  END

Add and drop a player from my team as an LM, when roster is full
  Click on drop player button
  Fetch the size of roster of the team
  IF    ${player_before_dropping} == 13
    Click on my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 1
    Add players to the team as an LM
    Click on my team link
    Scroll up
    Perform drop action to drop a player
  ELSE 
      Log    Please fill your roster by addding players to it.
  END

Drop players fom the team as an LM
  ${droppable_players_status}    Run Keyword And Return Status    wait until element is visible            ${ACTIVE_DROP_BUTTON} 
  # Storing all the droppable player to the list
  @{lm_droppable_players}=        Get WebElements    ${ACTIVE_DROP_BUTTON}
  IF    ${droppable_players_status} == True
    ${lm_droppable_players_length}                Get Length           ${lm_droppable_players}
    wait until element is visible                 ${ALL_PLAYER_LIST}
    @{players_before_dropping}=                   Get WebElements      ${ALL_PLAYER_LIST}
    ${length_before_dropping}                     Get Length           ${players_before_dropping}   
    IF    ${lm_droppable_players_length} != 0
    # Dropping a player from the team as league manager
      Scroll up
      Click Button    ${lm_droppable_players}[0]  
      Click on continue button  
      Click on confirm button
    ELSE
      Log    Droppable players are not available 
    END 
  ELSE
      Log    Please add players to your team
  END
  set global variable   ${length_before_dropping}

Validate the player is added to a team
  Click on drop player button
  Fetch the size of roster of the team
  Click on my team link
  wait until element is visible                    ${ALL_PLAYER_LIST}
  @{player_after_adding}=       Get WebElements    ${ALL_PLAYER_LIST}
  ${length_after_adding}    Get Length             ${player_after_adding}
  IF    ${player_before_dropping} == ${length_after_adding}
    Log    Player is added to the team
  ELSE
    Log    Player is not added to the team
  END
  
Add and drop a player when team roster is full
  Click on drop player button
  Fetch the size of roster of the team
  IF    ${player_before_dropping} == 13
    Click on my team link
    Add players to the team as a Team Owner
    Perform drop action to drop a player
  ELSE
      Log    Please fill your roster by addding players to it.
  END
  Click on my team link

Add and drop a player from other team as an LM, when roster is full
  Click on drop player button
  Fetch the size of roster of the team
  IF    ${player_before_dropping} == 13
    Click on my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 3
    Add players to the team as an LM
    Click on my team link
    Scroll up
    Perform drop action to drop a player
  ELSE 
      Log    Please fill your roster by addding players to it.
  END

Switch to the league ${league_name}
  Click on my team link
  wait until element is visible    ${LEAGUE_DROPDOWN}       timeout=10s
  mouse over 		                   ${LEAGUE_DROPDOWN}
  click element                    //span[normalize-space()='${league_name}']

Add a player when the roster is full as Team Owner
  Click on drop player button
  Fetch the size of roster of the team
  IF    ${player_before_dropping} == 13
    Click on my team link
    Add a player as Team Owner
    Wait Until Element Is Visible    ${CONTINUE_BUTTON} 
    Element Should Be Disabled       ${CONTINUE_BUTTON}
  ELSE 
    Log    Your roster is not full. Please add players to fill your roster
  END

Validate players are addable when the roster is full
   Add a player when the roster is full as Team Owner

Fetch the length of Position C Players from the team
  Wait Until Element Is Visible              ${POSITION_C_PLAYERS}
  @{droppable_position_C_players}=           Get WebElements    ${POSITION_C_PLAYERS}
  ${length_of_position_C_players}            Get Length         ${droppable_position_C_players}
  Set Global Variable                        ${length_of_position_C_players} 

Add Position C Free Agent Players
  wait until element is visible            ${POSITION_C_PLAYERS_ADD_BUTTON}
  # Storing all the p[osition C player to the list
  @{addable_position_C_players}=           Get WebElements    ${POSITION_C_PLAYERS_ADD_BUTTON}
  ${addable_position_C_players_length}     Get Length         ${addable_position_C_players}
  IF    ${addable_position_C_players_length} != 0
    # Selecting a position C player for adding to the team
    Wait Until Element Is Visible    ${addable_position_C_players}[0]
    Click Element    ${addable_position_C_players}[0]
    sleep     3s
  ELSE
      Log    Position C Free Agent players are not available 
  END

Drop a non Positon C Player
  Wait Until Element Is Visible        ${NON_POSITION_C_PLAYER_DROP_BUTTONS}
  @{non_position_C_drop_button}=       Get WebElements    ${NON_POSITION_C_PLAYER_DROP_BUTTONS}
  # Getting the length of all available non Position C players on the team
  ${drop}               Get Length         ${non_position_C_drop_button}
  IF    ${drop} != 0
    execute javascript             window.scrollTo(0, document.body.scrollHeight)
    # Selecting a non position C player to be dropped from the team
    Wait Until Element Is Visible      ${non_position_C_drop_button}[0] 
    Click Element                      ${non_position_C_drop_button}[0]
    Click on continue button
    Click on confirm button
  ELSE
    Log    Non Positoin C Droppable players are not available 
  END

Add Position C player to my team as Team Owner
  Click on my team link
  Fetch the length of Position C Players from the team
  IF    ${length_of_position_C_players} == 4
    Click on the add player button
    Fetch all the Free agents
    Click Element                    ${FILTER_C_BUTTON}
    Add Position C Free Agent Players
  ELSE
    log    Your roster is having less than 4 Position C player. Please add Position C players to the roster. There should be at least 4 Position C player in the roster. 
  END

Drop a non-Position C Player from the team
  ${drop_players_status}    Run Keyword And Return Status    wait until element is visible            ${ACTIVE_DROP_BUTTON}    timeout=7s
  IF    ${drop_players_status} == True
    Drop a non Positon C Player
  ELSE 
    Log    Please add players to your team!!  
  END

Select any Opposition Team, Team ${team_id}
  wait until element is visible      ${OPPOSING_TEAMS}
  mouse over 		                     ${OPPOSING_TEAMS}
  wait until element is visible      //span[text()='Team ${team_id} (TM${team_id})']    timeout=8s
  Click Element                      //span[text()='Team ${team_id} (TM${team_id})']

Add Position C player to another team ${team_id} as an LM
  Fetch the length of Position C Players from the team
  IF    ${length_of_position_C_players} == 4
      Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team ${team_id}
      Fetch all the Free agents
      Click Element                    ${FILTER_C_BUTTON}
      Add Position C Free Agent Players
  ELSE
      Log       Your roster is having less than 4 Position C player. Please add Position C players to the roster. There should be at least 4 Position C player in the roster. 
  END

Validate players are addable when the roster is full to the team ${team_id} as League Manager
  Fetch the size of roster of the team
  IF    ${player_before_dropping} == 13
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team ${team_id}
    Add players to the team as an LM
    Wait Until Element Is Visible    ${CONTINUE_BUTTON} 
    Element Should Be Disabled       ${CONTINUE_BUTTON}
  ELSE 
    Log    Your roster is not full. Please add players to fill your roster
  END
   
Validate that the player is not added to your team with the error message ${message}.
  ${error_message}   Convert to String     ${message}
  Wait Until Element Is Visible            //div[text()='${message}'] 
  ${error_text}      get text              //div[text()='${message}']
  Should Be Equal    ${error_message}      ${error_text}