# Diretrizes de Arquitetura (Feature-First)

Este documento estabelece as diretrizes arquiteturais obrigatórias para o projeto **Pet Care**. Qualquer agente de IA ou desenvolvedor que atuar neste repositório **DEVE** seguir rigorosamente estas regras.

---

## 📌 Regra Fundamental: Arquitetura Baseada em Features

Todo o código deste projeto deve ser organizado por **features** (funcionalidades/recursos), e não por tipos de arquivos técnicos globais (como pastas de telas, modelos ou controladores globais).

> [!IMPORTANT]
> **NÃO** crie pastas como `lib/models`, `lib/views` ou `lib/controllers` na raiz do diretório `lib`. Toda nova funcionalidade deve ser encapsulada dentro de sua respectiva pasta em `lib/features/`.

---

## 📂 Estrutura de Pastas Esperada

Para cada feature criada no aplicativo (por exemplo, `pet` ou `tutor`), a seguinte estrutura de subpastas deve ser respeitada dentro de `lib/features/<nome_da_feature>/`:

```text
lib/
└── features/
    └── <nome_da_feature>/
        ├── domain/
        │   ├── models/        # Modelos de negócio/Entidades (ex: pet.dart)
        │   └── repositories/  # Contratos/Interfaces de repositórios
        ├── data/
        │   ├── datasources/   # Fontes de dados locais/remotos (ex: SQLite, APIs)
        │   └── repositories/  # Implementação concreta dos repositórios (ex: SQLite)
        └── presentation/
            ├── controllers/   # Controladores (intermediários de regras e UI)
            ├── pages/         # Telas principais da feature
            └── widgets/       # Componentes visuais exclusivos desta feature
```

---

## 🛠️ Recursos Compartilhados (Core)

Componentes, utilitários, temas ou instâncias de banco de dados compartilhados entre múltiplas features:
* Devem ser alocados dentro de uma pasta chamada `lib/core/`.
* **Exemplos presentes:**
  - Conexão SQLite Singleton: [database_helper.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/core/database/database_helper.dart)
  - Widget global de navegação lateral: [app_drawer.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/core/presentation/widgets/app_drawer.dart)

---

## 🗄️ Persistência de Dados (SQLite)

O aplicativo utiliza o **SQLite** para persistência local de dados por meio do pacote `sqflite`.

### 1. Instância Única (Singleton Helper)
A conexão central com o banco de dados é gerida em `lib/core/database/database_helper.dart`. Ela implementa o padrão Singleton para evitar concorrências ou vazamento de recursos.

### 2. Integridade e Chaves Estrangeiras
* O suporte a chaves estrangeiras é habilitado obrigatoriamente no callback `onConfigure` utilizando `PRAGMA foreign_keys = ON`.
* Relacionamentos entre tabelas (como `pets` pertencendo a `tutors`) devem ser mapeados via FKs em nível de DDL (Tabela `pets` aponta para `tutors(tutorId)`).

### 3. Evolução de Esquema e Migrações
* Qualquer modificação nas tabelas deve ser tratada incrementalmente dentro do método `onUpgrade` com base nas variáveis de versão (`oldVersion`, `newVersion`).
* **NÃO** altere instruções do `onCreate` para tabelas já implantadas em produção; utilize migrações incrementais (`ALTER TABLE`, `CREATE TABLE IF NOT EXISTS`) para preservar dados de usuários.

### 4. Mapeamento de Tipos de Dados
* **Campos Temporal/DateTime:** SQLite não possui tipo nativo de data. Deve-se persistir as datas convertidas em strings formatadas no padrão ISO 8601 (`toIso8601String()`) e recuperá-las via `DateTime.parse()`.
* **Modelos `toMap` / `fromMap`:** Toda entidade deve fornecer esses métodos para serialização e desserialização limpa no banco de dados.

### 5. Exclusão Lógica (Soft Delete)
* Registros de domínio possuem suporte a exclusão lógica via coluna `deletedAt` (tipo `TEXT` nulo).
* Deleções realizam um `UPDATE` definindo a data de exclusão atual em `deletedAt` no lugar de `DELETE` físico.
* Leituras efetuam filtragem padrão adicionando a cláusula `deletedAt IS NULL`.

---

## 🧠 Gerenciamento de Estado e Controladores

Para manter o acoplamento baixo e facilitar testes unitários ou mock de dados, o projeto segue regras rígidas na camada de Apresentação:

> [!TIP]
> **Padrão de Controladores Sem Estado (Stateless/Direct Controllers):**
> * Os controladores (ex: `PetController` e `TutorController`) funcionam como intermediários diretos sem estado reativo em memória. Eles não herdam de `ChangeNotifier` ou bibliotecas complexas.
> * Eles expõem métodos simples retornando `Future` com os resultados das operações do repositório correspondente.
> * O estado visual (loading, listas, erros) é gerido de forma simples e reativa localmente pelas telas (`StatefulWidget` com `setState`).
> * Isso simplifica a estrutura das telas e garante que os controladores sejam extremamente fáceis de instanciar e testar.

---

## 📝 Caso de Referência Atual: Features `pet` e `tutor`

O projeto possui duas features completamente implementadas seguindo esta estrutura, as quais devem servir de referência para qualquer nova tela ou fluxo de negócio:

### 1. Feature `pet`
* **Domínio:**
  - Modelo: [pet.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/domain/models/pet.dart)
  - Abstração: [pet_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/domain/repositories/pet_repository.dart)
* **Dados:**
  - Fonte de Dados: [pet_local_datasource.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/data/datasources/pet_local_datasource.dart) (inclui *INNER JOIN* com `tutors` para otimizar queries).
  - Concreto: [sqlite_pet_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/data/repositories/sqlite_pet_repository.dart)
* **Apresentação:**
  - Controlador: [pet_controller.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/presentation/controllers/pet_controller.dart)
  - Interface: [pet_list_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/presentation/pages/pet_list_page.dart) e [pet_form_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/pet/presentation/pages/pet_form_page.dart)

### 2. Feature `tutor`
* **Domínio:**
  - Modelo: [tutor.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/domain/models/tutor.dart)
  - Abstração: [tutor_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/domain/repositories/tutor_repository.dart)
* **Dados:**
  - Fonte de Dados: [tutor_local_datasource.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/data/datasources/tutor_local_datasource.dart)
  - Concreto: [sqlite_tutor_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/data/repositories/sqlite_tutor_repository.dart)
* **Apresentação:**
  - Controlador: [tutor_controller.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/presentation/controllers/tutor_controller.dart) (inclui regra de validação referencial `hasActivePets` para impedir deleção cascata indevida).
  - Interface: [tutor_list_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/presentation/pages/tutor_list_page.dart) e [tutor_form_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/tutor/presentation/pages/tutor_form_page.dart)

---

## 🚀 Orientações para Futuros Desenvolvedores e Agentes de IA

1. **Antes de criar qualquer arquivo:** Identifique a qual funcionalidade (feature) ele pertence. Se for transversal, coloque em `core`.
2. **Siga a estrutura do domínio:** Comece mapeando o modelo de negócio no `domain/models/` da feature, adicionando as funções `toMap` e `fromMap`.
3. **Não misture responsabilidades:** Mantenha a interface do usuário (`presentation/`) completamente desacoplada do acesso direto ao banco de dados ou arquivos de persistência crua. Sempre use `Repositories` e `Datasources`.
