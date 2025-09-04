# Documentação de Deployment - Sabores Conectados

## Visão Geral

Este documento descreve o processo de deployment e orquestração do sistema Sabores Conectados, incluindo pipelines de CI/CD, ambientes de deployment e ferramentas de monitoramento.

## Arquitetura do Sistema

### Microserviços
- **Eureka Server** (8761): Service Discovery
- **Gateway** (8084): API Gateway
- **Cardapio Service** (8082): Gerenciamento do cardápio
- **Pedidos Service** (8083): Gerenciamento de pedidos
- **Pagamentos Service** (8081): Processamento de pagamentos
- **Auth Service** (8085): Autenticação e autorização

### Infraestrutura
- **MySQL 8.0**: Banco de dados principal
- **Prometheus**: Monitoramento e métricas
- **Grafana**: Dashboards de monitoramento
- **ELK Stack**: Logging centralizado (Elasticsearch, Logstash, Kibana)

## Ambientes

### 1. Desenvolvimento (Local)
```bash
# Usar docker-compose.yml
docker-compose up -d
```

### 2. Staging
```bash
# Usar docker-compose.staging.yml
docker-compose -f docker-compose.staging.yml up -d
```

### 3. Produção
```bash
# Usar docker-compose.prod.yml
docker-compose -f docker-compose.prod.yml up -d
```

### 4. Kubernetes
```bash
# Aplicar manifestos Kubernetes
kubectl apply -f k8s/
```

## Pipeline de CI/CD

### GitHub Actions

O pipeline está configurado em `.github/workflows/ci-cd.yml` e inclui:

1. **Testes Unitários e de Integração**
   - Execução de testes com Maven
   - Testes com Testcontainers
   - Relatórios de cobertura

2. **Build e Push de Imagens Docker**
   - Build automático de imagens
   - Push para Docker Hub
   - Versionamento com tags

3. **Deploy Automático**
   - Deploy para staging (branch develop)
   - Deploy para produção (branch main)
   - Verificação de saúde dos serviços

### Configuração de Secrets

Configure os seguintes secrets no GitHub:

```bash
DOCKER_USERNAME=seu_usuario_dockerhub
DOCKER_PASSWORD=sua_senha_dockerhub
MYSQL_ROOT_PASSWORD=senha_mysql_producao
GRAFANA_PASSWORD=senha_grafana
```

## Scripts de Deploy

### Deploy com Docker Compose

```bash
# Deploy para staging
./scripts/deploy.sh staging v1.0.0

# Deploy para produção
./scripts/deploy.sh prod v1.0.0

# Deploy com Kubernetes
./scripts/deploy.sh kubernetes v1.0.0

# Rollback
./scripts/deploy.sh rollback staging
```

### Deploy Manual

#### Docker Compose
```bash
# Staging
VERSION=v1.0.0 DOCKER_USERNAME=seu_usuario docker-compose -f docker-compose.staging.yml up -d

# Produção
VERSION=v1.0.0 DOCKER_USERNAME=seu_usuario MYSQL_ROOT_PASSWORD=senha_segura docker-compose -f docker-compose.prod.yml up -d
```

#### Kubernetes
```bash
# Aplicar namespace
kubectl apply -f k8s/namespace.yaml

# Aplicar configurações
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/secrets.yaml

# Aplicar serviços
kubectl apply -f k8s/mysql.yaml
kubectl apply -f k8s/eureka-server.yaml
kubectl apply -f k8s/microservices.yaml
kubectl apply -f k8s/gateway.yaml
```

## Monitoramento

### Prometheus
- **URL**: http://localhost:9090
- **Configuração**: `config/prometheus/prometheus.yml`
- **Alertas**: `config/prometheus/rules/alerts.yml`

### Grafana
- **URL**: http://localhost:3000
- **Usuário**: admin
- **Senha**: configurada via variável de ambiente

### Dashboards Disponíveis
- **Sistema**: CPU, Memória, Disk
- **Aplicação**: Response time, Error rate, Throughput
- **Banco de Dados**: Conexões, Queries lentas
- **Eureka**: Instâncias registradas

## Logging

