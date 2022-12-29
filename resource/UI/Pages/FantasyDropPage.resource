*** Settings ***
Documentation    All the Common objects and keywords
Library          SeleniumLibrary
Library          lib/fantasyAPI/FantasyUtils.py
Resource             resource/suite_setup_teardown_moveplayer.resource

*** Variables ***
${PROFILE_LOGIN_BUTTON}       xpath://button[text()='Log In']
@{DROP_PLAYERS_LIST}          //button[contains(@title,'Drop Player')]
${BROWSER}                    Chrome
${COMMON_DROP_BUTTON}         //div[@class='action-container absolute']//button[2]                     
${CONTINUE_BUTTON}            //span[normalize-space()='Continue']
${UNDROPPABLE_PLAYER}         //button[@aria-label="Can't drop Ja Morant"]
${CONFIRM_BUTTON}             //span[normalize-space()='Confirm']
${user}                       uitest3_user_account@test.com
${encrypted_password}         OXRmQi4zWTQjOGt1ayFqc2RramNid2l1Y2gyaXUzdTNocmtqNGZramV3Zg==
${greeting}                   uitest!
${league_id}                  792931688

*** Keywords ***

Load players
    Initialize the user cookie
    Close the current active browser
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster

Login into the espn site for drop
    ${decrypted_password}=    Get decrypted password ${encrypted_password}
    mouse over        ${profile_icon}
    click button      ${PROFILE_LOGIN_BUTTON}
    Select Frame      ${oneid_frame}
    wait until element is visible    ${username_field}
    input text        ${username_field}       ${user}
    wait until element is visible    ${Password_field}
    input password    ${Password_field}    ${decrypted_password}
    click button      ${PROFILE_LOGIN_BUTTON}

Click on drop button
    wait until element is visible   ${COMMON_DROP_BUTTON}
    Click Element    ${COMMON_DROP_BUTTON}
    Sleep    5s

Click on drop button for verification
    wait until element is visible   ${COMMON_DROP_BUTTON}
    Scroll Element Into View    ${COMMON_DROP_BUTTON}
    Click Element    ${COMMON_DROP_BUTTON}
    Sleep    5s

Verify the player has been dropped
    Reload Page
    Sleep    5s
    Click on drop button for verification
    ${after_drop}    check no of players available to drop
    [Return]    ${after_drop}
    
Verify the player has been dropped inside LM tools
    Reload Page
    Sleep    5s
    ${after_drop}    check no of players available to drop
    [Return]    ${after_drop}

Click on drop player and continue in LM tools
    wait until element is visible   ${DROP_PLAYERS_LIST}
    Scroll Element Into View    ${DROP_PLAYERS_LIST}
    Sleep    5s
    Click Element    ${DROP_PLAYERS_LIST}
    wait until element is visible    ${CONTINUE_BUTTON}
    Click Element    ${CONTINUE_BUTTON}
    Sleep    5s

Click on drop undroppable player and continue in LM tools
    wait until element is visible   ${UNDROPPABLE_PLAYER}
    Scroll Element Into View    ${UNDROPPABLE_PLAYER}
    Sleep    5s
    Click Element    ${UNDROPPABLE_PLAYER}
    wait until element is visible    ${CONTINUE_BUTTON}
    Click Element    ${CONTINUE_BUTTON}
    Sleep    5s

Click on drop player and continue
    wait until element is visible   ${DROP_PLAYERS_LIST}
    Execute JavaScript    window.document.evaluate("//button[contains(@title,'Drop Player')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Sleep    5s
    Click Element    ${DROP_PLAYERS_LIST}
    wait until element is visible    ${CONTINUE_BUTTON}
    Click Element    ${CONTINUE_BUTTON}
    Sleep    5s

check no of players available to drop
    @{player_list}=       Get WebElements    ${DROP_PLAYERS_LIST}
    ${length}    Get Length    ${player_list}
    [Return]    ${length}

Click on confirm drop
    Wait Until Element Is Visible    ${CONFIRM_BUTTON}
    Click Element    ${CONFIRM_BUTTON}
    Sleep    10s
