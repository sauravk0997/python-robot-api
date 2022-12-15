*** Settings ***
Library   Collections
Library   OperatingSystem
Library   RequestsLibrary
Library  lib/fantasyUI/FantasyLoginManager.py
Library   lib/fantasyUI/FantasyUtils.py

*** Variables ***
${HOMEPAGE}                https://www.espn.com/fantasy/
${BROWSER}                 Chrome
${user}                    test_user_account@test.com
${encrypted_password}      U3MzVF9HKnhmLy0/UlRpOHUyOHUyOGVyanNqY2pjYjkydTkyOTIx
${greeting}                test!

*** Keywords ***
Auth with Cookie Capture
   ${decrypted_password}=     Get decrypted password ${encrypted_password}
   Login Fantasy User    username=${user}    password=${decrypted_password}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
   ${espn_cookie}=     Fantasy API Cookie
   [Return]    ${espn_cookie}

 Close the current active browser
    Browser shutdown