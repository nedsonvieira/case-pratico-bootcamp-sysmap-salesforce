# 📘 Documentação do Desafio TechCare – Case Prático Bootcamp 2025

##### **Autor:** _Nedson Vieira do Nascimento_
##### **Perfil Escolhido:** _Dev/Admin_

## 1. Visão Geral

Este repositório contém a implementação do **Case Request**, um objeto customizado desenvolvido para a gestão estruturada e eficiente de pedidos de suporte no Salesforce. O projeto foi realizado como parte do **Desafio TechCare – Case Prático (Bootcamp 2025)**, dentro do **Programa de Trainee Sysmap de Excelência Salesforce – 6ª edição**, conduzido entre março e junho de 2025.

  

O objetivo do Case Request é aprimorar o processo de atendimento ao suporte, proporcionando segmentação inteligente por tipo de cliente e um fluxo otimizado para acompanhamento dos casos. A arquitetura foi estruturada seguindo boas práticas de desenvolvimento, garantindo segurança, automatização e manutenibilidade do código.

  

### ✨ Principais funcionalidades:

  

- 🧩 **Modelagem de Dados**: Definição do objeto customizado com atributos essenciais para gerenciamento de casos.

-  🔐 **Controle de Acesso:** Definição de perfis, Permission Sets, Permission Set Groups e regras de visibilidade para garantir segurança e segmentação correta dos dados.

- ✅ **Validações e Automação**: Regras de negócio implementadas via Validation Rules e Flows para garantir consistência dos dados.

- 🔀 **Atribuição Automática**: Implementação de lógica em Flow para roteamento de casos com base na prioridade e no nível de suporte.

- 📊 **Relatórios e Dashboards**: Visibilidade das métricas de atendimento, tempo de resposta e status dos casos registrados.

- ⚙️ **Apex & LWC**: Desenvolvimento de classes Apex e componentes Lightning Web para aprimorar a interação e funcionalidade do sistema.

  
---

  

## 🏗️ 2. Estrutura do Objeto

  

### 📋 Atributos

  

| Campo                   | Tipo      | Descrição                                            |
| :---------------------- | :-------- | :--------------------------------------------------- |
| **Subject__c**          | Texto     | Título do pedido. Obrigatório.                       |
| **Description__c**      | Long Text | Descrição detalhada do problema. Obrigatório.        |
| **Priority__c**         | Picklist  | Nível de prioridade: High, Medium, Low. Obrigatório. |
| **Status__c**           | Picklist  | Estado do caso: New, In Progress, Escalated, Closed. |
| **Support_Level__c**    | Picklist  | Nível de suporte: Basic, Advanced, VIP. Obrigatório. |
| **SLA_Deadline__c**     | DateTime  | Data/hora limite de SLA. Calculado via Flow.         |
| **Resolution_Notes__c** | Long Text | Notas de resolução. Obrigatório ao fechar o caso.    |
| **Contact**             | Lookup    | Contato relacionado ao caso.                         


### 🗂️ Abas Disponíveis

  

- **Case Request**

- **Dashboards**

- **Reports**

  

---

  

## 🧾 3. Tipos de Registro e Layouts

  

### 📑 Record Types

  

- **Premium**

- **Standard**

  

Cada tipo possui layout e campos obrigatórios personalizados.

  

---

  

## 🔐 4. Controle de Acesso

  

### 👥 Perfis

  

- **Support Premium**

- **Support Standard**

  

### 🛡️ Permission Sets

  

- **PS Support Premium**

- **PS Support Standard**

  

### 🧰 Permission Set Groups

  

- **PSG Support Premium**

- **PSG Support Standard**

  

**Notas:**

  

- Apenas **Support Premium** pode visualizar os campos **SLA Deadline** e **Support Level**.

- Apenas **Support Premium** pode reabrir casos com status **Closed**.

  

---

  

## ✅ 5. Validações

  

- Campos obrigatórios: **Subject, Description, Priority, Support Level**.

- O **Status** não pode ser alterado para **Closed** sem preenchimento do **Resolution Notes**.

- O campo **Resolution Notes** é **visível apenas** quando o status é alterado para **Closed**.

  

---

  

## 🔄 6. Automações

  

### ⏱️ Flow: `Set SLA Deadline`

  
- Record-Triggered Flow

- Executado na criação de um Case Request.

