*** Settings ***
Documentation    All the Common objects and keywords
Library          SeleniumLibrary
Library          lib/fantasyUI/FantasyUICustomKeywords.py
Library          lib/fantasyAPI/FantasyUtils.py
Resource             resource/UI/Common/Common.resource
Resource             resource/suite_setup_teardown_moveplayer.resource

*** Variables ***
${HOMEPAGE_URL}            https://www.espn.com/
${profile_Locator}         global-user-trigger
${login_button}            xpath://button[text()='Log In']
${oneid_frame}             id:oneid-iframe
${Email_field}             id:InputLoginValue
${Password_field}          id:InputPassword
@{player_list_xpath}       //button[contains(@title,'Drop Player')]
${dropdown1}               (//select[@class="dropdown__select"])[1]
${dropdown2}               (//select[@class="dropdown__select"])[2]
${HOMEPAGE}                https://www.espn.com/fantasy
${BROWSER}                 Chrome
${user}                    abdul.waajib@zucitech.com
${encrypted_password}      OXRmQi4zWTQjOGt1ayFqc2RramNid2l1Y2gyaXUzdTNocmtqNGZramV3Zg==
${greeting}                uitest!
${league_id}               496618003

*** Keywords ***

Load players
    Initialize the user cookie
    Schedule Offline Draft
    Begin Offline Draft
    Add players to all teams as league creator user and save the roster

Select any fantasy team
    wait until element is visible   ${profile_Locator}
    mouse over        ${profile_Locator}
    wait until element is visible   xpath:(//span[contains(text(),'My-Fantasy-League-5027')])[1]
    click element      xpath:(//span[contains(text(),'My-Fantasy-League-5027')])[1]

Login into the espn site for drop
    ${decrypted_password}=    Get decrypted password ${encrypted_password}
    mouse over        ${profile_Locator}
    click button      ${login_button}
    Select Frame      ${oneid_frame}
    wait until element is visible    ${Email_field}
    input text        ${Email_field}       ${user}
    wait until element is visible    ${Password_field}
    input password    ${Password_field}    ${decrypted_password}
    click button      ${login_button}

Click on drop button
    wait until element is visible   //div[@class='action-container absolute']//button[2]
    Click Element    //div[@class='action-container absolute']//button[2]
    Sleep    5s

Click on drop button for verification
    wait until element is visible   //div[@class='action-container absolute']//button[2]
    Scroll Element Into View    //div[@class='action-container absolute']//button[2]
    Click Element    //div[@class='action-container absolute']//button[2]
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
    wait until element is visible   //button[contains(@title,'Drop Player')]
    Scroll Element Into View    //button[contains(@title,'Drop Player')]
    Sleep    5s
    Click Element    //button[contains(@title,'Drop Player')]
    wait until element is visible    //span[normalize-space()='Continue']
    Click Element    //span[normalize-space()='Continue']
    Sleep    5s

Click on drop player and continue
    wait until element is visible   //button[contains(@title,'Drop Player')]
    Execute JavaScript    window.document.evaluate("//button[contains(@title,'Drop Player')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Sleep    5s
    Click Element    //button[contains(@title,'Drop Player')]
    wait until element is visible    //span[normalize-space()='Continue']
    Click Element    //span[normalize-space()='Continue']
    Sleep    5s

check no of players available to drop
    @{player_list}=       Get WebElements    ${player_list_xpath}
    ${length}    Get Length    ${player_list}
    [Return]    ${length}

Click on confirm drop
    Wait Until Element Is Visible    //span[normalize-space()='Confirm']
    Click Element    //span[normalize-space()='Confirm']
    Sleep    10s

Click on roster moves
    wait until element is visible    //a[normalize-space()='Roster Moves']
    Execute JavaScript    window.document.evaluate("//a[normalize-space()='Roster Moves']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue.scrollIntoView(true)
    Click element    //a[normalize-space()='Roster Moves']
    Sleep    5s