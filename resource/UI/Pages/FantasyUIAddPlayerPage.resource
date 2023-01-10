*** Settings ***
Documentation    All the Common objects and keywords for adding player in the fantasy league
Library          Collections
Resource         resource/UI/FantasyUIcommon.resource
Resource         resource/UI/FantasyUICommonMove.resource

*** Variables ***
${DROP_PLAYER_BUTTON}               css:button[data-myteam-mode='drop']
${ALL_PLAYER_LIST}                  xpath://tbody[@class='Table__TBODY']//tr//div[@title='Action']//button
${CONTINUE_BUTTON}                  xpath://span[text()='Continue']
${CONFIRM_BUTTON}                   xpath://span[text()='Confirm']
${ACTIVE_DROP_BUTTON}               css:button[title='Drop Player']
${MY_TEAM_LINK}                     xpath://span[text()='My Team']
${ADD_PLAYER_LINK}                  xpath://span[text()='Add Player']
${FILTER_DROPDOWN}                  id:filterStatus
${ADD_ACTION_BUTTON}                xpath://td//div[@title='Action']//button[1]
${CANCEL_BUTTON}                    xpath://span[text()='Cancel']
${LM_TOOL_BUTTON}                   xpath://span[text()='LM Tools']
${ROSTER_MOVES}                     xpath://a[normalize-space()='Roster Moves']
${ACTION_DROPDOWN}                  xpath:(//select[@class="dropdown__select"])[1]
${TEAM_DROPDOWN}                    xpath:(//select[@class="dropdown__select"])[2]
${LM_CONTINUE_BUTTON}               xpath://button[normalize-space()='Continue']

*** Keywords ***
validate the user is navigated to the teams page
  page should contain              My Team
  wait until element is visible    ${MY_TEAM_LINK}
  page should contain element      ${MY_TEAM_LINK}

Click on the my team link
  wait until element is visible    ${MY_TEAM_LINK}        timeout=10s
  mouse over                       ${MY_TEAM_LINK} 
  Click Element                    ${MY_TEAM_LINK}

Click on continue button
  wait until element is visible     ${CONTINUE_BUTTON}    timeout=10s
  Click Element                     ${CONTINUE_BUTTON} 

Click on confirm button
  wait until element is visible     ${CONFIRM_BUTTON}     timeout=10s
  Click Element                     ${CONFIRM_BUTTON} 

Click on drop player button
  Wait Until Element Is Visible     ${DROP_PLAYER_BUTTON}        timeout=10s
  mouse Over                        ${DROP_PLAYER_BUTTON}
  Click Element                     ${DROP_PLAYER_BUTTON}

Click on the drop button and fetch the players length
  Sleep    5s
  Scroll up
  Click on drop player button
  wait until element is visible    ${ALL_PLAYER_LIST}
  # Storing all the droppable player to the list
  @{player_after_dropping}=       Get WebElements    ${ALL_PLAYER_LIST}
  # Getting length of all the droopable players 
  ${length_after_dropping}        Get Length         ${player_after_dropping}
  Set Global Variable                                ${length_after_dropping}

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
  set global variable   ${length_before_dropping}

Validate whether player is dropped from team
  Click on the my team link
  Click on the drop button and fetch the players length
  ${total_players_in_a_team}    Evaluate    ${length_before_dropping}-1
  IF    ${length_after_dropping} == ${total_players_in_a_team}
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  
  Click Element    ${CANCEL_BUTTON}

Add a player as Team Owner
  # Clicking on add player button on top right
  wait until element is visible    ${ADD_PLAYER_LINK} 
  Click Element                    ${ADD_PLAYER_LINK} 
  wait until element is visible    ${FILTER_DROPDOWN}
  Select From List By Value        ${FILTER_DROPDOWN}        FREEAGENT
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
  Click on the my team link

Navigate to LM tools, Click on Roster moves and do the ${action} on the Team ${team_id} 
  # Clicking on LM Tool button
  Wait Until Element Is Visible     ${LM_TOOL_BUTTON}
  click element                     ${LM_TOOL_BUTTON}
  #Clicking on Roster Moves
  wait until element is visible    ${roster_moves}        timeout=10s
  Execute JavaScript               window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
  Click element                    ${roster_moves}
  # Selecting action and teams from the dropdown 
  wait until element is visible    ${ACTION_DROPDOWN}
  Select From List By Value        ${ACTION_DROPDOWN}        ${action}      
  Select From List By Value        ${TEAM_DROPDOWN}          ${team_id}
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
  Click on the my team link
  Scroll up
  
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
  Click on the drop button and fetch the players length
  IF    ${length_after_dropping} == 13
    Click on the my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 1
    Add players to the team as an LM
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
  Click on the drop button and fetch the players length
  Click on the my team link
  wait until element is visible                    ${ALL_PLAYER_LIST}
  @{player_after_adding}=       Get WebElements    ${ALL_PLAYER_LIST}
  ${length_after_adding}    Get Length             ${player_after_adding}
  IF    ${length_after_dropping} == ${length_after_adding}
    Log    Player is added to the team
  ELSE
    Log    Player is not added to the team
  END
  
Add and drop a player when team roster is full
  Click on the drop button and fetch the players length
  IF    ${length_after_dropping} == 13
    Click on the my team link
    Add players to the team as a Team Owner
    Perform drop action to drop a player
  ELSE
      Log    Please fill your roster by addding players to it.
  END
  Click on the my team link

Add and drop a player from other team as an LM, when roster is full
  Click on the drop button and fetch the players length
  IF    ${length_after_dropping} == 13
    Click on the my team link
    Navigate to LM tools, Click on Roster moves and do the addPlayers on the Team 3
    Add players to the team as an LM
    Perform drop action to drop a player
  ELSE 
      Log    Please fill your roster by addding players to it.
  END