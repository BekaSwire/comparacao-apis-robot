*** Settings ***
# LIBRARY IMPORTS
Library    RequestsLibrary
Library    JSONLibrary        
Library    OperatingSystem
Library    Collections
Library    Process

# KEYWORDS
Resource   ../_utils/api_keywords.resource

# ENVIRONMENTS
Variables    ../_fixtures/environments.yaml