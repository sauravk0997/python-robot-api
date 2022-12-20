*** Settings ***
Documentation    All the page objects and keywords of landing page
Library          SeleniumLibrary


*** Variables ***
${Move_Button}      //button[@title='MOVE']

*** Keywords ***
User is navigated to teams page
    page should contain    My Team
    @{move_button}     Get WebElements   ${Move_Button}
    ${Status}    Check for the ${move_button} in the teams page

Check for the ${move_button} in the teams page
    ${move}  get length    ${move_button}
    IF  ${move} == 0
      log to console    Lineup transaction could not be completed, as lineup is locked
      ${status}    Convert To Boolean    false
    ELSE
      ${status}    Convert To Boolean    true
    END
    [Return]    ${status}