- Calcula automaticamente a data limite do SLA com base no tipo de registro (**Record Type**):

  - **24 horas** para casos **Standard**

  - **8 horas** para casos **Premium**

- Fórmula: `NOW() + X horas`

  

### 📥 Flow: `Assign Queue to Case Request`

  

- Autolaunched flow 

- Atribui uma fila à uma requisição de caso com base em _Priority_, _Support Level_ e _Record Type_.

  

#### 🔧 Lógica de Atribuição

  

```

Se record type = PREMIUM e (priority = HIGH ou support level = VIP)

    → Queue: Support Premium Lv 1

Senão

    → Queue: Support Premium Lv 2

  

Se record type = STANDARD e (priority = HIGH)

    → Queue: Support Standard Lv 1

Senão

    → Queue: Support Standard Lv 2

```

  

---

  

## 📈 7. Relatórios e Dashboards

  

### 📄 Relatórios

  

- **Relatório Tabular**: Casos abertos por **Prioridade** e **Status**.

![[Pasted image 20250531150624.png]]
  

### 📊 Dashboard

  

- **Gráfico 1**: Casos Abertos vs. Fechados nos últimos 7 dias.

![[Open Cases x Closed Cases.png]]

- **Gráfico 2**: Tempo médio de resolução por tipo (**Premium** × **Standard**).

![[Average Time to Close (1).png]]

- **Gráfico 3:** Tempo médio de resolução por owner.

![[Average Time to Close 1.png]]
  

---

  

## 🧠 8. Apex e LWC

  

### 🧩 APEX

  

- **Trigger:** `CaseRequestTrigger`

	Este **trigger** é acionado **após a atualização** de um `Case_Request__c`. Ele verifica se o status do caso foi alterado para `"Closed"` e cria um histórico (`Case_History__c`), registrando a data de fechamento e se o SLA foi atendido.

	**Arquivos**

	- **Trigger:** `CaseRequestTrigger.trigger`
	
		✔ Captura **atualizações** em `Case_Request__c`.  
		✔ Aciona o **handler** para verificar mudanças no status.  
		✔ Somente executa ações **após a atualização** (`AFTER UPDATE`).
		
	- **Handler:** `CaseRequestTriggerHandler.cls`

		✔ **Recebe** os registros atualizados do Trigger.  
		✔ **Chama** a ação `createCaseHistory()` para registrar o fechamento.
	
	- **Action:** `CaseRequestActions.cls`

		✔ **Cria um histórico** (`Case_History__c`) quando o **caso é atualizado para "Closed"**.  
		✔ **Registra** a data de fechamento (`Time_Closed__c`).  
		✔ **Verifica se o SLA foi atendido** (`SLA_Met__c`).  
		✔ **Insere o histórico** apenas se houver mudanças.

  

### 🌐 API REST  

- **Rest Resource:** `CaseRequestManager`  

	Esta API permite recuperar informações sobre uma requisição de caso (`Case_Request__c`) utilizando um método GET. A API recebe um **ID da requisição** como parâmetro na URL e retorna os detalhes da requisição em formato JSON.

	**Endpoints**

	**Obter Requisição de Caso**

	- **Path:** `/Case_Request__c/{caseRequestId}`
	- **Método:** `GET`
	- **Descrição:** Retorna detalhes sobre uma requisição de caso específica.

	**Parâmetros**

|Nome|Tipo|Obrigatório|Descrição|
|---|---|---|---|
|`caseRequestId`|`String`|Sim|O ID da requisição de caso a ser recuperada|

- **Exemplo de Requisição**

```Apex
GET /Case_Request__c/5008c00001A1B2C3D
```


- **Exemplo de Respostas**

**Resposta de Sucesso (`200 OK`)**

```json
{ 
	"createdDate": "2025-05-30T13:45:23Z", 
	"slaDeadline": "2025-06-05T00:00:00Z", 
	"status": "In Progress", 
	"slaMet": true, 
	"timeClosed": "2025-06-03T16:30:00Z" 
}
```


**Erro - Requisição Inválida (`400 Bad Request`)**

```json
{ 
	"status": 400, 
	"error": "Bad Request", 
	"message": "Case request id can't be null." 
}
```


**Erro - Caso não encontrado (`404 Not Found`)**

```json
{ 
	"status": 404, 
	"error": "Not Found", 
	"message": "Case Request ID not found or invalid." 
}
```

  

