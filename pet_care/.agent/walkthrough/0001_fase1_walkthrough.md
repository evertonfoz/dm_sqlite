# Walkthrough: Fase 1 - Camadas de Domínio e Dados (0001)

Esta fase consistiu na criação das abstrações de domínio e da implementação concreta de dados para conectar o aplicativo ao Supabase Auth.

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

---

## Como Validar / Testar esta Etapa

Como esta etapa envolve apenas as classes de repositório e infraestrutura (sem tela ou controlador integrados ainda), a validação nesta fase pode ser feita através de **testes unitários** ou escrevendo um script temporário na inicialização do app para testar a comunicação com o Supabase Auth.

### Opção 1: Escrever um teste unitário simples em `test/` (Recomendado)
Você pode criar um arquivo de testes na pasta `test/features/auth/data/repositories/supabase_auth_repository_test.dart` (ou similar) mockando o `SupabaseClient` ou testando a integração direta com um banco de testes (se configurado).

### Opção 2: Teste rápido de integração no `main.dart`
Se você quiser realizar um teste de "fumaça" (smoke test) rápido na inicialização do aplicativo:
1. Abra o arquivo `lib/main.dart`.
2. No método `main()`, logo após a inicialização do Supabase e do `runApp`, instancie o repositório e chame algum método:
   ```dart
   final authRepo = SupabaseAuthRepository();
   print("Usuário atual: ${authRepo.getCurrentUser()}");
   ```
3. Execute o aplicativo e verifique no console de depuração se a chamada é executada sem falhas de compilação ou exceções não tratadas de inicialização do cliente.
