*** Settings ***
Library   Collections
Library   OperatingSystem
Library   base64
Library   RequestsLibrary
Library  lib/fantasyUI/FantasyLoginManager.py
Library   lib/fantasyUI/FantasyUtils.py

*** Variables ***
${HOMEPAGE}     https://www.espn.com/fantasy/
${BROWSER}      Chrome
${user}          abdul.waajib@gmail.com
${password}      S3NScSkkQTVxMlMmaDVoaWNpamozamppanNqY2prY2thZG5ja3NuY2tzbmtuYw==
${greeting}      Abdul!

*** Keywords ***
Auth with Cookie Capture
   ${credentials}=     Get user credentials ${password}
   Login Fantasy User    username=${user}    password=${credentials}  expected_profile_name_span_value=${greeting}   url=${HOMEPAGE}
   ${espn_cookie}=     Fantasy API Cookie
   [Return]    ${espn_cookie}

 Close the current active browser
    Browser shutdown