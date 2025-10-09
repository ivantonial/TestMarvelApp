#!/bin/bash

# =============================================================================
# SEÇÃO 1: CABEÇALHO E CONFIGURAÇÃO INICIAL
# =============================================================================

# MarvelApp Setup Script
# Autor: Ivan Tonial
# Descrição: Script para configuração inicial do projeto MarvelApp

# 'set -e' faz o script parar imediatamente se qualquer comando falhar
# Isso evita que erros passem despercebidos
set -e

echo "🚀 Iniciando configuração do MarvelApp..."
echo "========================================"

# =============================================================================
# SEÇÃO 2: DEFINIÇÃO DE CORES PARA OUTPUT
# =============================================================================

# Cores ANSI para melhorar a legibilidade do output no terminal
RED='\033[0;31m'      # Vermelho para erros
GREEN='\033[0;32m'    # Verde para sucessos
YELLOW='\033[1;33m'   # Amarelo para avisos
NC='\033[0m'          # No Color - reseta a cor

# =============================================================================
# SEÇÃO 3: FUNÇÃO PARA VERIFICAR ARQUIVO SECRETS
# =============================================================================

check_secrets_file() {
    # Verifica se o arquivo Secrets.xcconfig existe
    if [ ! -f "MarvelApp/Config/Secrets.xcconfig" ]; then
        echo -e "${YELLOW}⚠️  Arquivo Secrets.xcconfig não encontrado.${NC}"

        # Se não existe, tenta copiar do modelo
        if [ -f "MarvelApp/Config/Secrets-model.xcconfig" ]; then
            echo "📋 Copiando arquivo modelo..."
            cp "MarvelApp/Config/Secrets-model.xcconfig" "MarvelApp/Config/Secrets.xcconfig"
            echo -e "${GREEN}✅ Secrets.xcconfig criado a partir do modelo.${NC}"
            echo -e "${YELLOW}📝 Por favor, edite MarvelApp/Config/Secrets.xcconfig e adicione suas chaves da Marvel API.${NC}"

            # Retorna 1 indicando que precisa configuração manual
            return 1
        else
            echo -e "${RED}❌ Arquivo Secrets-model.xcconfig não encontrado!${NC}"
            exit 1  # Sai do script com erro
        fi
    else
        # Arquivo existe, verifica se as chaves foram configuradas
        # grep -q: busca silenciosamente (quiet) por padrões
        if grep -q "YOUR_PUBLIC_KEY_HERE\|YOUR_PRIVATE_KEY_HERE" "MarvelApp/Config/Secrets.xcconfig"; then
            echo -e "${YELLOW}⚠️  As chaves da Marvel API ainda não foram configuradas em Secrets.xcconfig${NC}"
            echo -e "${YELLOW}📝 Por favor, edite o arquivo e adicione suas chaves.${NC}"
            return 1  # Precisa configuração
        else
            echo -e "${GREEN}✅ Secrets.xcconfig configurado.${NC}"
            return 0  # Tudo OK
        fi
    fi
}

# =============================================================================
# SEÇÃO 4: FUNÇÃO PARA INSTALAR DEPENDÊNCIAS SPM
# =============================================================================

install_dependencies() {
    echo ""
    echo "📦 Verificando dependências Swift Package Manager..."

    # xcodebuild -resolvePackageDependencies baixa e resolve todos os pacotes SPM
    # 2>/dev/null redireciona mensagens de erro para evitar poluir o output
    xcodebuild -resolvePackageDependencies \
        -project MarvelApp.xcodeproj \
        -scheme MarvelApp \
        2>/dev/null

    # $? contém o código de saída do último comando (0 = sucesso)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Dependências SPM resolvidas com sucesso.${NC}"
    else
        echo -e "${RED}❌ Erro ao resolver dependências SPM.${NC}"
        echo "   Por favor, abra o projeto no Xcode e resolva manualmente."
    fi
}

# =============================================================================
# SEÇÃO 5: FUNÇÃO PARA VERIFICAR E CONFIGURAR GITIGNORE
# =============================================================================

