# ============================================================
#  MARVEL APP - MAKEFILE (para projeto modular com SPM)
# ============================================================

# Lê versão do app, se existir
APP_VERSION := $(shell cat .app_version 2>/dev/null || echo "1.0.0")

# Caminho do projeto
PROJECT_NAME := MarvelApp
SCHEME := MarvelApp
CONFIGURATION := Debug

# ============================================================
#  ALVO PADRÃO
# ============================================================
default: help

help: ## Exibe ajuda dos comandos disponíveis
	@echo "📘 Usage:\n    make <target>\n"
	@awk -F ':.*?## ' '/^[a-zA-Z0-9_-]+:.*?##/ { \
		printf "   \033[33m%-30s\033[0m %s\n", $$1, $$2 \
	}' $(MAKEFILE_LIST) | sort

# ============================================================
#  DEPENDÊNCIAS SPM
# ============================================================
deps: ## Resolve dependências do Swift Package Manager
	@echo "📦 Resolving Swift Package Manager dependencies..."
	xcodebuild -resolvePackageDependencies \
		-project $(PROJECT_NAME).xcodeproj \
		-scheme $(SCHEME)
	@echo "✅ Dependências resolvidas com sucesso."

clean_deps: ## Remove cache de dependências SPM
	@echo "🧹 Limpando dependências..."
	rm -rf .build
	rm -rf ~/Library/Developer/Xcode/DerivedData/*
	@echo "✅ Dependências limpas."

# ============================================================
#  COMPILAÇÃO E LIMPEZA DO PROJETO
# ============================================================
build: ## Compila o projeto (Debug)
	@echo "⚙️  Compilando $(PROJECT_NAME)..."
	xcodebuild -scheme $(SCHEME) -configuration $(CONFIGURATION) build

clean: ## Limpa build artifacts
	@echo "🧽 Limpando projeto..."
	xcodebuild -scheme $(SCHEME) clean

# ============================================================
#  TESTES
# ============================================================
test: ## Executa testes unitários
	@echo "🧪 Executando testes..."
	xcodebuild test \
		-scheme $(SCHEME) \
		-destination 'platform=iOS Simulator,name=iPhone 15 Pro'

test_clean: ## Limpa resultados de testes
	rm -rf fastlane/test_output/report.xcresult
	@echo "🧼 Test results limpos."

# ============================================================
#  LINT (SWIFTLINT)
# ============================================================
lint: ## Roda análise estática com SwiftLint
	@echo "🔍 Rodando SwiftLint..."
	swiftlint --config .swiftlint.yml

lint_fix: ## Corrige estilo com SwiftLint (autofix)
	@echo "🛠 Corrigindo estilo..."
	swiftlint --fix --config .swiftlint.yml

# ============================================================
#  CONFIGURAÇÃO INICIAL (SETUP)
# ============================================================
setup: ## Executa setup inicial (gitignore, deps, etc.)
	@echo "🚀 Iniciando setup do projeto..."
	bash setup.sh

# ============================================================
#  UTILITÁRIOS
# ============================================================
open: ## Abre o projeto no Xcode
	open $(PROJECT_NAME).xcodeproj

version: ## Mostra a versão atual do app
	@echo "📦 Versão do app: $(APP_VERSION)"

