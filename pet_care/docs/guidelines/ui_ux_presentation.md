# Diretrizes Visuais e de Interface do Usuário (UI/UX)

Este documento estabelece o guia de estilo visual, componentes de interface e regras de experiência do usuário para o aplicativo **Pet Care**. Seguir estas regras assegura consistência visual e um acabamento premium em qualquer tela adicionada ao sistema.

---

## 🎨 Paleta de Cores e Tipografia (Design Tokens)

O aplicativo utiliza uma paleta de cores moderna, limpa e de alta legibilidade, com contraste calibrado:

| Token de Cor | Valor Hexadecimal | Uso Recomendado |
| :--- | :--- | :--- |
| **Primary (Teal)** | `#0F766E` | Barras de ferramentas (AppBars), ícones ativos, títulos principais e ações de sucesso. |
| **Secondary (Orange)** | `#F97316` | Botões de ação flutuantes (FABs) de inserção e destaques. |
| **Neutral Background** | `#F8FAFC` | Cor de fundo padrão de páginas (`Scaffold.backgroundColor`). |
| **Text Primary** | `#1E293B` | Títulos de seções, textos de cards e botões principais. |
| **Text Secondary** | `#64748B` | Textos de ajuda, legendas e descrições de suporte. |
| **Border / Divider** | `#E2E8F0` | Divisórias e bordas secundárias sutis de componentes. |

### ✒️ Tipografia
* O aplicativo adota a família de fontes **Inter** com fallbacks dinâmicos do sistema operacional para garantir visualização limpa de texto em qualquer tela.

---

## 🧭 Estrutura de Navegação Geral

### 1. Barra Superior (`AppBar`)
* **Visual Premium:** Fundo totalmente branco, títulos em destaque com cor primária (`#0F766E`), subtítulos de ajuda curtos em cinza, elevação definida em zero (`elevation: 0`).
* **Subdivisão:** Sempre adicione um divisor sutil (`bottom: PreferredSize`) de `1px` de altura com a cor `#E2E8F0` para delimitar de forma limpa o topo.

### 2. Painel Lateral de Navegação (`AppDrawer`)
* O widget global [app_drawer.dart](file:///Users/evertoncoimbradearaujo/Documents/GitHub/dm_sqlite/pet_care/lib/core/presentation/widgets/app_drawer.dart) é responsável pelo menu lateral do aplicativo.
* **Indicador de Atividade:** O item selecionado no menu deve receber a decoração com cor primária translúcida (`const Color(0xFF0F766E).withOpacity(0.08)`), com bordas arredondadas de `12px` e fonte em negrito.

---

## 🔄 Gestos, Animações e Feedback

### 1. Arrastar para Excluir (`Swipe-to-Dismiss`)
* Em listagens principais, a exclusão rápida deve ser implementada envolvendo o item com o widget `Dismissible`.
* **Visual do Fundo de Ação:** Exiba um degradê vermelho (`Colors.red.shade400` a `Colors.red.shade600`) alinhado à direita com o ícone de lixeira e o texto em negrito "Remover".

### 2. Diálogo de Confirmação Interativo
* **Regra Absoluta:** Nenhuma ação destrutiva de exclusão deve ser disparada imediatamente. Um diálogo arredondado (`BorderRadius.circular(24)`) deve ser apresentado ao usuário com as seguintes seções estruturadas:
  - Um círculo destacado com fundo vermelho suave contendo o ícone `Icons.delete_forever_rounded` em vermelho vivo no centro do topo.
  - Título chamativo: "Confirmar Exclusão".
  - Texto detalhado perguntando ao usuário se tem certeza da ação e destacando o nome do registro em negrito.
  - Dois botões lado a lado arredondados (`BorderRadius.circular(14)`): "Cancelar" (estilo Outline com texto secundário) e "Excluir" (estilo preenchido com fundo vermelho destacado).

### 3. Notificações Flutuantes (`Snackbars`)
* Devem ser disparadas para indicar sucesso ou erro nas operações CRUD.
* **Convenção de Formato:** Use estilo flutuante (`behavior: SnackBarBehavior.floating`), cantos arredondados (`borderRadius: BorderRadius.circular(12)`) e duração máxima de 3 segundos.
* **Esquema de Cores:** Fundo Teal (`#0F766E`) para sucesso e vermelho acentuado (`Colors.redAccent`) para erros de processamento.

---

## 📝 Formulários e Entrada de Dados

Para garantir consistência visual no preenchimento de cadastros, utilize os seguintes padrões:

```dart
// Exemplo de Input Decorator padrão para TextFields do Pet Care
InputDecoration(
  labelText: 'Nome do Pet',
  labelStyle: const TextStyle(color: Color(0xFF64748B)),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey.shade300),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFF0F766E), width: 2),
  ),
)
```

### 📋 Regras de Validação e Relacionamentos
* **Validação Obrigatória:** Todos os campos críticos devem ser verificados e conter validadores de não-nulidade ou de formato estruturado (ex: validação de e-mails, tamanho máximo do telefone).
* **Campos Relacionais (Dropdowns):** Campos que dependem de chaves estrangeiras (ex: vincular Pet a um Tutor) devem carregar dinamicamente os registros da tabela correspondente.
  - Sempre exiba um aviso em destaque ou redirecione o usuário caso a tabela de chaves estrangeiras esteja vazia, evitando a criação de registros órfãos ou com chaves zeradas.
