*** Settings ***
Documentation    All the Common objects and keywords
Library          lib/fantasyAPI/FantasyUtils.py
Resource         resource/suite_setup_teardown_moveplayer.resource
Resource         resource/UI/FantasyUIcommon.resource

*** Variables ***
${PROFILE_LOGIN_BUTTON}       xpath://button[text()='Log In']
@{DROP_PLAYERS_LIST}          //button[contains(@title,'Drop Player')]
${BROWSER}                    Chrome
${COMMON_DROP_BUTTON}         //div[@class='action-container absolute']//button[2]                     
${CONTINUE_BUTTON}            //span[normalize-space()='Continue']
${UNDROPPABLE_PLAYER}         //button[contains(@aria-label,"Can't drop")]
${CONFIRM_BUTTON}             //span[normalize-space()='Confirm']
${OUT_STATUS}                 //span[@title='Out']
${DTD_STATUS}                 //span[@title='Day-To-Day'']

*** Keywords ***
Click on drop button
    wait until element is visible   ${COMMON_DROP_BUTTON}
    Scroll Element Into View    ${COMMON_DROP_BUTTON}
    Click Element    ${COMMON_DROP_BUTTON}
    Wait Until Page Contains Element    @{DROP_PLAYERS_LIST}  

Verify the player has been dropped
    Reload Page
    Sleep    3s
    Click on drop button
    ${after_drop}    check no of players available to drop
    [Return]    ${after_drop}
    
Verify the player has been dropped inside LM tools
    Reload Page
    Sleep    5s
    ${after_drop}    check no of players available to drop
    [Return]    ${after_drop}

Click on drop player button and continue in LM tools
    wait until element is visible   ${DROP_PLAYERS_LIST}
    Scroll Element Into View    ${DROP_PLAYERS_LIST}
    Click Element    ${DROP_PLAYERS_LIST}
    Click on continue button

Click on drop player button and continue
    wait until element is visible   ${DROP_PLAYERS_LIST}
    Execute JavaScript    window.document.evaluate("//button[contains(@title,'Drop Player')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Click Element    ${DROP_PLAYERS_LIST}
    Click on continue button

Click on drop undroppable player and continue in LM tools
    Scroll Element Into View    ${UNDROPPABLE_PLAYER}
    wait until element is visible   ${UNDROPPABLE_PLAYER}
    Click Element    ${UNDROPPABLE_PLAYER}
    Click on continue button

Click on multiple players to drop
    wait until element is visible   ${DROP_PLAYERS_LIST}
    Execute JavaScript    window.document.evaluate("//button[contains(@title,'Drop Player')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Select multiple players
    Click on continue button

Click on multiple players to drop in LM tools
    Select multiple players
    Click on continue button

Get player name whose status is ${status}
    ${player_name}=    Get Element Attribute    //span[@title='${status}']//parent::div    title
    Check if ${player_name} is an undroppable player
    IF    ${undroppable_check} == ${TRUE}
            Scroll Element Into View    //button[@aria-label="Can't drop ${player_name}"]
            Click Element    //button[@aria-label="Can't drop ${player_name}"]
    ELSE
            Execute JavaScript    window.document.evaluate("//button[@aria-label='Drop Player ${player_name}']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
            Click Element    //button[@aria-label='Drop Player ${player_name}']
    END
    Click on continue button
    Click on confirm button

check no of players available to drop
    @{player_list}=       Get WebElements    ${DROP_PLAYERS_LIST}
    ${length}    Get Length    ${player_list}
    [Return]    ${length}

Click on confirm button
    Wait Until Element Is Visible    ${CONFIRM_BUTTON}
    Click Element    ${CONFIRM_BUTTON}

Select roster moves in LM tools
    Click on LM tools
    Click on roster moves
    Select options from dropdown

Check availability for ${status} player and drop
    Set availability true
    Scroll Element Into View    //span[@title='${status}']
    ${player_count} =   Get Element Count   //span[@title='${status}']    
    Run Keyword If    ${player_count}>0    
    ...    Get player name whose status is ${status} 
    ...  ELSE    Run Keywords
    ...    Set availability false
    
Set availability ${avail}
    ${avail}         convert to boolean    ${avail}
    Set Global Variable       ${avail}

Check if ${player_name} is an undroppable player
    ${json}     load json from file           resource/UI/undroppable_players.json
    ${undroppable_check}    Set Variable    False
    Convert To Boolean    ${undroppable_check}
    FOR    ${index}    IN RANGE    21
      ${name}     get value from json     ${json}      $.Player${index}
      IF    "${player_name}" == "${name}"
          ${undroppable_check}    Set Variable    True
          Convert To Boolean    ${undroppable_check}
      END
    END
    Set Global Variable       ${undroppable_check}

Click on continue button
    wait until element is visible    ${CONTINUE_BUTTON}
    Click Element    ${CONTINUE_BUTTON}

Select multiple players
    Wait Until Element Is Visible   (//button[contains(@title,'Drop Player')])[1]
    Click Element    (//button[contains(@title,'Drop Player')])[1]
    Wait Until Element Is Visible    (//button[contains(@title,'Drop Player')])[2]
    Click Element    (//button[contains(@title,'Drop Player')])[2]

Verify that ${status} player has been dropped
    IF    ${avail} == ${TRUE}
      ${after_drop}    Verify the player has been dropped inside LM tools
      Should Be Equal    ${${before_drop}-1}    ${after_drop}
    ELSE
      Log To Console    "No ${status} players in the team"
    END

Select my team and check the available players
    Select my fantasy team
    Click on drop button
    ${before_drop}    check no of players available to drop
    Set Global Variable    ${before_drop}

Verify if the player has been dropped from teams page
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Verify if the player has been dropped from LM tools page
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-1}    ${after_drop}

Select a team from LM tools
    Select roster moves in LM tools
    ${before_drop}    check no of players available to drop
    Set Global Variable    ${before_drop}

Drop a player from the team
    Click on drop player button and continue
    Click on confirm button

Drop a player from the team inside LM tools
    Click on drop player button and continue in LM tools
    Click on confirm button

Select undroppable player and drop
    Click on drop undroppable player and continue in LM tools
    Click on confirm button

Select multiple players and drop inside LM tools
    Click on multiple players to drop in LM tools
    Click on confirm button

Select multiple players and drop
   Click on multiple players to drop
    Click on confirm button

Verify multiple players have been dropped inside LM tools
    ${after_drop}    Verify the player has been dropped inside LM tools
    Should Be Equal    ${${before_drop}-2}    ${after_drop}

Verify multiple players have been dropped
    ${after_drop}    Verify the player has been dropped
    Should Be Equal    ${${before_drop}-2}    ${after_drop}
