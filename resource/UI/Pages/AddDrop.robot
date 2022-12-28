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
${freeAgent_button}                (//button[@class="Button Button--sm Button--default Button--custom claim-action-btn mh2"])[1]
${continue_add_button}             //button[@class="Button Button--default Button--custom action-buttons"]
${cancel_button}                   //button[@class='Button Button--alt Button--custom']
${lm_tool_button}

*** Keywords ***
User is navigated to teams page
  page should contain              My Team
  wait until element is visible    ${My_team_Button_active}
  page should contain element      ${My_team_Button_active}

Dropping a player from my team
  Click Button    ${Drop_Player_Button}
  wait until element is visible    ${active_drop_button}
  @{drop_button}=       Get WebElements    ${active_drop_button}
  ${drop}               Get Length         ${drop_button}
  wait until element is visible    ${all_player_list}
  @{player_before_dropping}=       Get WebElements    ${all_player_list}
  ${length_before_dropping}    Get Length    ${player_before_dropping}   
  IF    ${drop} != 0
    execute javascript             window.scrollTo(0, document.body.scrollHeight)
    Click Button    ${drop_button}[0]   
    wait until element is visible     ${continue_button}
    Click Button    ${continue_button}    
    wait until element is visible    ${confirm_button}
    Click Button    ${confirm_button}    
  ELSE
     Log    Droppable players are not available 
  END
  set global variable   ${length_before_dropping}

Validate whether player is dropped from team
  Sleep    5
  execute javascript             window.scrollTo(document.body.scrollHeight, 0)
  wait until element is visible    ${Drop_Player_Button}
  Click Button    ${Drop_Player_Button}
  wait until element is visible    ${all_player_list}
  @{player_after_dropping}=       Get WebElements    ${all_player_list}
  ${length_after_dropping}    Get Length    ${player_after_dropping}
  Log    ${length_after_dropping}
  IF    ${length_after_dropping} == (${length_before_dropping}-1)
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  
  Click Button    ${cancel_button}
  Set Global Variable    ${length_after_dropping}


Adding a player to my team
  wait until element is visible    //span[text()='Add Player']
  Click Element            //span[text()='Add Player']
  wait until element is visible    ${filter_dropdown}
  Select From List By Value       ${filter_dropdown}        WAIVERS
  wait until element is visible    ${freeAgents}
  @{add_players}=       Get WebElements    ${freeAgents}
  ${add}               Get Length        ${add_players}
  IF    ${add} != 0
    Click Button    ${freeAgent_button}   
    wait until element is visible     ${continue_add_button}
    Click Button    ${continue_add_button}    
    wait until element is visible    ${confirm_button}
    Click Button    ${confirm_button}    
  ELSE
     Log    Free Agent players are not available 
  END

Validate whether player is added to team
  wait until element is visible    ${all_player_list}
  @{player_after_adding}=       Get WebElements    ${all_player_list}
  ${length_after_dropping}    Get Length    ${player_after_adding}
  Log    ${length_after_dropping}
  IF    ${length_after_dropping} == (${player_after_adding}+1)
    Log    Player is dropped
  ELSE
    Log    Player is not dropped
  END  

Dropping a player from other team as LM

Adding a player to other team as LM
  