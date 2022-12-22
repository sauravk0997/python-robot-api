*** Settings ***
Library   Collections
Library   OperatingSystem
Library   RPA.Browser.Selenium
Library   SeleniumLibrary
Library   RequestsLibrary
Library   ../lib/fantasyUI/FantasyDropPlayer.py
Library   lib/fantasyAPI/FantasyUtils.py
Library   lib/fantasyUI/FantasyLoginManager.py

*** Variables ***
${HOMEPAGE}                https://www.espn.com/fantasy
${BROWSER}                 Chrome
${user}                    abdultest@test.com
${encrypted_password}      U3MzVF9HKnhmLy0/UlRpOHUyOHUyOGVyanNqY2pjYjkydTkyOTIx
${greeting}                abdultest!
${decrypted_password}      YWkCXza!aUn8YMn

*** Test Cases ***
Drop a player from my team as a team manager
    # ${decrypted_password}=     Get decrypted password ${encrypted_password}
    Login Fantasy User    username=${user}    password=${decrypted_password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    Click on teams
    Click on drop button
    Click on drop player and continue
    Click on confirm drop

Drop a player from my team as a team manager
    # ${decrypted_password}=     Get decrypted password ${encrypted_password}
    Login Fantasy User    username=${user}    password=${decrypted_password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
    Click on teams
    Click on LM tools
    Click on roster moves
    Click on drop a player
