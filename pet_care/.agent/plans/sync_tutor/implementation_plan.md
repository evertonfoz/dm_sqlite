# Plano de Implementação: Sincronização de Tutores (SyncTutorRepository)

Este plano descreve as etapas para a implementação da sincronização dos dados dos tutores da base remota (Supabase) para a base local (SQLite).

## Fase 1: Implementação da Camada de Dados e Domínio ✅ (Concluída)
Nesta fase, criamos a abstração e a implementação do repositório de sincronização, que atuará como ponte entre o datasource remoto e o datasource local.

1. **Criar a interface `ISyncTutorRepository`**
   - **Caminho**: `lib/features/tutor/domain/repositories/sync_tutor_repository.dart`
   - **Objetivo**: Definir o contrato com o método `syncTutors()`.

2. **Criar a implementação `SyncTutorRepositoryImpl`**
   - **Caminho**: `lib/features/tutor/data/repositories/sync_tutor_repository_impl.dart`
   - **Objetivo**: Implementar a lógica de sincronização. Vai receber uma instância do `ITutorDataSource` remoto (Supabase) e do `ITutorDataSource` local (SQLite). 
   - A lógica irá:
     - Buscar todos os tutores da base remota.
     - Para cada tutor remoto, buscar localmente pelo `id` (usando o método `getById` do SQLite).
     - Se o tutor não existir localmente, inserir usando `insert`.
     - Se existir, atualizar usando `update` (ou, caso prefira otimizar, ignorar ou atualizar).

## Fase 2: Integração com a Aplicação (Controladores e UI) ✅ (Concluída)
Nesta fase, atualizaremos a aplicação para que a sincronização ocorra em momentos oportunos.

1. **Atualizar `TutorController`**
   - **Caminho**: `lib/features/tutor/presentation/controllers/tutor_controller.dart`
   - **Objetivo**: Adicionar o método `syncData()` que chama a sincronização. Injetar a dependência do novo repositório ou inicializá-la no lugar correto.

2. **Atualizar a Injeção de Dependências em `TutorListPage`**
   - **Caminho**: `lib/features/tutor/presentation/pages/tutor_list_page.dart`
   - **Objetivo**: Fornecer a instância do repositório de sincronização.
   - Como e quando chamar: Pode ser através de um botão explícito de "Sincronizar" na AppBar ou acionado de forma automática no `loadFirstPage()`. (Aguardo feedback/decisão se será automático na inicialização ou através de ação do usuário, mas inicialmente colocaremos na action bar ou durante o refresh natural).

---

## Próximos Passos
Todas as fases deste plano foram concluídas com sucesso. O recurso de sincronização de tutores já está funcional na interface da aplicação.

Se houver necessidade de replicar a lógica de sincronização para outros módulos (como Pets), recomendo a criação de um novo plano focado nessa entidade.
