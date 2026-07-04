# Walkthrough: Fase 1 - Camadas de Domínio e Dados (0001)

Esta fase consistiu na criação das abstrações de domínio, da implementação concreta de dados para conectar o aplicativo ao Supabase Auth, limpeza de códigos de teste antigos no arquivo principal e criação de testes automatizados.

---

## Modificações Realizadas

### Camada de Domínio
*   `[NEW]` [auth_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/domain/repositories/auth_repository.dart): Definição da interface `IAuthRepository` com os métodos necessários para:
    *   Cadastro (`signUp`)
    *   Login (`signIn`)
    *   Logout (`signOut`)
    *   Recuperação de senha (`resetPassword`)
    *   Recuperação do usuário atual (`getCurrentUser`)
    *   Verificação de sessão ativa (`checkSession`)

### Camada de Dados
*   `[NEW]` [supabase_auth_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/data/repositories/supabase_auth_repository.dart): Implementação do repositório conectando diretamente com a instância `SupabaseClient`. Ele utiliza o `Supabase.instance.client` por padrão, mas permite injeção externa para facilitar testes unitários.

### Limpeza e Configurações
*   `[MODIFY]` [main.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/main.dart): Removidos os testes manuais e consultas temporárias à tabela `tutors` que estavam poluindo a inicialização do app.
*   `[MODIFY]` [pubspec.yaml](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/pubspec.yaml): Adicionada a dependência de testes `flutter_test`.

### Testes Automatizados
*   `[NEW]` [supabase_auth_repository_test.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/test/features/auth/data/repositories/supabase_auth_repository_test.dart): Testes unitários completos cobrindo todos os métodos do repositório de autenticação (`signUp`, `signIn`, `signOut`, `resetPassword`, `getCurrentUser`, `checkSession`), simulando a dependência do cliente do Supabase por meio de Fakes dinâmicos.

---

## Como Validar / Testar esta Etapa

Como os testes de unidade foram implementados para validar o funcionamento lógico das integrações, você pode rodar os testes automatizados diretamente.

### Execução dos Testes Unitários
No terminal, execute o comando abaixo a partir do diretório raiz do projeto (`pet_care`):

```bash
flutter test test/features/auth/data/repositories/supabase_auth_repository_test.dart
```

**Resultado esperado:**
O console deve indicar sucesso em todos os 7 testes executados:
*   `signUp deve chamar auth.signUp no cliente do Supabase`
*   `signIn deve chamar auth.signInWithPassword no cliente do Supabase`
*   `signOut deve chamar auth.signOut no cliente do Supabase`
*   `resetPassword deve chamar auth.resetPasswordForEmail no cliente do Supabase`
*   `getCurrentUser deve retornar o usuário atual do Supabase`
*   `checkSession deve retornar true se houver sessao ativa`
*   `checkSession deve retornar false se nao houver sessao ativa`
