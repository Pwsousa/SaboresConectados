#!/bin/bash

# Script de Setup - Sabores Conectados
# Este script configura o ambiente de desenvolvimento e produção

set -e

echo "🚀 Configurando ambiente Sabores Conectados..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar se o comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Função para imprimir mensagens coloridas
print_status() {
    echo -e "${GREEN} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}  $1${NC}"
}

print_error() {
    echo -e "${RED} $1${NC}"
}

# Verificar dependências
echo " Verificando dependências..."

if ! command_exists docker; then
    print_error "Docker não está instalado. Instale o Docker primeiro."
    exit 1
fi
print_status "Docker encontrado"

if ! command_exists docker-compose; then
    print_error "Docker Compose não está instalado. Instale o Docker Compose primeiro."
    exit 1
fi
print_status "Docker Compose encontrado"

if ! command_exists mvn; then
    print_warning "Maven não encontrado. Algumas funcionalidades podem não funcionar."
fi

if ! command_exists kubectl; then
    print_warning "kubectl não encontrado. Deploy Kubernetes não estará disponível."
fi

# Criar diretórios necessários
echo " Criando diretórios..."
mkdir -p config/prometheus/rules
mkdir -p config/logstash
mkdir -p config/mysql/staging
mkdir -p config/mysql/prod
mkdir -p backups
mkdir -p logs

print_status "Diretórios criados"

# Configurar permissões
echo " Configurando permissões..."
chmod +x scripts/deploy.sh
chmod +x setup.sh

print_status "Permissões configuradas"

# Verificar se arquivo de configuração de produção existe
if [ ! -f "config/prod.env" ]; then
    print_warning "Arquivo config/prod.env não encontrado. Criando template..."
    cp config/prod.env.example config/prod.env 2>/dev/null || echo "Crie o arquivo config/prod.env com suas configurações de produção"
fi

# Verificar se secrets do GitHub estão configurados
echo " Verificando configuração de secrets..."

if [ -z "$DOCKER_USERNAME" ]; then
    print_warning "DOCKER_USERNAME não configurado. Configure no GitHub Secrets ou como variável de ambiente."
fi

if [ -z "$DOCKER_PASSWORD" ]; then
    print_warning "DOCKER_PASSWORD não configurado. Configure no GitHub Secrets ou como variável de ambiente."
fi

# Build das imagens Docker
echo " Fazendo build das imagens Docker..."

# Build do Eureka Server
echo "Building Eureka Server..."
docker build -t saboresconectados/eureka-server:latest ./server/Server

# Build do Gateway
echo "Building Gateway..."
docker build -t saboresconectados/gateway:latest ./Gateway/Gateway

# Build do Cardapio Service
echo "Building Cardapio Service..."
docker build -t saboresconectados/cardapio-service:latest ./cardapio/Cardapio

# Build do Pedidos Service
echo "Building Pedidos Service..."
docker build -t saboresconectados/pedidos-service:latest ./pedidos

# Build do Pagamentos Service
echo "Building Pagamentos Service..."
docker build -t saboresconectados/pagamentos-service:latest ./pagamentos/Pagamentos

# Build do Auth Service
echo "Building Auth Service..."
docker build -t saboresconectados/auth-service:latest ./auth-service

print_status "Imagens Docker construídas"

# Teste de compilação
echo "🧪 Testando compilação..."

if command_exists mvn; then
    mvn clean compile -q
    print_status "Compilação bem-sucedida"
else
    print_warning "Maven não encontrado. Pulando teste de compilação."
fi

# Verificar se os serviços podem ser iniciados
echo "🚀 Testando inicialização dos serviços..."

# Parar containers existentes
docker-compose down 2>/dev/null || true

# Iniciar serviços em background
docker-compose up -d

# Aguardar serviços ficarem prontos
echo " Aguardando serviços ficarem prontos..."
sleep 30

# Verificar saúde dos serviços
echo "🏥 Verificando saúde dos serviços..."

services=("eureka-server:8761" "cardapio-service:8082" "pedidos-service:8083" "pagamentos-service:8081" "gateway:8084" "auth-service:8085")

for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if curl -f -s http://localhost:$port/actuator/health > /dev/null 2>&1; then
        print_status "$name está saudável"
    else
        print_warning "$name não está respondendo (pode estar inicializando)"
    fi
done

# Parar serviços de teste
docker-compose down

print_status "Teste de inicialização concluído"

# Mostrar próximos passos
echo ""
echo " Setup concluído com sucesso!"
echo ""
echo " Próximos passos:"
echo "1. Configure os secrets no GitHub (DOCKER_USERNAME, DOCKER_PASSWORD, etc.)"
echo "2. Configure o arquivo config/prod.env com suas senhas de produção"
echo "3. Execute './scripts/deploy.sh staging' para deploy em staging"
echo "4. Execute './scripts/deploy.sh prod' para deploy em produção"
echo ""
echo " Documentação:"
echo "- DEPLOYMENT.md - Documentação completa de deployment"
echo "- README.md - Documentação geral do projeto"
echo ""
echo " URLs importantes:"
echo "- Eureka Dashboard: http://localhost:8761"
echo "- Gateway: http://localhost:8084"
echo "- Grafana: http://localhost:3000"
echo "- Prometheus: http://localhost:9090"
echo "- Kibana: http://localhost:5601"
echo ""
echo "  Comandos úteis:"
echo "- Iniciar serviços: docker-compose up -d"
echo "- Parar serviços: docker-compose down"
echo "- Ver logs: docker-compose logs [service]"
echo "- Deploy: ./scripts/deploy.sh [environment] [version]"
echo ""
