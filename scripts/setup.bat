@echo off
echo  Configurando ambiente Sabores Conectados...

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Docker não está instalado. Instale o Docker primeiro.
    pause
    exit /b 1
)
echo  Docker encontrado

REM Verificar se Docker Compose está instalado
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Docker Compose não está instalado. Instale o Docker Compose primeiro.
    pause
    exit /b 1
)
echo  Docker Compose encontrado

REM Verificar se Maven está instalado
mvn --version >nul 2>&1
if %errorlevel% neq 0 (
    echo   Maven não encontrado. Algumas funcionalidades podem não funcionar.
) else (
    echo  Maven encontrado
)

REM Criar diretórios necessários
echo  Criando diretórios...
if not exist "config\prometheus\rules" mkdir "config\prometheus\rules"
if not exist "config\logstash" mkdir "config\logstash"
if not exist "config\mysql\staging" mkdir "config\mysql\staging"
if not exist "config\mysql\prod" mkdir "config\mysql\prod"
if not exist "backups" mkdir "backups"
if not exist "logs" mkdir "logs"
echo  Diretórios criados

REM Verificar se arquivo de configuração de produção existe
if not exist "config\prod.env" (
    echo   Arquivo config\prod.env não encontrado. Crie este arquivo com suas configurações de produção.
)

REM Build das imagens Docker
echo  Fazendo build das imagens Docker...

echo Building Eureka Server...
docker build -t saboresconectados/eureka-server:latest ./server/Server
if %errorlevel% neq 0 (
    echo  Erro ao construir Eureka Server
    pause
    exit /b 1
)

echo Building Gateway...
docker build -t saboresconectados/gateway:latest ./Gateway/Gateway
if %errorlevel% neq 0 (
    echo  Erro ao construir Gateway
    pause
    exit /b 1
)

echo Building Cardapio Service...
docker build -t saboresconectados/cardapio-service:latest ./cardapio/Cardapio
if %errorlevel% neq 0 (
    echo  Erro ao construir Cardapio Service
    pause
    exit /b 1
)

echo Building Pedidos Service...
docker build -t saboresconectados/pedidos-service:latest ./pedidos
if %errorlevel% neq 0 (
    echo  Erro ao construir Pedidos Service
    pause
    exit /b 1
)

echo Building Pagamentos Service...
docker build -t saboresconectados/pagamentos-service:latest ./pagamentos/Pagamentos
if %errorlevel% neq 0 (
    echo  Erro ao construir Pagamentos Service
    pause
    exit /b 1
)

echo Building Auth Service...
docker build -t saboresconectados/auth-service:latest ./auth-service
if %errorlevel% neq 0 (
    echo  Erro ao construir Auth Service
    pause
    exit /b 1
)

echo  Imagens Docker construídas

REM Teste de compilação
echo  Testando compilação...
mvn clean compile -q
if %errorlevel% neq 0 (
    echo   Erro na compilação. Verifique as dependências.
) else (
    echo  Compilação bem-sucedida
)

REM Verificar se os serviços podem ser iniciados
echo  Testando inicialização dos serviços...

REM Parar containers existentes
docker-compose down >nul 2>&1

REM Iniciar serviços em background
docker-compose up -d
if %errorlevel% neq 0 (
    echo  Erro ao iniciar serviços
    pause
    exit /b 1
)

REM Aguardar serviços ficarem prontos
echo  Aguardando serviços ficarem prontos...
timeout /t 30 /nobreak >nul

REM Verificar saúde dos serviços
echo  Verificando saúde dos serviços...

REM Verificar Eureka Server
curl -f -s http://localhost:8761/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo  eureka-server está saudável
) else (
    echo   eureka-server não está respondendo
)

REM Verificar Gateway
curl -f -s http://localhost:8084/actuator/health >nul 2>&1
if %errorlevel% equ 0 (
    echo  gateway está saudável
) else (
    echo   gateway não está respondendo
)

REM Parar serviços de teste
docker-compose down >nul 2>&1

echo  Teste de inicialização concluído

REM Mostrar próximos passos
echo.
echo  Setup concluído com sucesso!
echo.
echo  Próximos passos:
echo 1. Configure os secrets no GitHub (DOCKER_USERNAME, DOCKER_PASSWORD, etc.)
echo 2. Configure o arquivo config\prod.env com suas senhas de produção
echo 3. Execute 'scripts\deploy.bat staging' para deploy em staging
echo 4. Execute 'scripts\deploy.bat prod' para deploy em produção
echo.
echo  Documentação:
echo - DEPLOYMENT.md - Documentação completa de deployment
echo - README.md - Documentação geral do projeto
echo.
echo  URLs importantes:
echo - Eureka Dashboard: http://localhost:8761
echo - Gateway: http://localhost:8084
echo - Grafana: http://localhost:3000
echo - Prometheus: http://localhost:9090
echo - Kibana: http://localhost:5601
echo.
echo   Comandos úteis:
echo - Iniciar serviços: docker-compose up -d
echo - Parar serviços: docker-compose down
echo - Ver logs: docker-compose logs [service]
echo - Deploy: scripts\deploy.bat [environment] [version]
echo.
pause