### 🧪 Testes Apex

  

- Foram implementadas classes de teste para todas as classes Apex garantindo no **mínimo de 90% de cobertura** de código.

- Foram validados **cenários positivos e negativos** para assegurar robustez das regras de negócio e automações.

  

### ⚡ LWC Components

  

1. **SLA Countdown Timer**

   Este **Lightning Web Component (LWC)** exibe um **contador regressivo** baseado no prazo (`SLA_Deadline__c`) de uma requisição de caso (`Case_Request__c`). Ele verifica o status do caso e interrompe o timer quando ele é **"Closed"**.

	**Arquivos do Componente**

	- **JS:** `slaDeadlineTimer.js`
	- **HTML:** `slaDeadlineTimer.html`

	**Funcionalidades**

	✔ Obtém os campos `SLA_Deadline__c` e `Status__c` de um registro `Case_Request__c`.
	✔ Exibe um **timer regressivo** até o prazo final (`SLA_Deadline__c`).
	✔ Aplica **estilos visuais** com `slds-theme_*` dependendo do tempo restante:

	- **Verde** (`slds-theme_success`) para mais de 2 horas restantes.
	- **Amarelo** (`slds-theme_warning`) para menos de 2 horas.
	- **Vermelho** (`slds-theme_error`) quando o tempo expira.

  

2. **Botão "Reopen Case"**

   Este **Lightning Web Component (LWC)** permite que os usuários **reabram uma requisição de caso (`Case_Request__c`)** caso ela tenha sido fechada. O componente verifica o status do caso antes de chamar uma **classe Apex** que altera o status para "In Progress" e inicia um **Flow** automaticamente.

	**Arquivos do Componente**

	- **JS:** `reopenCaseRequest.js`
	- **HTML:** `reopenCaseRequest.html`
	- **Apex:** `ReopenCaseRequest.cls`

	**Funcionalidades**

	✔ Obtém o status do caso (`Status__c`) via `@wire(getRecord)`.  
	✔ Permite reabrir o caso **somente se ele estiver fechado**.  
	✔ Chama um método **Apex (`reopenCase`)** para atualizar o status para `"In Progress"`.  
	✔ Dispara um **Flow automático** para configurar um novo SLA.  
	✔ Mostra mensagens de sucesso ou erro utilizando `ShowToastEvent`.


---


## 📌9. Instalação e Deploy


### Pré-requisitos: 

Antes de iniciar o deploy, verifique se você possui:
	
🔹 Acesso de administrador no Salesforce.
🔹 Salesforce CLI instalada ([Download aqui](https://developer.salesforce.com/tools/salesforcecli)).
🔹 VS Code com extensão Salesforce Extension Pack ([Link](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)).
🔹 Acesso ao GitHub.

**Configuração do Ambiente Local**

1. **Instalar o Salesforce CLI**

- Baixe e instale a CLI:

```bash
sfdx update
```


- Confirme a instalação com:

```bash
sfdx --version
```


2. **Criar o diretório do projeto**

```bash
mkdir <nomeDoProjetoSalesforce> && cd <nomeDoProjetoSalesforce>
```


3. **Clonar o repositório do projeto**

```bash
git clone https://github.com/nedsonvieira/case-pratico-bootcamp-sysmap-salesforce.git
```

4. **Autenticar na organização Salesforce**

- Abra a pastas do projeto no Visual Studio Code, pressione **Ctrl+Shift+P**.
- Insira `sfdx`.  
- Selecione **SFDX: Authorize an Org (Autorizar uma organização)**.  
- Insira um nome para organização e pressione **Enter**.  
- Faça login usando suas credenciais da organização.  
- Clique em **Allow (Permitir)**.


5. **Deploy dos metadados**

- Clique com o botão direito do mouse na pasta **force-app/main/default**.
- Selecione **SFDX: Deploy This Source to Org (Implantar essa fonte na organização)**.


---

## 🏁 10. Considerações Finais

  

Este projeto foi implementado com foco em  segurança e automação de processos de suporte. A arquitetura segue boas práticas de desenvolvimento Salesforce, incluindo:

  

- ✅ **Separação de lógica em handlers e actions.**

- 🔒 **Exposição segura via Apex REST.**

- 🔁 **Uso de Flow para regras de negócio e automação.**

- 🧩 **Componentes LWC reativos e orientados a experiência do usuário.**