### ELK Stack
- **Elasticsearch**: http://localhost:9200
- **Kibana**: http://localhost:5601
- **Logstash**: Configuração em `config/logstash/logstash.conf`

### Estrutura de Logs
```json
{
  "timestamp": "2024-01-01T10:00:00Z",
  "level": "INFO",
  "service": "cardapio-service",
  "message": "Item criado com sucesso",
  "userId": "123",
  "requestId": "req-456"
}
```

## Testes

### Testes Unitários
```bash
mvn test
```

### Testes de Integração
```bash
mvn verify -Dspring.profiles.active=integration
```

### Testes End-to-End
```bash
# Com Docker Compose
docker-compose -f docker-compose.test.yml up -d
mvn test -Dtest=EndToEndIntegrationTest
docker-compose -f docker-compose.test.yml down
```

## Segurança

### Autenticação
- **JWT Tokens**: Configurados no Auth Service
- **Roles**: ADMIN, MANAGER, WAITER, CUSTOMER
- **Expiração**: Configurável via `jwt.expiration`

### Secrets Management
- **Desenvolvimento**: Variáveis de ambiente locais
- **Staging/Produção**: Kubernetes Secrets ou Docker Secrets
- **CI/CD**: GitHub Secrets

### Network Security
- **Docker Networks**: Isolamento entre serviços
- **Kubernetes Network Policies**: Controle de tráfego
- **TLS**: Configurável para produção

## Backup e Recuperação

### Banco de Dados
```bash
# Backup
docker exec mysql mysqldump -u root -p sabores_conectados > backup.sql

# Restore
docker exec -i mysql mysql -u root -p sabores_conectados < backup.sql
```

### Volumes Docker
```bash
# Backup de volumes
docker run --rm -v sabores_mysql_data:/data -v $(pwd):/backup alpine tar czf /backup/mysql_backup.tar.gz /data
```

## Troubleshooting

### Verificar Saúde dos Serviços
```bash
# Docker Compose
docker-compose ps
docker-compose logs [service_name]

# Kubernetes
kubectl get pods -n sabores-conectados
kubectl logs [pod_name] -n sabores-conectados
```

### Verificar Conectividade
```bash
# Eureka Dashboard
curl http://localhost:8761

# Health Checks
curl http://localhost:8084/actuator/health
curl http://localhost:8082/actuator/health
curl http://localhost:8083/actuator/health
curl http://localhost:8081/actuator/health
curl http://localhost:8085/actuator/health
```

### Logs de Debug
```bash
# Ativar debug logs
export LOGGING_LEVEL_ROOT=DEBUG
docker-compose up -d
```

## Performance

### Otimizações Aplicadas
- **JVM Tuning**: Configurado via JAVA_OPTS
- **Database Connection Pool**: Configurado no Spring Boot
- **Caching**: Redis (futuro)
- **Load Balancing**: Nginx ou HAProxy (futuro)

### Métricas de Performance
- **Response Time**: < 200ms (95th percentile)
- **Throughput**: > 1000 requests/second
- **Availability**: 99.9% uptime
- **Error Rate**: < 0.1%

## Escalabilidade

### Horizontal Pod Autoscaler (Kubernetes)
- **CPU Threshold**: 70%
- **Memory Threshold**: 80%
- **Min Replicas**: 2-3
- **Max Replicas**: 6-10

### Docker Compose Scaling
```bash
# Escalar serviços
docker-compose up -d --scale cardapio-service=3
docker-compose up -d --scale pedidos-service=3
```

## Próximos Passos

1. **Implementar Redis** para cache distribuído
2. **Adicionar API Gateway** com rate limiting
3. **Implementar Circuit Breaker** com Resilience4j
4. **Adicionar Distributed Tracing** com Jaeger
5. **Implementar Blue-Green Deployment**
6. **Adicionar Health Checks** mais robustos
7. **Implementar Auto-scaling** baseado em métricas customizadas

## Contatos

- **DevOps Team**: devops@saboresconectados.com
- **Documentação**: [Wiki do Projeto](https://github.com/Pwsousa/SaboresConectados.git)
- **Issues**: [GitHub Issues](https://github.com/saboresconectados/issues)
