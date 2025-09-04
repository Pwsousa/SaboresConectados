#!/bin/bash

# Script de Deploy - Sabores Conectados
# Uso: ./deploy.sh [environment] [version]
# Exemplo: ./deploy.sh staging v1.0.0

set -e

ENVIRONMENT=${1:-staging}
VERSION=${2:-latest}
DOCKER_USERNAME=${DOCKER_USERNAME:-saboresconectados}

echo " Iniciando deploy para ambiente: $ENVIRONMENT"
echo " Versão: $VERSION"
echo " Docker Username: $DOCKER_USERNAME"

# Função para verificar se o comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Verificar dependências
if ! command_exists docker; then
    echo " Docker não está instalado"
    exit 1
fi

if ! command_exists docker-compose; then
    echo " Docker Compose não está instalado"
    exit 1
fi

# Função para deploy com Docker Compose
deploy_docker_compose() {
    local env=$1
    local version=$2
    
    echo " Fazendo deploy com Docker Compose..."
    
    # Parar containers existentes
    echo "  Parando containers existentes..."
    docker-compose -f docker-compose.${env}.yml down || true
    
    # Fazer pull das imagens mais recentes
    echo " Fazendo pull das imagens..."
    docker-compose -f docker-compose.${env}.yml pull
    
    # Iniciar os serviços
    echo "  Iniciando serviços..."
    VERSION=$version DOCKER_USERNAME=$DOCKER_USERNAME docker-compose -f docker-compose.${env}.yml up -d
    
    # Aguardar serviços ficarem prontos
    echo " Aguardando serviços ficarem prontos..."
    sleep 30
    
    # Verificar saúde dos serviços
    echo " Verificando saúde dos serviços..."
    check_services_health $env
}

# Função para deploy com Kubernetes
deploy_kubernetes() {
    local env=$1
    local version=$2
    
    echo "  Fazendo deploy com Kubernetes..."
    
    if ! command_exists kubectl; then
        echo " kubectl não está instalado"
        exit 1
    fi
    
    # Aplicar manifestos
    echo " Aplicando manifestos Kubernetes..."
    kubectl apply -f k8s/namespace.yaml
    kubectl apply -f k8s/configmap.yaml
    kubectl apply -f k8s/secrets.yaml
    kubectl apply -f k8s/mysql.yaml
    kubectl apply -f k8s/eureka-server.yaml
    kubectl apply -f k8s/microservices.yaml
    kubectl apply -f k8s/gateway.yaml
    
    # Aguardar deployments ficarem prontos
    echo "⏳ Aguardando deployments ficarem prontos..."
    kubectl wait --for=condition=available --timeout=300s deployment/mysql -n sabores-conectados
    kubectl wait --for=condition=available --timeout=300s deployment/eureka-server -n sabores-conectados
    kubectl wait --for=condition=available --timeout=300s deployment/cardapio-service -n sabores-conectados
    kubectl wait --for=condition=available --timeout=300s deployment/pedidos-service -n sabores-conectados
    kubectl wait --for=condition=available --timeout=300s deployment/pagamentos-service -n sabores-conectados
    kubectl wait --for=condition=available --timeout=300s deployment/gateway -n sabores-conectados
    
    echo " Deploy Kubernetes concluído!"
}

# Função para verificar saúde dos serviços
check_services_health() {
    local env=$1
    
    echo " Verificando saúde dos serviços..."
    
    # Lista de serviços para verificar
    local services=("eureka-server:8761" "cardapio-service:8082" "pedidos-service:8083" "pagamentos-service:8081" "gateway:8084")
    
    for service in "${services[@]}"; do
        local name=$(echo $service | cut -d: -f1)
        local port=$(echo $service | cut -d: -f2)
        
        echo "Verificando $name..."
        
        # Tentar conectar no serviço
        if curl -f -s http://localhost:$port/actuator/health > /dev/null; then
            echo " $name está saudável"
        else
            echo " $name não está respondendo"
            return 1
        fi
    done
    
    echo " Todos os serviços estão saudáveis!"
}

# Função para rollback
rollback() {
    local env=$1
    
    echo " Fazendo rollback..."
    
    if [ "$env" = "kubernetes" ]; then
        kubectl rollout undo deployment/mysql -n sabores-conectados
        kubectl rollout undo deployment/eureka-server -n sabores-conectados
        kubectl rollout undo deployment/cardapio-service -n sabores-conectados
        kubectl rollout undo deployment/pedidos-service -n sabores-conectados
        kubectl rollout undo deployment/pagamentos-service -n sabores-conectados
        kubectl rollout undo deployment/gateway -n sabores-conectados
    else
        docker-compose -f docker-compose.${env}.yml down
        docker-compose -f docker-compose.${env}.yml up -d
    fi
    
    echo " Rollback concluído!"
}

# Função principal
main() {
    case $ENVIRONMENT in
        "staging"|"prod")
            deploy_docker_compose $ENVIRONMENT $VERSION
            ;;
        "kubernetes"|"k8s")
            deploy_kubernetes $ENVIRONMENT $VERSION
            ;;
        "rollback")
            rollback $VERSION
            ;;
        *)
            echo " Ambiente inválido. Use: staging, prod, kubernetes ou rollback"
            exit 1
            ;;
    esac
    
    echo " Deploy concluído com sucesso!"
    echo " Para monitorar os serviços:"
    echo "   - Eureka Dashboard: http://localhost:8761"
    echo "   - Gateway: http://localhost:8084"
    echo "   - Grafana: http://localhost:3000"
    echo "   - Prometheus: http://localhost:9090"
}

# Executar função principal
main
