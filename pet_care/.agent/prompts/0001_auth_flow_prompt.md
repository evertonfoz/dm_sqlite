# Prompt para Geração do Plano de Implementação: Fluxo de Entrada e Autenticação do Usuário (0001)

Você é um Engenheiro de Software Sênior especialista em Flutter, Clean Architecture e Supabase. Sua tarefa é ler as instruções abaixo e gerar um Plano de Implementação completo e estruturado para o fluxo de entrada do usuário no aplicativo **Pet Care**.

O plano de implementação gerado deve ser salvo em: `.agent/plans/0001_auth_flow/implementation_plan.md` (ou `.agent/plans/0001_implementation_plan.md`).

---

## 1. Contexto e Objetivo
Atualmente, o aplicativo Pet Care interage diretamente com o Supabase para a gestão de Tutores, porém os dados são públicos e compartilhados entre todos os acessos. O objetivo deste plano é introduzir o **Supabase Auth** para criar o fluxo de entrada e controle de sessão do usuário, garantindo que o app reconheça quem está conectado antes de permitir o acesso à área principal e possibilite a posterior amarração dos dados ao `user_id`.

## 2. Requisitos de Telas e Estrutura (Área Pública)
*   **OnboardingPage**: Apresentação inicial simples de tela única explicando o objetivo do app: *"Organize os dados dos tutores e pets em um só lugar, com acesso seguro e integrado à nuvem"*. Deve conter botões para "Criar Conta" (direcionando para a RegisterPage) e "Entrar" (direcionando para a LoginPage).
*   **LoginPage**: Permite o login com e-mail e senha. Deve conter um botão ou link de "Esqueci minha senha" que direciona para a ForgotPasswordPage.
*   **RegisterPage**: Permite criar conta coletando e-mail, senha e confirmação de senha.
*   **ForgotPasswordPage**: Permite inserir o e-mail cadastrado para solicitar o e-mail de recuperação de senha pelo Supabase.
*   **AuthGate**: Widget/Tela que escuta o estado da sessão. Se houver usuário logado, direciona para a área interna (inicialmente `TutorListPage` ou `HomePage`). Se não houver, direciona para o `OnboardingPage` ou `LoginPage`.

## 3. Arquitetura da Feature `auth`
Seguir o padrão de pastas do projeto, criando a feature `auth` na pasta `lib/features/auth/` estruturada em:
*   **Domain (Domínio)**:
    *   `lib/features/auth/domain/repositories/auth_repository.dart`: Contrato abstrato da autenticação com os métodos:
        *   `signUp(String email, String password)`
        *   `signIn(String email, String password)`
        *   `signOut()`
        *   `resetPassword(String email)`
        *   `getCurrentUser()`
        *   `checkSession()` (ou equivalente para monitorar sessão ativa).
*   **Data (Dados)**:
    *   `lib/features/auth/data/repositories/supabase_auth_repository.dart`: Implementação concreta do `AuthRepository` utilizando a biblioteca oficial do Supabase.
*   **Presentation (Apresentação)**:
    *   `lib/features/auth/presentation/controllers/auth_controller.dart`: Controlador para gerenciar o estado da autenticação (estados: `isLoading`, `errorMessage`, `currentUser`) e expor métodos para a UI interagir (`signUp`, `signIn`, `signOut`, `resetPassword`, `checkSession`).
    *   `lib/features/auth/presentation/pages/`:
        *   `onboarding_page.dart`
        *   `login_page.dart`
        *   `register_page.dart`
        *   `forgot_password_page.dart`
        *   `auth_gate.dart` (se necessário na UI/rotas).

## 4. Restrições e Decisões Iniciais (Escopo Reduzido)
*   **Somente e-mail e senha**: Não implementar login social ou magic link.
*   **Perfil de usuário simplificado**: Não criar perfil completo de usuário (como nome, foto, etc.) nesta fase.
*   **Sem RLS e amarração de tabelas agora**: A amarração de tutores a usuários logados (`user_id`), configuração de Row Level Security (RLS) e políticas de acesso no Supabase ficarão para etapas futuras, após o fluxo de login básico estar funcionando 100%.

## 5. Sequência Recomendada de Implementação (Fases do Plano)
O plano de implementação deve ser dividido nas seguintes fases de entrega atômica:
1.  **Fase 1: Configuração e Camadas de Domínio & Dados**:
    *   Definição da interface `AuthRepository`.
    *   Implementação do `SupabaseAuthRepository`.
2.  **Fase 2: Camada de Apresentação (Controller)**:
    *   Criação e testes de estado do `AuthController`.
3.  **Fase 3: Criação das Telas Públicas**:
    *   Implementação do `OnboardingPage`.
    *   Implementação do `RegisterPage` e `LoginPage`.
    *   Implementação do `ForgotPasswordPage`.
4.  **Fase 4: Controle de Sessão e AuthGate**:
    *   Criação do `AuthGate` para gerenciar a rota inicial com base na sessão ativa do Supabase.
5.  **Fase 5: Ajustes Finais e Testes de Integração**:
    *   Testes manuais de fluxo completo (Entrar no app -> Onboarding -> Registro -> Login -> Área Interna -> Logout -> Redirecionamento).

## 6. Estrutura do Arquivo de Destino
O plano de implementação a ser gerado deve seguir o formato padrão em markdown contendo:
*   **Objetivo geral**
*   **Tabela de progresso / Status das Fases**
*   **Fases de implementação detalhadas com o caminho exato dos arquivos (`[NEW]`, `[MODIFY]`) e responsabilidades**
*   **Plano de verificação manual**

Por favor, gere o plano com base nas diretrizes acima e salve-o no local especificado.
