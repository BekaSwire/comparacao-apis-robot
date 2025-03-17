# Teste Automatizado de Comparação de APIs com Robot Framework

### 🎯 Objetivo

Este projeto automatiza a comparação de respostas de duas APIs (antiga e nova) para verificar:

- Estrutura do objeto JSON (JSON Schema: keys, tipo de campos e campos obrigatórios)
- Conteúdo das respostas (valores esperados x reais)
- Código de status HTTP retornado

A automação utiliza Robot Framework e bibliotecas específicas para análise de diferenças estruturais e de conteúdo entre os JSONs.

## 📌 1. Pré-requisitos

### 1.1. Python

- Python 3.9+ (recomendado)

### 1.2. IDE

- VS Code (ou qualquer outra IDE de sua preferência)

### 1.3. Bibliotecas Utilizadas

Este projeto utiliza as seguintes bibliotecas para facilitar a automação dos testes:

- **Robot Framework** → Framework de automação de testes estruturados e reutilizáveis.

- **RequestsLibrary** → Permite requisições HTTP para testar APIs REST.

- **JSONLibrary** → Manipulação e comparação de dados JSON.

- **PyYaml** → Processamento de arquivos YAML para configurações de ambiente.

- **OperatingSystem** → Manipulação de arquivos e diretórios no sistema operacional.

- **Collections** → Facilita o uso de listas e dicionários no Robot Framework.

- **Process** → Execução de comandos no sistema operacional.

- **Genson** → Gera JSON Schemas automaticamente a partir de dados de resposta da API.

- **DeepDiff** →  Detecta diferenças estruturais entre dois objetos JSON, como adições, remoções e modificações.

## 🚀 2. Instalação e Configuração do Ambiente

### 2.1. Instalar Python e VS Code

