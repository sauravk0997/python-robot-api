*** Settings ***
Documentation    All the Common objects and keywords for adding player in the fantasy league
Library          SeleniumLibrary
Library          Collections
Library          String
Resource         resource/UI/FantasyUIcommon.resource

*** Variables ***
${DROP_PLAYER_BUTTON}               xpath://button[@data-myteam-mode='drop']
${ALL_PLAYER_LIST}                  xpath://tbody[@class='Table__TBODY']//tr//div[@title='Action']//button
${CONTINUE_BUTTON}                  xpath://span[text()='Continue']
${CONFIRM_BUTTON}                   xpath://span[text()='Confirm']
${ACTIVE_DROP_BUTTON}               xpath://button[@title='Drop Player']
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

Clicking over drop button and taking players length
  Sleep    5s
  execute javascript             window.scrollTo(document.body.scrollHeight, 100)
  Wait Until Element Is Visible    ${DROP_PLAYER_BUTTON}    timeout=10
  # Clicking over the drop button at top right
  Click Element                     ${DROP_PLAYER_BUTTON}
  wait until element is visible    ${ALL_PLAYER_LIST}
  # Storing all the droppable player to the list
  @{player_after_dropping}=       Get WebElements    ${ALL_PLAYER_LIST}
  # Getting length of all the droopable players 
  ${length_after_dropping}        Get Length         ${player_after_dropping}
  Set Global Variable                                ${length_after_dropping}

Drop a player from my fantasy team
  wait until element is visible            ${DROP_PLAYER_BUTTON}    timeout=7
  Click Element    ${DROP_PLAYER_BUTTON}
  ${Drop_players_status}    Run Keyword And Return Status    wait until element is visible            ${ACTIVE_DROP_BUTTON}    timeout=7 
  # Storing all the droppable player to the list
  IF    ${Drop_players_status} == True
    @{drop_button}=       Get WebElements    ${ACTIVE_DROP_BUTTON}
    # Getting the length of all available players on the team
    ${drop}               Get Length         ${drop_button}
    wait until element is visible            ${ALL_PLAYER_LIST}
    # Getting the length of player before the player is dropped from the team
    @{player_before_dropping}=       Get WebElements    ${ALL_PLAYER_LIST}
    ${length_before_dropping}        Get Length         ${player_before_dropping}   
    IF    ${drop} != 0
      execute javascript             window.scrollTo(0, document.body.scrollHeight)
      # Selecting a player to be dropped from the team
      Click Button                      ${drop_button}[0]   
      # Clicking on continue button
      wait until element is visible     ${CONTINUE_BUTTON}
      Click Element                     ${CONTINUE_BUTTON}    
      # Clicking on confirm button
      wait until element is visible     ${CONFIRM_BUTTON}    timeout=8
      Click Element                     ${CONFIRM_BUTTON}    
    ELSE
      Log    Droppable players are not available 
  END
  ELSE
      Log    Please add players to your team!!
  END
  set global variable   ${length_before_dropping}

Validate whether player is dropped from team
  Clicking over drop button and taking players length
  ${length_of_team}    Evaluate    ${length_before_dropping}-1
  log     "Length after dropping :::: "${length_after_dropping}
  log     "Lenght of team :::: "${length_of_team}
  IF    ${length_after_dropping} == ${length_of_team}
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  
  Click Element    ${CANCEL_BUTTON}

Add players to the team as an TO
  # Clicking on add player button on top right
  wait until element is visible    ${ADD_PLAYER_LINK} 
  Click Element                    ${ADD_PLAYER_LINK} 
  wait until element is visible    ${FILTER_DROPDOWN}
  Select From List By Value        ${FILTER_DROPDOWN}        FREEAGENT
  wait until element is visible    ${ADD_ACTION_BUTTON}    timeout=8
  # Storing all the free agent player to the list
  @{add_players}=       Get WebElements    ${ADD_ACTION_BUTTON}
  ${add}                Get Length         ${add_players}
  IF    ${add} != 0
    # Selecting a player for adding to the team
    Wait Until Element Is Visible    ${add_players}[0]    timeout=8 
    Click Button    ${add_players}[0]   
  ELSE
     Log    Free Agent players are not available 
  END
  
  wait until element is visible    ${MY_TEAM_LINK}     timeout=10
  Click Element    ${MY_TEAM_LINK}

Navigate to LM tools, Click on Roster moves and do the ${action} on the Team ${team_id} 
  # Clicking on LM Tool button
  Wait Until Element Is Visible     ${LM_TOOL_BUTTON}
  click element                     ${LM_TOOL_BUTTON}
  #vClicking on Roster Moves
  wait until element is visible    ${roster_moves}        timeout=10
  Execute JavaScript               window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
  Click element                    ${roster_moves}
  # Selecting action and teams from the dropdown 
  wait until element is visible    ${ACTION_DROPDOWN}
  Select From List By Value        ${ACTION_DROPDOWN}        ${action}      
  Select From List By Value        ${TEAM_DROPDOWN}          ${team_id}
  Wait Until Element Is Visible    ${LM_CONTINUE_BUTTON}
  click element                    ${LM_CONTINUE_BUTTON}
  Sleep    3s

Add players to the team as an LM
  wait until element is visible               ${ADD_ACTION_BUTTON}        timeout=8
  # Storing all free agents to the list
  @{lm_add_players}=       Get WebElements    ${ADD_ACTION_BUTTON}
  ${lm_add}               Get Length          ${lm_add_players}
  IF    ${lm_add} != 0
  # Adding a player to the team as league manager
    Click Button    ${lm_add_players}[0]   
  ELSE
     Log    Free Agent players are not available 
  END 
  wait until element is visible    ${MY_TEAM_LINK}
  Click Element    ${MY_TEAM_LINK}

Drop players fom the team as an LM
  ${Drop_players_status}    Run Keyword And Return Status    wait until element is visible            ${ACTIVE_DROP_BUTTON} 
  # Storing all the droppable player to the list
  @{lm_drop_players}=        Get WebElements    ${ACTIVE_DROP_BUTTON}
  IF    ${Drop_players_status} == True
    ${lm_drop}                 Get Length         ${lm_drop_players}
    wait until element is visible            ${ALL_PLAYER_LIST}
    @{player_before_dropping}=       Get WebElements    ${ALL_PLAYER_LIST}
    ${length_before_dropping}        Get Length         ${player_before_dropping}   
    IF    ${lm_drop} != 0
    # Dropping a player from the team as league manager
      Click Button    ${lm_drop_players}[0]  
      # Clicking on continue button
      wait until element is visible     ${CONTINUE_BUTTON}
      Click Element                     ${CONTINUE_BUTTON}    
      # Clicking on confirm button
      wait until element is visible     ${CONFIRM_BUTTON}
      Click Element                     ${CONFIRM_BUTTON}  
    ELSE
      Log    Droppable players are not available 
    END 
  ELSE
      Log    Please add players to your team
  END
  wait until element is visible    ${MY_TEAM_LINK}    timeout=8
  Click Element    ${MY_TEAM_LINK}
  set global variable   ${length_before_dropping}

Validate the player is added to a team
  Clicking over drop button and taking players length
  wait until element is visible                    ${ALL_PLAYER_LIST}
  @{player_after_adding}=       Get WebElements    ${ALL_PLAYER_LIST}
  ${length_after_adding}    Get Length             ${player_after_adding}
  IF    ${length_after_dropping} == ${length_after_adding}
    Log    Player is added to the team
  ELSE
    Log    Player is not added to the team
  END  