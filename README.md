# Sabores Conectados - Sistema de Microserviços

## 🍕 Visão Geral

Sistema completo de microserviços para restaurante desenvolvido com Spring Boot, Spring Cloud e Docker, implementando entrega contínua (CD) e orquestração com Kubernetes. O sistema suporta múltiplos clientes (IoT e Mobile) conectando-se através de um API Gateway centralizado.

## 🏗️ Arquitetura do Sistema

### 📱 Clientes e Interfaces

#### **Cliente IoT (Dispositivos Inteligentes)**
- **Dispositivos**: Terminais de pedido, tablets de mesa, sensores de cozinha
- **Tecnologia**: ESP32/Arduino com conectividade WiFi
- **Design**: [Circuito IoT - Cirkit Designer](https://app.cirkitdesigner.com/project/a7a1f965-5f03-4754-95bc-00742a8c262e)
- **Funcionalidades**:
  - Interface touch para pedidos
  - Integração com sensores de temperatura
  - Notificações em tempo real
  - Status de pedidos em tempo real

#### **Cliente Mobile (Aplicativo)**
- **Plataforma**: Android/iOS
- **Design**: [App Mobile - Figma](https://www.figma.com/design/8Yjrv8fOo9Bo29TMVmBsKP/App-do-restaurante?node-id=1-2&p=f)
- **Funcionalidades**:
  - Cardápio digital interativo
  - Sistema de pedidos
  - Pagamento integrado
  - Histórico de pedidos
  - Avaliações e feedback

### 🔄 Fluxo de Comunicação

```
[Cliente IoT] ──┐
                ├──► [API Gateway:8084] ──► [Eureka Server:8761]
[Cliente Mobile] ──┘                           │
                                               ▼
                                    [Microserviços]
                                    ├── Cardapio:8082
                                    ├── Pedidos:8083
                                    ├── Pagamentos:8081
                                    └── Auth:8085
```

### 📡 Protocolos de Comunicação

#### **Cliente IoT → Gateway**
- **HTTP REST**: Requisições de pedidos e status
- **MQTT**: Notificações em tempo real
- **WebSocket**: Comunicação bidirecional
- **JSON**: Formato de dados

#### **Cliente Mobile → Gateway**
- **HTTP REST**: API principal
- **WebSocket**: Notificações push
- **JWT**: Autenticação segura
- **JSON**: Formato de dados

#### **Gateway → Microserviços**
- **HTTP REST**: Comunicação interna
- **Service Discovery**: Via Eureka
- **Load Balancing**: Distribuição de carga
- **Circuit Breaker**: Tolerância a falhas

### 🏗️ Microserviços Backend

- **Eureka Server** (8761): Service Discovery e Registry
- **Gateway** (8084): API Gateway centralizado
- **Cardapio Service** (8082): Gerenciamento do cardápio
- **Pedidos Service** (8083): Gerenciamento de pedidos
- **Pagamentos Service** (8081): Processamento de pagamentos
- **Auth Service** (8085): Autenticação e autorização

### 🗄️ Infraestrutura
- **MySQL 8.0**: Banco de dados principal
- **Prometheus**: Monitoramento e métricas
- **Grafana**: Dashboards de monitoramento
- **ELK Stack**: Logging centralizado
### 🗄️ Infraestrutura IOT
- **STM32F407VETG**: Hardware embarcado
- **Display** LCL ILI9341 TFT
- **ENC28J60**: Shild de conexão Ethernet

## 🚀 Entrega Contínua (CD)

### Pipeline GitHub Actions
- ✅ **Build automático** de imagens Docker
- ✅ **Push automático** para Docker Hub
- ✅ **Deploy automático** para staging/produção
- ✅ **Testes de integração** com Testcontainers
- ✅ **Verificação de saúde** dos serviços

### Ambientes
- **Desenvolvimento**: Docker Compose local
- **Staging**: Deploy automático via GitHub Actions
- **Produção**: Deploy automático via GitHub Actions
- **Kubernetes**: Orquestração avançada

## 📋 Planejamento do Projeto

### 🎯 Objetivos
- **Automatização completa** do processo de pedidos em restaurantes
- **Múltiplas interfaces** de acesso (IoT e Mobile)
- **Escalabilidade** através de microserviços
- **Monitoramento** em tempo real
- **Entrega contínua** automatizada

### 🏢 Casos de Uso
1. **Cliente faz pedido** via app mobile ou terminal IoT
2. **Sistema processa** através do Gateway
3. **Microserviços** executam lógica de negócio
4. **Cozinha recebe** notificação em tempo real
5. **Cliente acompanha** status do pedido
6. **Pagamento** processado automaticamente

### 🔄 Integração IoT + Mobile
- **Sincronização** entre dispositivos
- **Notificações push** em tempo real
- **Dados compartilhados** entre interfaces
- **Experiência unificada** do usuário

## 🛠️ Stack Tecnológica

### 🖥️ Backend (Microserviços)
- **Java 17**
- **Spring Boot 3.3.4**
- **Spring Cloud 2023.0.3**
- **Spring Security** (JWT)
- **Spring Data JPA**
- **MySQL 8.0**
- **Flyway** (migrações)

### 📱 Frontend & Clientes

#### **Cliente IoT**
- **Hardware**: Stm32,  Raspberry Pi
- **Linguagem**: C, Arduino
- **Comunicação**: WiFi, MQTT, HTTP REST
- **Interface**: TFT Touch Screen, LEDs, Sensores
- **Design**: [Circuito IoT](https://app.cirkitdesigner.com/project/a7a1f965-5f03-4754-95bc-00742a8c262e)

#### **Cliente Mobile**
- **Framework**: React Native / Flutter
- **Plataforma**: Android & iOS
- **Comunicação**: HTTP REST, WebSocket
- **Design**: [App Mobile](https://www.figma.com/design/8Yjrv8fOo9Bo29TMVmBsKP/App-do-restaurante?node-id=1-2&p=f)

### 🚀 DevOps & Orquestração
- **Docker & Docker Compose**
- **Kubernetes**
- **GitHub Actions**
- **Prometheus & Grafana**
- **ELK Stack**

### 🧪 Testes
- **JUnit 5**
- **Testcontainers**
- **REST Assured**
- **WireMock**

## 📋 Pré-requisitos

- Java 17+
- Maven 3.6+
- Docker & Docker Compose
- MySQL 8.0+ (opcional, pode usar container)
- kubectl (para deploy Kubernetes)

## 🚀 Início Rápido

### 1. Setup Automático
```bash
# Linux/Mac
./setup.sh

# Windows
setup.bat
```

### 2. Iniciar Serviços
```bash
# Desenvolvimento
docker-compose up -d

# Staging
docker-compose -f docker-compose.staging.yml up -d

# Produção
docker-compose -f docker-compose.prod.yml up -d
```

### 3. Deploy com Scripts
```bash
# Linux/Mac
./scripts/deploy.sh staging v1.0.0
./scripts/deploy.sh prod v1.0.0
./scripts/deploy.sh kubernetes v1.0.0

# Windows
scripts\deploy.bat staging v1.0.0
scripts\deploy.bat prod v1.0.0
scripts\deploy.bat kubernetes v1.0.0
```

## 🔧 Configuração

### Variáveis de Ambiente
```bash
# Docker Registry
DOCKER_USERNAME=seu_usuario_dockerhub
DOCKER_PASSWORD=sua_senha_dockerhub

# Database
MYSQL_ROOT_PASSWORD=senha_segura

# JWT
JWT_SECRET=chave_secreta_jwt
JWT_EXPIRATION=86400000

# Monitoring
GRAFANA_PASSWORD=senha_grafana
```

### GitHub Secrets
Configure os seguintes secrets no GitHub:
- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`
- `MYSQL_ROOT_PASSWORD`
- `GRAFANA_PASSWORD`

## 📊 Monitoramento

### URLs de Acesso
- **Eureka Dashboard**: http://localhost:8761
- **Gateway**: http://localhost:8084
- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601

### Métricas Disponíveis
- **Sistema**: CPU, Memória, Disk
- **Aplicação**: Response time, Error rate, Throughput
- **Banco de Dados**: Conexões, Queries lentas
- **Eureka**: Instâncias registradas

## 🧪 Testes

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
docker-compose -f docker-compose.test.yml up -d
mvn test -Dtest=EndToEndIntegrationTest
docker-compose -f docker-compose.test.yml down
```

## 🔐 Segurança

### Autenticação
- **JWT Tokens** com expiração configurável
- **Roles**: ADMIN, MANAGER, WAITER, CUSTOMER
- **Endpoints protegidos** com Spring Security

### Secrets Management
- **Desenvolvimento**: Variáveis de ambiente locais
- **Staging/Produção**: Kubernetes Secrets
- **CI/CD**: GitHub Secrets

## 📚 Documentação

- **[DEPLOYMENT.md](DEPLOYMENT.md)**: Documentação completa de deployment
- **[VERSOES_COMPATIBILIDADE.md](VERSOES_COMPATIBILIDADE.md)**: Compatibilidade de versões
- **[API Documentation](cardapio/Cardapio/API_CARDAPIO.md)**: Documentação da API

## 🏗️ Estrutura do Projeto

```
SaboresConectados/
├── .github/workflows/          # GitHub Actions
├── cardapio/Cardapio/          # Microserviço de cardápio
├── Gateway/Gateway/            # API Gateway
├── pagamentos/Pagamentos/      # Microserviço de pagamentos
├── pedidos/                    # Microserviço de pedidos
├── server/                     # Eureka Server
└── pom.xml                     # Maven parent
```

## 🚀 Deploy em Produção

### 1. Configurar Secrets
```bash
# Criar arquivo de configuração
cp config/prod.env.example config/prod.env
# Editar com suas configurações
```

### 2. Deploy Automático
```bash
# Push para branch main ativa deploy automático
git push origin main
```

### 3. Deploy Manual
```bash
# Com Docker Compose
./scripts/deploy.sh prod v1.0.0

# Com Kubernetes
./scripts/deploy.sh kubernetes v1.0.0
```

## 🔄 CI/CD Pipeline

### Workflow Principal
1. **Push/Pull Request** → Trigger pipeline
2. **Testes** → Unitários e integração
3. **Build** → Imagens Docker
4. **Push** → Docker Hub
5. **Deploy** → Staging/Produção
6. **Verificação** → Health checks

### Workflows Disponíveis
- **ci-cd.yml**: Pipeline principal
- **integration-tests.yml**: Testes de integração

## 📈 Escalabilidade

### Kubernetes HPA
- **CPU Threshold**: 70%
- **Memory Threshold**: 80%
- **Min Replicas**: 2-3
- **Max Replicas**: 6-10

### Docker Compose Scaling
```bash
docker-compose up -d --scale cardapio-service=3
docker-compose up -d --scale pedidos-service=3
```

## 🛠️ Comandos Úteis

### Docker
```bash
# Iniciar serviços
docker-compose up -d

# Parar serviços
docker-compose down

# Ver logs
docker-compose logs [service]

# Rebuild
docker-compose up -d --build
```

### Kubernetes
```bash
# Aplicar manifestos
kubectl apply -f k8s/

# Ver pods
kubectl get pods -n sabores-conectados

# Ver logs
kubectl logs [pod-name] -n sabores-conectados

# Escalar
kubectl scale deployment [service] --replicas=3 -n sabores-conectados
```

### Maven
```bash
# Compilar
mvn clean compile

# Testes
mvn test

# Package
mvn clean package

# Executar
mvn spring-boot:run
```

## 🐛 Troubleshooting

### Verificar Saúde dos Serviços
```bash
# Docker Compose
docker-compose ps
docker-compose logs [service]

# Kubernetes
kubectl get pods -n sabores-conectados
kubectl logs [pod-name] -n sabores-conectados
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

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Contato

- **Equipe de Desenvolvimento**: pedro.wilson@ccc.ufg.edu.com.br
- **DevOps Team**: devops@saboresconectados.com
- **Documentação**: [Wiki do Projeto](https://github.com/Pwsousa/SaboresConectados.git)

---

## 🎯 Próximos Passos

### 🚀 Backend & Infraestrutura
- [ ] Implementar Redis para cache distribuído
- [ ] Adicionar API Gateway com rate limiting
- [ ] Implementar Circuit Breaker com Resilience4j
- [ ] Adicionar Distributed Tracing com Jaeger
- [ ] Implementar Blue-Green Deployment
- [ ] Adicionar Health Checks mais robustos
- [ ] Implementar Auto-scaling baseado em métricas customizadas

### 📱 Desenvolvimento de Clientes

#### **Cliente IoT**
- [ ] Implementar circuito baseado no [design Cirkit](https://app.cirkitdesigner.com/project/a7a1f965-5f03-4754-95bc-00742a8c262e)
- [ ] Desenvolver firmware para STM32
- [ ] Integrar Shield Ethernet
- [ ] Implementar interface touch responsiva
- [ ] Configurar comunicação MQTT/HTTP
- [ ] Testes de conectividade e estabilidade

#### **Cliente Mobile**
- [ ] Desenvolver app baseado no [design Figma](https://www.figma.com/design/8Yjrv8fOo9Bo29TMVmBsKP/App-do-restaurante?node-id=1-2&p=f)
- [ ] Implementar autenticação JWT
- [ ] Integrar com API Gateway
- [ ] Implementar notificações push
- [ ] Sistema de pagamento integrado
- [ ] Testes em dispositivos reais

### 🔗 Integração
- [ ] Sincronização em tempo real entre IoT e Mobile
- [ ] Sistema de notificações unificado
- [ ] Dashboard administrativo
- [ ] Relatórios e analytics
- [ ] Testes end-to-end completos

---

