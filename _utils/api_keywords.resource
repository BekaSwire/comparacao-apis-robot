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
    ...  - Creates a session for the OLD API and the NEW API
    ...  - Fetches JSON data from both sources
    ...  - Stores results as suite variables
    ...  - Saves the API responses as JSON files for later use
    
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
    
    Set Suite Variable    ${OLD_API_URL}  ${envs['api']['old_api']}${envs['api']['v1']}
    Set Suite Variable    ${NEW_API_URL}  ${envs['api']['new_api']}${envs['api']['v2']}
    Set Suite Variable    ${OLD_API_HTTP_RESPONSE}    ${old_api_http_response} 
    Set Suite Variable    ${NEW_API_HTTP_RESPONSE}    ${new_api_http_response} 
    Set Suite Variable    ${OLD_API_JSON}    ${old_api_json}  
    Set Suite Variable    ${NEW_API_JSON}    ${new_api_json}  

    #Criação automática dos arquivos JSON
    ${fixtures_path}=    Set Variable    ../_fixtures
    ${old_json_path}=    Set Variable    ${fixtures_path}/old_api.json
    ${new_json_path}=    Set Variable    ${fixtures_path}/new_api.json

    OperatingSystem.Create Directory    ${fixtures_path}

    ${old_json_str}=    Evaluate    json.dumps(${OLD_API_JSON}, indent=4)    json
    ${new_json_str}=    Evaluate    json.dumps(${NEW_API_JSON}, indent=4)    json

    OperatingSystem.Create File    ${old_json_path}    ${old_json_str}
    OperatingSystem.Create File    ${new_json_path}    ${new_json_str}

    # Definir as variáveis globais
    Set Suite Variable  ${OLD_API_JSON_PATH}  ${old_json_path}
    Set Suite Variable  ${NEW_API_JSON_PATH}  ${new_json_path}

    Log    ✅ API responses saved as JSON files: OLD API -> ${old_json_path}, NEW API -> ${new_json_path}

Compare HTTP Status Codes
    [Documentation]  Compares HTTP status codes between OLD API and NEW API
    ...  - Logs both status codes for comparison

    ${old_status}=    Set Variable    ${OLD_API_HTTP_RESPONSE.status_code}
    ${new_status}=    Set Variable    ${NEW_API_HTTP_RESPONSE.status_code}

    Run keyword If    ${old_status} == ${new_status}  
    ...    Log    ✅ OLD API and NEW API returned the same status code: ${old_status}  level=INFO
    ...    ELSE  
    ...    Fail   ❌ Status codes do not match: OLD API=${old_status}, NEW API=${new_status}

Compare API JSON Schemas
    [Documentation]  Compara os schemas das APIs (OLD e NEW) e exibe as diferenças no log.

    Run Keyword If    '${OLD_API_JSON_PATH}' == '${EMPTY}' or '${NEW_API_JSON_PATH}' == '${EMPTY}'
    ...    Fail    ❌ ERROR: JSON files not available. Run 'Load API Data' first!

    ${result}=  Run Process    python   ../_support/generate_and_compare_schema.py
    ...    ${OLD_API_JSON_PATH}    ${NEW_API_JSON_PATH}    shell=True    stdout=STDOUT    stderr=STDERR
    ...    stderr=IGNORE

    # 📌 Separar a saída padrão e os erros
    Log    🔹 API Schema Comparison Output:\n${result.stdout}    level=INFO

    ${result_dict}=  Evaluate    json.loads('''${result.stdout}''')    json

    # Definir os caminhos dos schemas gerados
    Set Suite Variable    ${OLD_SCHEMA_PATH}    ${result_dict["old_schema_path"]}
    Set Suite Variable    ${NEW_SCHEMA_PATH}    ${result_dict["new_schema_path"]}

    # Definir diferenças detectadas
    ${added_keys}=  Set Variable    ${result_dict["differences"]["added_keys"]}
    ${removed_keys}=  Set Variable    ${result_dict["differences"]["removed_keys"]}
    ${modified_types}=  Set Variable    ${result_dict["differences"]["modified_types"]}
    ${added_required}=  Set Variable    ${result_dict["differences"]["added_required"]}
    ${removed_required}=  Set Variable    ${result_dict["differences"]["removed_required"]}
    ${total_differences}=  Evaluate    int(${result_dict["total_differences"]})  # 🚀 Garante que é um número

    # 📌 Criar um log bem estruturado com múltiplas linhas
    ${schema_comparison_log}=  Catenate
    ...  \n📊 **Schema Comparison Report**
    ...  \n🔵 **OLD API Schema:** ${OLD_SCHEMA_PATH}
    ...  \n🔶 **NEW API Schema:** ${NEW_SCHEMA_PATH}
    ...  \n🚀 **Differences Found:** ${total_differences}
    ...  \n🆕 **Keys Present in NEW but Missing in OLD:** ${added_keys}
    ...  \n🗑️ **Keys Removed from OLD API:** ${removed_keys}
    ...  \n🔄 **Modified Field Types:** ${modified_types}
    ...  \n⚠️ **Fields Newly Required in NEW API:** ${added_required}
    ...  \n❌ **Fields No Longer Required in NEW API:** ${removed_required}

    Log    ${schema_comparison_log}    level=INFO
