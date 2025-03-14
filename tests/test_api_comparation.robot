*** Settings ***
Resource    ../_support/resources.resource

Suite Setup    Run Keywords
...    Enable Firewall Rule For Mock Server    AND
...    Start Mock Api Server
               
Suite Teardown    Run Keywords
...    Stop Mock Api Server    AND
...    Disable Firewall Rule For Mock Server

*** Test Cases ***
Test Load API Data
    [Documentation]  Tests if API responses are being loaded correctly
    Load API Data
    Log    OLD API JSON: ${OLD_API_JSON}
    Log    NEW API JSON: ${NEW_API_JSON}

Test Compare HTTP Status Codes
    [Documentation]  Tests if the HTTP status codes of OLD and NEW API match
    Load API Data
    Compare HTTP Status Codes
    
