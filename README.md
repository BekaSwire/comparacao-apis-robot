# Teste Automatizado de Comparação de APIs com Robot Framework

### Objetivo
Este projeto tem como objetivo comparar automaticamente respostas obtidas de duas APIs diferentes (antiga e nova), verificando:

- Estrutura do objeto JSON
- Conteúdo das respostas (valores esperados x reais)
- Código de status HTTP retornado

## 1. Pré-requisitos

### 1.1. Python
- Python 3.9+ (recomendado)

### 1.2. IDE
- VS Code (ou qualquer outra IDE de sua preferência)

### 1.3. Bibliotecas Utilizadas
Este projeto utiliza as seguintes bibliotecas para facilitar a automação dos testes:

- Robot Framework → Framework de automação utilizado para escrever, executar e gerenciar testes de forma legível e estruturada.

- RequestsLibrary → Biblioteca que permite realizar requisições HTTP para testar APIs REST.

- JSONLibrary → Biblioteca para manipulação, validação e comparação de dados no formato JSON.

- OperatingSystem → Biblioteca que permite interagir com o sistema operacional, como manipulação de arquivos e diretórios.

- Collections → Biblioteca que facilita o uso de listas e dicionários no Robot Framework.

- Process → Biblioteca usada para executar comandos no sistema operacional, como iniciar e finalizar processos (exemplo: iniciar o servidor mock).

## 2. Instalação e Configuração do Ambiente

### 2.1. Instalar Python e VS Code

- Faça o download e instale o [Python](https://www.python.org/downloads/) na versão compatível com seu sistema operacional.

- Faça o download e instale o [VS Code](https://code.visualstudio.com/) (ou outra IDE de sua preferência).

### 2.2. Criar e Ativar Ambiente Virtual (venv)

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

### Instale o Robot Framework e as Dependências

pip install robotframework
pip install requests
pip install robotframework-jsonlibrary

## 3. Estrutura do Projeto

```bash
📂 Desafio_Comparar_APIs/
├── 📁 _fixtures/
│ └── new_request_mock.txt #Mock de resposta da nova API
├── 📁 _support/
│ ├── mock_api_server.py #Mock Server
│ ├── resources.resource #Arquivos de suporte
├── 📁 _utils/
│ ├── api_keywords.resource #Keywords reutilizáveis
├── 📁 logs/ #Saída dos testes
├── 📁 tests/
│ ├── test_api_comparation.robot #Arquivo principal de testes
├── 📁 venv/ #Ambiente virtual para instalação das dependências
└── README.md
```

## 4. Configuração do Mock API Server (Simulação da Nova API)

A **nova API** foi fornecida como um arquivo .txt, o que impede requisições HTTP diretas.
Para contornar isso, um Mock Server foi implementado, permitindo que os testes sejam executados como se a API estivesse disponível online.

Já a **API antiga** foi fornecida como uma URL acessível na web, permitindo que as requisições fossem feitas diretamente.

### 4.1. Como as APIs são acessadas nos testes?

**API Antiga** → Como foi fornecida diretamente por uma [URL](https://api.thedogapi.com/v1/breeds), os testes acessam essa API diretamente via requisições HTTP.

**API Nova** → Como veio como um arquivo .txt, foi necessário simular um servidor local para que os testes pudessem consumi-la como uma API real.

### 4.2. Inicialização e Finalização do Mock Server

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

## **4.3 Inicialização Manual do Mock Server**

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


## 5. Execução dos testes

O comando para executar os testes salvando os resultados na pasta logs (considerando que estamos dentro da pasta raiz do projeto) é:

```bash
robot -d logs tests/test_api_comparation.robot
```

Se já estiver dentro da pasta tests, utilize:

```bash
robot -d ../logs test_api_comparation.robot
```

## 6. Notas Finais

### Comparação das APIs:

- **new_request_mock.txt** representa a nova API, mas como um arquivo de texto.
→ Solução: Criação de um Mock Server que responde como uma API real.

- **old_api** é a API antiga, fornecida como uma URL acessível online (https://api.thedogapi.com/v1/breeds).
→ Solução: As requisições foram feitas diretamente para essa URL, sem necessidade de simulação.

### Melhores práticas:

- Certifique-se de manter a estrutura do projeto para facilitar a manutenção e escalabilidade dos testes.

- Revise as configurações do firewall se houver problemas na execução do servidor mock.