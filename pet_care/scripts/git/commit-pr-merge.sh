#!/bin/bash
#
# commit-pr-merge.sh
# Script para automatizar o fluxo de commit, push, PR, merge e voltar ao main.
#
# Uso:
#   ./scripts/git/commit-pr-merge.sh "Mensagem do commit"
#   ./scripts/git/commit-pr-merge.sh -m "Mensagem do commit"
#   ./scripts/git/commit-pr-merge.sh # (solicita mensagem interativamente)
#
# Requisitos:
#   - GitHub CLI (gh) instalado e autenticado
#   - Git configurado com remote origin
#

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[!]${NC} $1"; }
log_error() { echo -e "${RED}[✗]${NC} $1"; exit 1; }

AUTO_GIT_DEFAULTS="${AUTO_GIT_DEFAULTS:-true}"
INTERACTIVE_GIT_PROMPTS="${INTERACTIVE_GIT_PROMPTS:-false}"

to_slug() {
    echo "$1" \
      | tr '[:upper:]' '[:lower:]' \
      | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g'
}

generate_branch_name() {
    local first_file changed_hint timestamp
    first_file=$(git status --porcelain | head -n1 | awk '{print $2}')
    changed_hint=$(basename "${first_file:-changes}")
    changed_hint=$(to_slug "$changed_hint")
    [ -n "$changed_hint" ] || changed_hint="changes"
    timestamp=$(date +%Y%m%d-%H%M%S)
    echo "codex/auto-${timestamp}-${changed_hint}"
}

generate_commit_message() {
    local files changed_count has_materials_sql has_backend
    files=$(git status --porcelain | awk '{print $2}')
    changed_count=$(echo "$files" | sed '/^$/d' | wc -l | tr -d ' ')
    has_materials_sql=$(echo "$files" | grep -E '^supabase/sql/materials/' || true)
    has_backend=$(echo "$files" | grep -E '^backend/' || true)

    if [ -n "$has_materials_sql" ]; then
      echo "fix(materials): ajustar sincronizacao e contagem de progresso"
      return
    fi
    if [ -n "$has_backend" ]; then
      echo "fix(backend): atualizar implementacao e ajustes de deploy"
      return
    fi
    if [ "$changed_count" -le 1 ]; then
      echo "chore: atualizar arquivo do projeto"
      return
    fi
    echo "chore: atualizar ${changed_count} arquivos do projeto"
}

# Verificar se está em um repositório git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    log_error "Não está em um repositório Git"
fi

# Verificar se gh está instalado
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) não está instalado. Instale com: brew install gh"
fi

# Verificar se gh está autenticado
if ! gh auth status > /dev/null 2>&1; then
    log_error "GitHub CLI não está autenticado. Execute: gh auth login"
fi

# Obter branch atual
CURRENT_BRANCH=$(git branch --show-current)

# Se estiver no main, criar branch de feature
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    log_warn "Você está no branch '$CURRENT_BRANCH'."
    
    # Verificar se há mudanças pendentes ou commits locais não enviados
    UNPUSHED_COMMITS=$(git log origin/$CURRENT_BRANCH..$CURRENT_BRANCH --oneline 2>/dev/null || echo "")
    if [ -z "$(git status --porcelain)" ] && [ -z "$UNPUSHED_COMMITS" ]; then
        log_error "Nenhuma mudança pendente ou commit local não enviado. Nada a fazer."
    fi
    
    NEW_BRANCH=""
    if [ "$AUTO_GIT_DEFAULTS" = "true" ]; then
        NEW_BRANCH=$(generate_branch_name)
        log_info "Nome do branch gerado automaticamente: '$NEW_BRANCH'"
    else
        echo -e "${YELLOW}Digite o nome do branch de feature (ex: feat/helmet-security):${NC}"
        read -r NEW_BRANCH
        if [ -z "$NEW_BRANCH" ]; then
            log_error "Nome do branch não pode ser vazio"
        fi
    fi
    
    # Validar nome do branch (não pode ter espaços ou caracteres especiais inválidos)
    if [[ "$NEW_BRANCH" =~ [[:space:]] ]]; then
        log_error "Nome do branch não pode conter espaços. Use hífens (-) ou underscores (_). Exemplo: feat/login-email-senha"
    fi
    
    if [[ ! "$NEW_BRANCH" =~ ^[a-zA-Z0-9/_.-]+$ ]]; then
        log_error "Nome do branch contém caracteres inválidos. Use apenas letras, números, hífens, underscores, pontos e barras."
    fi
    
    log_info "Criando branch '$NEW_BRANCH'..."
    git checkout -b "$NEW_BRANCH"
    
    # Se havia commits no branch anterior não enviados, eles agora estão no novo branch.
    # Precisamos recuar o branch antigo (ex: main) para evitar histórico divergente futuro.
    if [ -n "$UNPUSHED_COMMITS" ]; then
        git branch -f "$CURRENT_BRANCH" origin/"$CURRENT_BRANCH"
        log_info "Branch local '$CURRENT_BRANCH' recuado para origin/$CURRENT_BRANCH para evitar conflitos no pull futuro."
    fi
    
    log_success "Branch '$NEW_BRANCH' criado (com mudanças ou commits pendentes)"
    
    CURRENT_BRANCH="$NEW_BRANCH"
