# Plano de Implementação: Fluxo de Entrada e Autenticação do Usuário (0001)

Este plano descreve as etapas para implementação do fluxo de autenticação (onboarding, login, cadastro, recuperação de senha e controle de sessão) utilizando o Supabase Auth no aplicativo **Pet Care**.

---

## Tabela de Progresso

| Fase | Descrição | Status |
| --- | --- | --- |
| 1 | Camadas de Domínio e Dados (AuthRepository & SupabaseAuthRepository) | ✅ Concluída |
| 2 | Camada de Apresentação - Controlador (AuthController) | ✅ Concluída |
| 3 | Camada de Apresentação - Telas Públicas (Onboarding, Login, Registro, Recuperação de Senha) | ✅ Concluída |
| 4 | Controle de Sessão e Fluxo de Roteamento (AuthGate) | ✅ Concluída |
| 5 | Testes de Integração e Validação de Fluxo Completo | ✅ Concluída |

---

## Detalhamento das Fases

### Fase 1: Camadas de Domínio e Dados ✅ (Concluída)

Esta fase define a abstração para autenticação e sua respectiva implementação concreta conectada ao Supabase Auth.

1. **Criar a interface `AuthRepository`**
   - **Caminho**: `[NEW]` [auth_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/domain/repositories/auth_repository.dart)
   - **Objetivo**: Definir o contrato do repositório de autenticação.
   - **Métodos**:
     - `Future<void> signUp({required String email, required String password});`
     - `Future<void> signIn({required String email, required String password});`
     - `Future<void> signOut();`
     - `Future<void> resetPassword({required String email});`
     - `Future<dynamic> getCurrentUser();` // Retorna dados básicos do usuário logado no Supabase.
     - `Future<bool> checkSession();` // Verifica se há uma sessão ativa localmente.

2. **Criar a implementação `SupabaseAuthRepository`**
   - **Caminho**: `[NEW]` [supabase_auth_repository.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/data/repositories/supabase_auth_repository.dart)
   - **Objetivo**: Implementar o contrato usando a biblioteca oficial `supabase_flutter`.
   - **Dependências**: Utilizar `Supabase.instance.client.auth`.

---

### Fase 2: Camada de Apresentação - Controlador ✅ (Concluída)

Esta fase gerencia os estados do fluxo de autenticação e expõe comandos para a interface de usuário.

1. **Criar o `AuthController`**
   - **Caminho**: `[NEW]` [auth_controller.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/presentation/controllers/auth_controller.dart)
   - **Objetivo**: Controlar o estado e erros das transições de autenticação.
   - **Estados gerenciados**:
     - `bool isLoading` (para exibir spinners na tela).
     - `String? errorMessage` (para exibir feedbacks de erro).
     - `dynamic currentUser` (dados do usuário logado atualmente).
   - **Métodos expostos**:
     - `Future<void> signUp(String email, String password)`
     - `Future<void> signIn(String email, String password)`
     - `Future<void> signOut()`
     - `Future<void> resetPassword(String email)`
     - `Future<void> checkSession()`

---

### Fase 3: Camada de Apresentação - Telas Públicas ✅ (Concluída)

Esta fase foca nas interfaces com as quais o usuário não-autenticado irá interagir.

1. **Criar a `OnboardingPage`**
   - **Caminho**: `[NEW]` [onboarding_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/presentation/pages/onboarding_page.dart)
   - **Objetivo**: Apresentar o Pet Care e direcionar para registro ou login.
   - **Elementos de UI**:
     - Título: *Pet Care*
     - Mensagem: *"Organize os dados dos tutores e pets em um só lugar, com acesso seguro e integrado à nuvem."*
     - Botão: *Criar conta* (Navega para `RegisterPage`)
     - Botão: *Entrar* (Navega para `LoginPage`)

2. **Criar a `RegisterPage`**
   - **Caminho**: `[NEW]` [register_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/presentation/pages/register_page.dart)
   - **Objetivo**: Cadastro de novos usuários.
   - **Campos**: E-mail, Senha e Confirmação de Senha.
   - **Ação**: Acionar o método `signUp` no `AuthController`.

3. **Criar a `LoginPage`**
   - **Caminho**: `[NEW]` [login_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/presentation/pages/login_page.dart)
   - **Objetivo**: Autenticação de usuários cadastrados.
   - **Campos**: E-mail e Senha.
   - **Elementos adicionais**: Link/Botão para "Esqueci minha senha" (Navega para `ForgotPasswordPage`).
   - **Ação**: Acionar o método `signIn` no `AuthController`.

4. **Criar a `ForgotPasswordPage`**
   - **Caminho**: `[NEW]` [forgot_password_page.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/presentation/pages/forgot_password_page.dart)
   - **Objetivo**: Solicitar link/código de recuperação de senha por e-mail.
   - **Campos**: E-mail.
   - **Ação**: Acionar o método `resetPassword` no `AuthController`.

---

### Fase 4: Controle de Sessão e Roteamento

Esta fase gerencia o ponto de entrada principal do aplicativo.

1. **Criar o `AuthGate`**
   - **Caminho**: `[NEW]` [auth_gate.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/features/auth/presentation/pages/auth_gate.dart)
   - **Objetivo**: Escutar o estado da sessão activa. Decidir se exibe a área autenticada (`TutorListPage`) ou a área pública (`OnboardingPage`).
   - **Comportamento**: Ao abrir o aplicativo, verificar a sessão no Supabase. Enquanto verifica, exibir uma tela/indicador de carregamento (`isLoading`).

---

### Fase 5: Ajustes Finais e Validação

1. **Atualizar ponto de entrada principal do App**
   - **Caminho**: `[MODIFY]` [main.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/main.dart)
   - **Objetivo**: Definir o `AuthGate` como a `home` da aplicação, assegurando que todas as sessões passem pelo fluxo de validação correto.

---

## Plano de Verificação

### Verificação Manual
1. **Fluxo de Onboarding**:
   - Abrir o app sem nenhuma sessão ativa. Certificar de que a `OnboardingPage` é exibida.
   - Clicar em "Criar conta" para navegar para a `RegisterPage`.
   - Clicar em "Entrar" para navegar para a `LoginPage`.
2. **Cadastro (SignUp)**:
   - Digitar e-mail e senha incompatíveis na confirmação e validar a validação local.
   - Criar uma conta com sucesso e validar se o usuário é direcionado para a tela correta (LoginPage ou diretamente logado).
3. **Autenticação (SignIn)**:
   - Digitar credenciais inválidas e validar a mensagem de erro.
   - Digitar credenciais válidas e garantir o redirecionamento imediato para a `TutorListPage` (área autenticada).
4. **Persistência de Sessão**:
   - Fechar o aplicativo com usuário logado, abrir novamente e garantir que a tela de onboarding não seja exibida, indo direto para a `TutorListPage`.
5. **Logout**:
   - Clicar no botão de sair (se implementado) e certificar o redirecionamento imediato para a tela de Login/Onboarding.
6. **Recuperação de Senha**:
   - Solicitar recuperação de senha na `ForgotPasswordPage` e certificar-se de que o e-mail é enviado via console ou console do Supabase.
