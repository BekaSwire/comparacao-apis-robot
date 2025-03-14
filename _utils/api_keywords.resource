*** Settings ***
Resource    ../_support/resources.resource

*** Variables ***
${MOCK_SERVER_SCRIPT}    ${CURDIR}/../_support/mock_api_server.py
${MOCK_SERVER_PORT}      8080
${MOCK_SERVER_PID}       None

*** Keywords ***
Enable Firewall Rule For Mock Server
    [Documentation]  Temporarily allows traffic on port 8080 for the mock server
    Run Process    netsh    advfirewall    firewall    add    rule    name \"Allow Port 8080\"    dir in    action allow    protocol TCP    localport 8080    shell=True

Disable Firewall Rule For Mock Server
    [Documentation]  Removes the firewall rule for port 8080 after tests
    Run Process    netsh    advfirewall    firewall    delete    rule    name \"Allow Port 8080\"    shell=True

Start Mock Api Server
    [Documentation]  Starts the mock API server in the background and saves its PID.
    
    ${result}=  Start Process  python  ${MOCK_SERVER_SCRIPT}  shell=True
    Sleep  2s  # Tempo para iniciar o servidor

    ${pid}=  Get Process Id  ${result}
    Set Suite Variable  ${MOCK_SERVER_PID}  ${pid}

    Log  Mock API Server started with PID: ${MOCK_SERVER_PID}

Stop Mock Api Server
    [Documentation]  Stops the mock API server using taskkill on Windows.

    Run Keyword If  '${MOCK_SERVER_PID}' != 'None'
    ...    Run Keywords  
    ...    Log  Trying to stop process with PID: ${MOCK_SERVER_PID}
    ...    AND  Run Process  taskkill  /PID ${MOCK_SERVER_PID}  /F  shell=True
    ...    AND  Log  Mock API Server stopped

Load API Data
    [Documentation]  Loads API responses from OLD API (via HTTP request) and NEW API (from local file)
    ...  - Creates a session for the OLD API
    ...  - Fetches JSON data from both sources
    ...  - Stores results as suite variables
    
    Log    Loading OLD API data...
    Create Session    old_api_session    ${envs['api']['old_api']}${envs['api']['v1']}
    ${old_api_http_response}=    GET On Session    old_api_session    /
    ${old_api_json}=    Convert String To Json    ${old_api_http_response.content}
    Log    OLD API loaded successfully with status: ${old_api_http_response.status_code}

    Log    Loading NEW API data...
    Create Session    new_api_session    ${envs['api']['new_api']}
    ${new_api_http_response}=    GET On Session    new_api_session    ${envs['api']['v2']}
    ${new_api_json}=    Convert String To Json    ${new_api_http_response.content}
    Log    NEW API loaded successfully with status: ${old_api_http_response.status_code}
    
    Set Suite Variable    ${OLD_API_HTTP_RESPONSE}    ${old_api_http_response} 
    Set Suite Variable    ${NEW_API_HTTP_RESPONSE}    ${new_api_http_response} 
    Set Suite Variable    ${OLD_API_JSON}    ${old_api_json}  
    Set Suite Variable    ${NEW_API_JSON}    ${new_api_json}  
  
Compare HTTP Status Codes
    [Documentation]  Compares HTTP status codes between OLD API and NEW API
    ...  - Logs both status codes for comparison

    ${old_status}=    Set Variable    ${OLD_API_HTTP_RESPONSE.status_code}
    ${new_status}=    Set Variable    ${NEW_API_HTTP_RESPONSE.status_code}

    Run keyword If    ${old_status} == ${new_status}  
    ...    Log    ✅ OLD API and NEW API returned the same status code: ${old_status}  level=INFO
    ...  ELSE  
    ...    Fail   ❌ Status codes do not match: OLD API=${old_status}, NEW API=${new_status}