fi

# Verificar se há mudanças para commitar
if [ -z "$(git status --porcelain)" ]; then
    log_warn "Nenhuma mudança para commitar."
    HAS_CHANGES=false
else
    HAS_CHANGES=true
fi

# Obter mensagem de commit
COMMIT_MSG=""
while getopts "m:" opt; do
    case $opt in
        m) COMMIT_MSG="$OPTARG" ;;
        *) ;;
    esac
done
shift $((OPTIND-1))

# Se não passou -m, usa o primeiro argumento
if [ -z "$COMMIT_MSG" ] && [ -n "$1" ]; then
    COMMIT_MSG="$1"
fi

# Se ainda não tem mensagem, solicita
if [ -z "$COMMIT_MSG" ]; then
    if [ "$AUTO_GIT_DEFAULTS" = "true" ]; then
        COMMIT_MSG=$(generate_commit_message)
        log_info "Mensagem de commit gerada automaticamente: '$COMMIT_MSG'"
    else
        if [ "$HAS_CHANGES" = true ]; then
            echo -e "${YELLOW}Digite a mensagem do commit:${NC}"
        else
            echo -e "${YELLOW}Digite o título para o Pull Request:${NC}"
        fi
        read -r COMMIT_MSG
        if [ -z "$COMMIT_MSG" ]; then
            log_error "Mensagem/Título não pode ser vazio"
        fi
    fi
fi

# Resumo antes de executar
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Resumo do Fluxo Git${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "  Branch: ${GREEN}$CURRENT_BRANCH${NC}"
if [ "$HAS_CHANGES" = true ]; then
    echo -e "  Commit: ${GREEN}$COMMIT_MSG${NC}"
else
    echo -e "  Commit: ${YELLOW}(sem mudanças locais)${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Isso irá: add ➔ commit ➔ push ➔ criar PR ➔ merge PR ➔ voltar ao main ➔ pull${NC}"
if [ "$INTERACTIVE_GIT_PROMPTS" = "true" ]; then
    echo -e "${YELLOW}Pressione ENTER para continuar ou CTRL+C para cancelar...${NC}"
    read -r
fi

# 1. Add e Commit (se houver mudanças)
if [ "$HAS_CHANGES" = true ]; then
    log_info "Adicionando arquivos..."
    git add -A
    log_success "Arquivos adicionados"

    log_info "Criando commit..."
    git commit -m "$COMMIT_MSG"
    log_success "Commit criado"
else
    log_info "Usando commits existentes no branch"
fi

# 2. Push
log_info "Enviando para o remote..."
git push -u origin "$CURRENT_BRANCH"
log_success "Push realizado"

# 3. Criar PR
log_info "Criando Pull Request..."
PR_URL=$(gh pr create --title "$COMMIT_MSG" --body "Criado automaticamente via script" --base main 2>&1) || {
    # PR já pode existir
    if echo "$PR_URL" | grep -q "already exists"; then
        log_warn "PR já existe para este branch"
        PR_URL=$(gh pr view --json url -q '.url')
    else
        log_error "Erro ao criar PR: $PR_URL"
    fi
}
log_success "PR criado/encontrado: $PR_URL"

# 4. Merge PR (usando squash pois merge commits não são permitidos)
log_info "Mergeando Pull Request..."
gh pr merge --squash --delete-branch
log_success "PR mergeado (squash) e branch remoto deletado"

# 5. Voltar ao main
log_info "Voltando para o branch main..."
git checkout main
log_success "No branch main"

# 6. Pull
log_info "Atualizando main com as mudanças..."
git pull origin main
log_success "Main atualizado"

# 7. Limpar branch local (se ainda existir)
if git branch --list "$CURRENT_BRANCH" | grep -q "$CURRENT_BRANCH"; then
    log_info "Removendo branch local '$CURRENT_BRANCH'..."
    git branch -D "$CURRENT_BRANCH"
    log_success "Branch local removido"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✓ Fluxo completo realizado com sucesso!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
