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
    input text        ${Email_field}       sauravk0997@gmail.com
    wait until element is visible    ${Password_field}
    input password    ${Password_field}    Saurav@1103
    click button      ${login_button}

Select fantasy team from the existing league to drop players
     wait until element is visible   ${profile_Locator}
     mouse over        ${profile_Locator}
     click element      xpath:(//span[contains(text(),'UI-Automation-Testing-League-1')])[1]
