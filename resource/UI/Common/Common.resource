*** Settings ***
Documentation    All the Common objects and keywords
Library          SeleniumLibrary
Library          lib/fantasyUI/FantasyUICustomKeywords.py

*** Variables ***
${HOMEPAGE_URL}        https://www.espn.com/
${profile_Locator}     global-user-trigger
${login_button}        xpath://button[text()='Log In']
${oneid_frame}         id:oneid-iframe
${Email_field}         id:InputLoginValue
${Password_field}      id:InputPassword
@{player_list_xpath}         //button[contains(@title,'Drop Player')]
${dropdown1}            (//select[@class="dropdown__select"])[1]
${dropdown2}            (//select[@class="dropdown__select"])[2]

*** Keywords ***
Launch the Browser and Navigate to Espn site
    ${Browser_path}          Get the Browser Path
    create webdriver         Chrome  executable_path=${Browser_path}
    Go To                    ${HOMEPAGE_URL}
    MAXIMIZE BROWSER WINDOW

Close Browser Session
    close browser

Login into the espn site
    mouse over        ${profile_Locator}
    click button      ${login_button}
    Select Frame      ${oneid_frame}
    wait until element is visible    ${Email_field}
    input text        ${Email_field}       abdultest@test.com
    wait until element is visible    ${Password_field}
    input password    ${Password_field}    YWkCXza!aUn8YMn
    click button      ${login_button}

Select any fantasy team from the existing league ${league_name} to move players
     wait until element is visible   ${profile_Locator}
     mouse over        ${profile_Locator}
     click element      xpath://span[text()='${league_name}']

Reset draft
    Click on LM tools
    wait until element is visible    (//a[contains(text(),'Reset Draft')])[1]
    click element    (//a[contains(text(),'Reset Draft')])[1]
    wait until element is visible    //button[normalize-space()='Reset Draft']
    click element    //button[normalize-space()='Reset Draft']
    wait until element is visible    (//button[@aria-label='Reset Draft'])[1]
    Sleep    5s
    click element    (//button[@aria-label='Reset Draft'])[1]
    Sleep    5s
    Close Browser Session

Click on LM tools
    Wait Until Element Is Visible    //span[contains(text(),'LM Tools')]
    click element       //span[contains(text(),'LM Tools')]
    Sleep    5s

Select options from dropdown
    wait until element is visible    ${dropdown1}
    Select From List By Value       ${dropdown1}        dropPlayers
    wait until element is visible    ${dropdown2}
    Select From List By Value       ${dropdown2}        2
    Wait Until Element Is Visible    //button[normalize-space()='Continue']
    click element       //button[normalize-space()='Continue']
    Sleep    3s