check_gitignore() {
    echo ""
    echo "🔒 Verificando .gitignore..."

    if [ -f ".gitignore" ]; then
        # Se .gitignore existe, verifica se contém Secrets.xcconfig
        if grep -q "Secrets.xcconfig" ".gitignore"; then
            echo -e "${GREEN}✅ Secrets.xcconfig está no .gitignore.${NC}"
        else
            # Adiciona Secrets.xcconfig ao .gitignore existente
            echo -e "${YELLOW}⚠️  Adicionando Secrets.xcconfig ao .gitignore...${NC}"
            echo -e "\n# Marvel API Keys\nSecrets.xcconfig" >> .gitignore
            echo -e "${GREEN}✅ Secrets.xcconfig adicionado ao .gitignore.${NC}"
        fi
    else
        # Cria um .gitignore completo se não existe
        echo -e "${YELLOW}⚠️  Criando .gitignore...${NC}"

        # 'cat > .gitignore << EOF' cria um arquivo com conteúdo multilinha
        # EOF marca o fim do conteúdo
        cat > .gitignore << EOF
# Xcode
#
# gitignore contributors: remember to update Global/Xcode.gitignore, Objective-C.gitignore & Swift.gitignore

## User settings
xcuserdata/

## compatibility with Xcode 8 and earlier (ignoring not required starting Xcode 9)
*.xcscmblueprint
*.xccheckout

## compatibility with Xcode 3 and earlier (ignoring not required starting Xcode 4)
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3

## Obj-C/Swift specific
*.hmap

## App packaging
*.ipa
*.dSYM.zip
*.dSYM

## Playgrounds
timeline.xctimeline
playground.xcworkspace

# Swift Package Manager
Packages/
Package.pins
Package.resolved
*.xcodeproj
.swiftpm

# CocoaPods
Pods/

# Carthage
Carthage/Build/

# fastlane
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output

# Marvel API Keys
Secrets.xcconfig
EOF
        echo -e "${GREEN}✅ .gitignore criado com configurações padrão.${NC}"
    fi
}

# =============================================================================
# SEÇÃO 6: FUNÇÃO PARA CRIAR ESTRUTURA DE PASTAS
# =============================================================================

create_folder_structure() {
    echo ""
    echo "📁 Verificando estrutura de pastas..."

    # Array de pastas que devem existir no projeto
    folders=(
        "MarvelApp/Resources"
        "MarvelApp/Resources/Assets"
        "MarvelApp/Resources/Fonts"
        "MarvelApp/SupportingFiles"
        "Documentation"
        "Scripts"
    )

    # Loop através de cada pasta
    for folder in "${folders[@]}"; do
        if [ ! -d "$folder" ]; then
            # mkdir -p: cria a pasta e todas as pastas pai necessárias
            mkdir -p "$folder"
            echo -e "${GREEN}✅ Pasta criada: $folder${NC}"
        fi
    done
}

# =============================================================================
# SEÇÃO 7: FUNÇÃO PARA VERIFICAR XCODE
# =============================================================================

check_xcode() {
    echo ""
    echo "🛠 Verificando Xcode..."

    # 'command -v' verifica se um comando existe
    # &> /dev/null descarta toda a saída (stdout e stderr)
    if ! command -v xcodebuild &> /dev/null; then
        echo -e "${RED}❌ Xcode não encontrado!${NC}"
        echo "   Por favor, instale o Xcode pela App Store."
        exit 1
    else
        # Captura a versão do Xcode
        XCODE_VERSION=$(xcodebuild -version | head -n1)
        echo -e "${GREEN}✅ $XCODE_VERSION instalado.${NC}"
    fi
}

# =============================================================================
# SEÇÃO 8: FUNÇÃO PARA VERIFICAR SWIFT
# =============================================================================

check_swift() {
    echo ""
    echo "🦉 Verificando Swift..."

    if ! command -v swift &> /dev/null; then
        echo -e "${RED}❌ Swift não encontrado!${NC}"
        exit 1
    else
        SWIFT_VERSION=$(swift --version | head -n1)
        echo -e "${GREEN}✅ Swift instalado.${NC}"
    fi
}

# =============================================================================
# SEÇÃO 9: FUNÇÃO PRINCIPAL
# =============================================================================

main() {
    echo ""

    # Executa todas as verificações na ordem apropriada
    check_xcode           # Verifica se Xcode está instalado
    check_swift           # Verifica se Swift está instalado
    check_gitignore       # Configura .gitignore
    create_folder_structure  # Cria pastas necessárias

    # Verifica configuração das chaves da API
    # A função retorna 0 (sucesso) ou 1 (precisa configuração)
    if check_secrets_file; then
        # Se as chaves estão configuradas, instala dependências
        install_dependencies

        # Mostra mensagem de sucesso
        echo ""
        echo "========================================"
        echo -e "${GREEN}🎉 Configuração concluída com sucesso!${NC}"
        echo ""
        echo "📱 Para executar o projeto:"
        echo "   1. Abra MarvelApp.xcodeproj no Xcode"
        echo "   2. Selecione um simulador ou dispositivo"
        echo "   3. Pressione Cmd+R para executar"
        echo ""
    else
        # Se as chaves NÃO estão configuradas, mostra instruções
        echo ""
        echo "========================================"
        echo -e "${YELLOW}⚠️  Configuração parcialmente concluída!${NC}"
        echo ""
        echo "📝 Próximos passos:"
        echo "   1. Edite MarvelApp/Secrets.xcconfig"
        echo "   2. Adicione suas chaves da Marvel API"
        echo "   3. Execute este script novamente: ./setup.sh"
        echo ""
        echo "🔑 Obtenha suas chaves em: https://developer.marvel.com/account"
        echo ""
    fi
}

# =============================================================================
# SEÇÃO 10: EXECUÇÃO DO SCRIPT
# =============================================================================

# Chama a função principal
main
