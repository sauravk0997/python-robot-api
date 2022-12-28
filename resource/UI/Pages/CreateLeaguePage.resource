*** Variables ***
${FANTASY_PROFILE_ICON}       css:[role='button']
${FANTASY_LOGIN_LINK}         xpath://li//span[text()='Log In']
${DISNEY_ID_IFRAME}           id:disneyid-iframe
${LOGOUT_LINK}                xpath://li//span[text()='Log Out']
${CREATE_A_LEAGUE_BUTTON}     xpath://button[contains(text(),'Create a League')]
${CREATE_LEAGUE_BUTTON}       xpath://button[.='Create League']
${LEAGUE_NAME_INPUT_FIELD}    css:.form__control.LeagueNameInput
${LEAGUE_SIZE_4}              css:.LeagueSizeRadioGroup__ControlLabel:nth-of-type(1)
${SCORING_H2H_POINTS}         css:.LargeRadioGroup__ControlLabel:nth-of-type(2)
${CLOSE_ICON}                 css:.lightbox__closebtn__wrap
${INVITE_MANAGERS}            xpath://a[text()='Invite Managers']
${INVITE_LINK_TEXT}           xpath://input[@id='invite_link_input_text']
${JOIN_THIS_LEAGUE_BUTTON}    xpath://button[contains(text(),'Join This League')]
${TEAM_LOCATION}              css:[data-name='teamLocation']
${TEAM_NICKNAME}              css:[data-name='teamNickName']
${TEAM_ABBREVIATION}          css:[data-name='teamAbbrev']
${FINISH_BUTTON}              css:.join-league-form__finish
${MY_TEAMS_ICON}              css:.myTeams.NavSecondary__Item>a>svg
${LM_TOOLS}                   xpath://span[text()='LM Tools']
${DELETE_LEAGUE_TEXT}         xpath://a[text()='Delete League']
${DELETE_LEAGUE_BUTTON}       xpath://button[text()='Delete League']
${CONFIRM_TEXT}               xpath://span[text()='Confirm']
${SUCCESS_HEADING}            css:.success-heading