- Faça o download e instale o [Python](https://www.python.org/downloads/) na versão compatível com seu sistema operacional.

- Faça o download e instale o [VS Code](https://code.visualstudio.com/) (ou outra IDE de sua preferência).

### 2.2. Criar e Ativar Ambiente Virtual (venv)

Na pasta raiz do projeto, execute:

```bash
# No Git Bash
python -m venv venv            # para criar o venv
source venv/Scripts/activate   # para ativar o venv
deactivate                     # para desativar o venv

# No Powershell
.\venv\Scripts\activate.ps1    # para ativar o venv
.\venv\Scripts\deactivate.bat  # para desativar o venv
```

Depois de instalar e ativar o venv, é necessário instalar as dependências no novo ambiente.

### 2.3. Instale o Robot Framework e as Dependências

Para instalar as dependências manualmente, execute:

```Bash
pip install robotframework
pip install requests
pip install robotframework-jsonlibrary
pip install pyyaml
pip install genson
pip install deepdiff
```

Ou, para instalar todas as dependências de uma vez, utilize:

```Bash
pip install -r requirements.txt
```

**💡 Observação:**

Se precisar gerar um novo requirements.txt com todas as bibliotecas do seu ambiente, use o seguinte comando:

```Bash
pip freeze > requirements.txt
```

Isso garante que todas as dependências instaladas sejam registradas e possam ser facilmente reproduzidas em outro ambiente. 🚀

## 3. Estrutura do Projeto

```bash
📂 Desafio_Comparar_APIs/
├── 📁 _fixtures/ #Armazena os arquivos JSON de referência usados nos testes
│ ├── environments.yaml #Configurações de ambiente para a execução dos testes
│ ├── new_api.json #Resposta da nova API usada para comparação
│ ├── new_request_mock.txt #Mock da resposta da nova API (simulação para testes)
│ ├── old_api.json #Resposta da API antiga usada para comparação
│ ├── schema_new.json #JSON Schema gerado para a nova API
│ ├── schema_old.json #JSON Schema gerado para a API antiga
├── 📁 _support/ #Arquivos auxiliares para execução dos testes
│ ├── mock_api_server.py #Mock Server para simular respostas da API
│ ├── resources.resource #Recursos reutilizáveis para os testes
├── 📁 _utils/ #Módulos utilitários para suporte aos testes
│ ├── api_keywords.resource #Arquivo com keywords reutilizáveis no Robot Framework
├── 📁 logs/ #Diretório onde são armazenadas as saídas dos testes
├── 📁 tests/ #Diretório contendo os casos de teste
│ ├── IGNORE #Armazena mensagens temporárias sobre a execução, como logs de schemas gerados
│ ├── STDOUT #Armazena a saída padrão dos testes executados, útil para depuração
│ ├── test_api_comparation.robot #Arquivo principal contendo os testes de comparação de APIs
├── 📁 venv/ #Ambiente virtual contendo as dependências do projeto
├── .gitignore #Lista de arquivos/diretórios ignorados pelo Git
├── README.md #Documentação principal do projeto
└── requirements.txt #Lista de dependências para instalação
```

## 🔎 4. Como Funciona a Comparação dos Schemas JSON?

Durante a comparação, os seguintes aspectos são analisados:

- Campos adicionados na nova API

- Campos removidos que estavam na API antiga

- Modificações nos tipos de dados (ex: integer → string)

- Campos obrigatórios (required) que foram incluídos ou removidos

### Exemplo de Saída no Log:

```
📊 **Schema Comparison Report**
🔵 **OLD API Schema:** ../_fixtures/schema_old.json
🔶 **NEW API Schema:** ../_fixtures/schema_new.json
🚀 **Differences Found:** 3
🆕 **Keys Present in NEW but Missing in OLD:** ['newParameter', 'newParameter2', 'names']
🗑️ **Keys Removed from OLD API:** []
🔄 **Modified Field Types:** []
✅ **Campos Obrigatórios Alterados:** ['life_span']
```

Se **nenhuma diferença** for encontrada:

```
📊 **Schema Comparison Report**
🚀 **Differences Found:** 0
✅ No differences detected between OLD and NEW API schemas.
```

## 🛠️ 5. Execução dos Testes

### 5.1. Executar Testes Completos
O comando para executar os testes salvando os resultados na pasta logs (considerando que estamos dentro da pasta `raiz` do projeto) é:

```bash
robot -d logs tests/test_api_comparation.robot
```

### 5.2. Executar testes diretamente da pasta `tests`

Se já estiver dentro da pasta tests, utilize:

```bash
robot -d ../logs test_api_comparation.robot
```

## 🖥️ 6. Configuração do Mock API Server (Simulação da Nova API)

A **nova API** foi fornecida como um arquivo .txt, o que impede requisições HTTP diretas.
Para contornar isso, um Mock Server foi implementado, permitindo que os testes sejam executados como se a API estivesse disponível online.

Já a **API antiga** foi fornecida como uma URL acessível na web, permitindo que as requisições fossem feitas diretamente.

### 6.1. Como as APIs são acessadas nos testes?

**API Antiga** → Como foi fornecida diretamente por uma [URL](https://api.thedogapi.com/v1/breeds), os testes acessam essa API diretamente via requisições HTTP.

**API Nova** →  é simulada por um servidor local devido à sua origem em um arquivo .txt.

### 6.2. Inicialização e Finalização do Mock Server

O **Mock Server** é inicializado e finalizado automaticamente durante a execução dos testes, utilizando as keywords definidas no `Suite Setup` e `Suite Teardown`.

### **Verificação automática do Mock Server**

Para evitar conflitos, o **Mock Server** verifica automaticamente se há algum processo rodando na porta **8080** antes de iniciar. Se houver, o processo antigo é finalizado antes da nova execução. 

Isso garante que não haja múltiplos servidores rodando simultaneamente e evita falhas nos testes.

Esse comportamento já está implementado no próprio `mock_api_server.py`, portanto, **não é necessário parar manualmente um servidor antigo antes de iniciar um novo**.

### Keywords utilizadas:

- **Habilitar o firewall para permitir tráfego no mock server**

    `Enable Firewall Rule For Mock Server` → Permite temporariamente o tráfego na porta 8080 para que o Mock Server receba requisições.

- **Inicializar o Mock Server:**

    `Start Mock Api Server` → Inicia o Mock Server que simula a nova API.
    ✅ **Agora verifica e finaliza automaticamente servidores antigos antes de iniciar um novo.**

- **Finalizar o Mock Server:**

    `Stop Mock Api Server` → Para o Mock Server ao final da execução dos testes.

- **Remover a regra de firewall:**

    `Disable Firewall Rule For Mock Server` → Remove a regra do firewall para a porta 8080 após a execução dos testes.

A execução automática dessas keywords é feita no Suite Setup e Suite Teardown, conforme mostrado abaixo:

```bash
robot

Suite Setup       Run Keywords  
...               Enable Firewall Rule For Mock Server    AND  
...               Start Mock Api Server  

Suite Teardown    Run Keywords  
...               Stop Mock Api Server    AND  
...               Disable Firewall Rule For Mock Server
```

### 6.3. Inicialização Manual do Mock Server

Caso precise iniciar o Mock Server manualmente para depuração ou testes isolados, utilize:

```bash
bash

python _support/mock_api_server.py
```

**⚠️ Atenção: Verifique se há servidores antigos rodando**

Se houver um Mock Server já rodando na porta 8080, o novo servidor **não será iniciado corretamente**. Para garantir que não há conflitos, antes de iniciar um novo servidor, verifique se existe algum processo ativo:

```bash
bash

netstat -ano | findstr :8080
```

Se houver um processo na porta 8080, finalize-o com:

```bash
bash

taskkill /F /PID <PID_DO_SERVIDOR>
```

Ou, no PowerShell:

```bash
powershell

Stop-Process -Id <PID_DO_SERVIDOR>
```

Se desejar automatizar essa verificação, utilize a execução normal dos testes, pois o Mock Server já finaliza processos antigos automaticamente quando executado via Robot Framework.

##  é simulada por um servidor local devido à sua origem em um arquivo .txt.

6.1. Inicialização Automática

O Mock Server é iniciado automaticamente antes dos testes e finalizado após a execução:

Suite Setup       Run Keywords  Enable Firewall Rule For Mock Server  AND  Start Mock Api Server  
Suite Teardown    Run Keywords  Stop Mock Api Server  AND  Disable Firewall Rule For Mock Server

6.2. Inicialização Manual

Caso queira iniciar manualmente:

python _support/mock_api_server.py

Para verificar se a porta 8080 já está ocupada:

netstat -ano | findstr :8080

Para encerrar um processo ativo:

taskkill /F /PID <PID_DO_SERVIDOR>

## 📌 7. Notas Finais

### Comparação das APIs:

- **new_request_mock.txt** representa a nova API, mas como um arquivo de texto.
→ Solução: Criação de um Mock Server que responde como uma API real.

- **old_api** é a API antiga, fornecida como uma URL acessível online (https://api.thedogapi.com/v1/breeds).
→ Solução: As requisições foram feitas diretamente para essa URL, sem necessidade de simulação.

# 7.1. Como interpretar as diferenças?

- 🆕 Keys Present in NEW but Missing in OLD → Campos adicionados na nova API

- 🗑️ Keys Removed from OLD API → Campos que existiam na API antiga e não estão mais na nova

- 🔄 Modified Field Types → Tipos de dados alterados entre versões

- ✅ Campos Obrigatórios Alterados → Lista de campos que passaram a ser obrigatórios ou deixaram de ser

Esses logs ajudam a entender rapidamente quais mudanças impactam a API.

### Melhores práticas:

- Certifique-se de manter a estrutura do projeto para facilitar a manutenção e escalabilidade dos testes.

- Revise as configurações do firewall se houver problemas na execução do servidor mock.


## 🚀 Conclusão

Este projeto oferece uma automação robusta para comparar APIs e detectar mudanças de forma eficiente. Com logs bem estruturados e um Mock Server integrado, garante-se uma validação rápida e confiável das diferenças entre as versões da API.

Caso precise de suporte, contribuições são bem-vindas! 😊