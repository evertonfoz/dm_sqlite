# Plano de Implementação: Sincronização de Pets (SyncPetRepository)

Este plano descreve as etapas para a implementação da sincronização dos dados dos pets da base remota (Supabase) para a base local (SQLite), replicando o mesmo padrão utilizado no módulo de Tutores.

## Fase 1: Implementação da Camada de Dados e Domínio

Nesta fase, criaremos a abstração e a implementação do repositório de sincronização, atuando como ponte entre os datasources remoto e local.

### 1. Criar a interface `ISyncPetRepository`
- **Caminho**: `lib/features/pet/domain/repositories/sync_pet_repository.dart`
- **Objetivo**: Definir o contrato com o método principal `syncPets()`.

### 2. Criar a implementação `SyncPetRepositoryImpl`
- **Caminho**: `lib/features/pet/data/repositories/sync_pet_repository_impl.dart`
- **Objetivo**: Implementar a lógica de sincronização. A classe receberá por injeção as instâncias do `IPetDataSource` remoto (Supabase) e do `IPetDataSource` local (SQLite). 
- **Lógica proposta**:
  - Buscar todos os pets da base de dados remota.
  - Para cada pet remoto, buscar localmente pelo `id` (usando o método correspondente do SQLite).
  - Se o pet não existir localmente, inserir o registro (`insert`).
  - Se já existir, atualizar o registro (`update`).

## Fase 2: Integração com a Aplicação (Controladores e UI)

Nesta fase, atualizaremos as camadas superiores (Controlador e UI) para orquestrar e exibir a funcionalidade de sincronização para o usuário.

### 1. Atualizar o `PetController`
- **Caminho**: `lib/features/pet/presentation/controllers/pet_controller.dart`
- **Objetivo**: Adicionar a dependência do novo repositório `ISyncPetRepository` e implementar o método `syncData()`, que chamará a sincronização em background e lidará com os estados de carregamento, sucesso ou erro.

### 2. Atualizar a UI em `PetListPage`
- **Caminho**: `lib/features/pet/presentation/pages/pet_list_page.dart`
- **Objetivo**: 
  - Atualizar a instanciação do `PetController` para injetar o `SyncPetRepositoryImpl`, que por sua vez receberá os datasources apropriados (`SupabasePetDataSource` e `SqlitePetDataSource`).
  - Adicionar um mecanismo na interface (ex: um botão de "refresh" na AppBar) para permitir que o usuário inicie a sincronização de forma manual.

---

> [!NOTE]
> A lógica seguirá o mesmo fluxo estabelecido no `SyncTutorRepository`, garantindo consistência arquitetural na aplicação. Se o plano estiver de acordo, podemos iniciar a execução da Fase 1 imediatamente!
