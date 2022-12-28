*** Settings ***
Documentation    All the page objects and keywords of landing page
Library          SeleniumLibrary
Library          Collections
Library          lib/fantasyUI/FantasyUICustomKeywords.py
Library          RPA.RobotLogListener
Library          String

*** Variables ***
${drop_Player_Button}              //button[@data-myteam-mode='drop']
${all_player_list}                 //span[text()='DROP']
${confirm_button}                  //button[@class="Button Button--default Button--custom btn-confirm-action mb3"]
${continue_button}                 //*[@id='portal-stickybar'] //*[@class='Button Button--default Button--custom']
${active_drop_button}              //button[@title='Drop Player']
${My_team_Button_active}           //li[@class='myTeam active NavSecondary__Item']
${add_player_button}               //span[text()='Add Player']
${filter_dropdown}                  //select[@id="filterStatus"]
${freeAgents}                      //button[@class="Button Button--sm Button--default Button--custom claim-action-btn mh2"]
${lm_freeAgents}                   //button[@class='Button Button--sm Button--default Button--custom add-action-btn clr-positive mh2']
${continue_add_button}             //button[@class="Button Button--default Button--custom action-buttons"]
${cancel_button}                   //button[@class='Button Button--alt Button--custom']
${lm_tool_button}                  //span[text()='LM Tools']
${roster_moves}                    //a[normalize-space()='Roster Moves']
${action_dropdown}                 (//select[@class="dropdown__select"])[1]
${team_dropdown}                   (//select[@class="dropdown__select"])[2]
${lm_tool_continue_button}         //button[normalize-space()='Continue']
${my_team_button}                  //span[text()='My Team']

*** Keywords ***
User is navigated to teams page
  page should contain              My Team
  wait until element is visible    ${My_team_Button_active}
  page should contain element      ${My_team_Button_active}

Clicking over drop button and taking players length
  Wait Until Element Is Visible    ${Drop_Player_Button}
  # Clicking over the drop button at top right
  Click Button    ${Drop_Player_Button}
  wait until element is visible    ${all_player_list}
  # Storing all the droppable player to the list
  @{player_after_dropping}=       Get WebElements    ${all_player_list}
  # Getting length of all the droopable players 
  ${length_after_dropping}    Get Length    ${player_after_dropping}
  Set Global Variable    ${length_after_dropping}

Dropping a player from my team
  Click Button    ${Drop_Player_Button}
  wait until element is visible    ${active_drop_button}
  # Storing all the droppable player to the list
  @{drop_button}=       Get WebElements    ${active_drop_button}
  # Getting the length of all available players on the team
  ${drop}               Get Length         ${drop_button}
  wait until element is visible    ${all_player_list}
  # Getting the length of player before the player is dropped from the team
  @{player_before_dropping}=       Get WebElements    ${all_player_list}
  ${length_before_dropping}    Get Length    ${player_before_dropping}   
  IF    ${drop} != 0
    execute javascript             window.scrollTo(0, document.body.scrollHeight)
    # Selecting a player to be dropped from the team
    Click Button    ${drop_button}[0]   
    # Clicking on continue button
    wait until element is visible     ${continue_button}
    Click Button    ${continue_button}    
    # Clicking on confirm button
    wait until element is visible    ${confirm_button}
    Click Button    ${confirm_button}    
  ELSE
     Log    Droppable players are not available 
  END
  set global variable   ${length_before_dropping}

Validate whether player is dropped from team
  execute javascript             window.scrollTo(document.body.scrollHeight, 0)
  Clicking over drop button and taking players length
  IF    ${length_after_dropping} == ${length_before_dropping}
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  
  Click Button    ${cancel_button}

Adding a player to my team
  # Clicking on add player button on top right
  wait until element is visible    ${add_player_button} 
  Click Element                    ${add_player_button} 
  wait until element is visible    ${filter_dropdown}
  Select From List By Value       ${filter_dropdown}        WAIVERS
  wait until element is visible    ${freeAgents}
  # Storing all the free agent player to the list
  @{add_players}=       Get WebElements    ${freeAgents}
  ${add}               Get Length        ${add_players}
  IF    ${add} != 0
    # Selecting a player for adding to the team
    Click Button    ${add_players}[0]   
    # Clicking on continue button
    wait until element is visible     ${continue_add_button}
    Click Button    ${continue_add_button}   
    # Clicking on confirm button 
    wait until element is visible    ${confirm_button}
    Click Button    ${confirm_button}    
  ELSE
     Log    Free Agent players are not available 
  END

League Manger activities on the team 
  [Arguments]    ${action}     ${team_id}
  # Clicking on LM Tool button
  Wait Until Element Is Visible     ${lm_tool_button}
  click element                     ${lm_tool_button}
  #vClicking on Roster Moves
  wait until element is visible    ${roster_moves}
  Execute JavaScript       window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
  Click element            ${roster_moves}
  # Selecting action and teams from the dropdown 
  wait until element is visible    ${action_dropdown}
  Select From List By Value       ${action_dropdown}        ${action}      
  Select From List By Value       ${team_dropdown}          ${team_id}
  Wait Until Element Is Visible    ${lm_tool_continue_button}
  click element                    ${lm_tool_continue_button}

Adding a player to the team as LM
  wait until element is visible    ${lm_freeAgents}
  # Storing all free agents to the list
  @{lm_add_players}=       Get WebElements    ${lm_freeAgents}
  ${lm_add}               Get Length        ${lm_add_players}
  IF    ${lm_add} != 0
  # Adding a player to the team as league manager
    Click Button    ${lm_add_players}[0]  
  ELSE
     Log    Free Agent players are not available 
  END 
  Click Element    ${my_team_button}

Dropping a player from the team as LM
  wait until element is visible    ${active_drop_button}
  # Storing all droppable player to the list
  @{lm_drop_players}=       Get WebElements    ${active_drop_button}
  ${lm_drop}               Get Length        ${lm_drop_players}
  IF    ${lm_drop} != 0
  # Dropping a player from the team as league manager
    Click Button    ${lm_drop_players}[0]  
  ELSE
     Log    Free Agent players are not available 
  END 
  Click Element    ${my_team_button}

Validate whether player is added to team
  Clicking over drop button and taking players length
  wait until element is visible    ${all_player_list}
  @{player_after_adding}=       Get WebElements    ${all_player_list}
  ${length_after_adding}    Get Length    ${player_after_adding}
  IF    ${length_after_dropping} == ${length_after_adding}
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  