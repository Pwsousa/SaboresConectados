@echo off
REM Script de Deploy - Sabores Conectados (Windows)
REM Uso: deploy.bat [environment] [version]
REM Exemplo: deploy.bat staging v1.0.0

setlocal enabledelayedexpansion

set ENVIRONMENT=%1
set VERSION=%2
set DOCKER_USERNAME=%DOCKER_USERNAME%

if "%ENVIRONMENT%"=="" set ENVIRONMENT=staging
if "%VERSION%"=="" set VERSION=latest
if "%DOCKER_USERNAME%"=="" set DOCKER_USERNAME=saboresconectados

echo  Iniciando deploy para ambiente: %ENVIRONMENT%
echo  Versão: %VERSION%
echo  Docker Username: %DOCKER_USERNAME%

REM Verificar se Docker está instalado
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Docker não está instalado
    pause
    exit /b 1
)

REM Verificar se Docker Compose está instalado
docker-compose --version >nul 2>&1
if %errorlevel% neq 0 (
    echo  Docker Compose não está instalado
    pause
    exit /b 1
)

if "%ENVIRONMENT%"=="staging" goto deploy_staging
if "%ENVIRONMENT%"=="prod" goto deploy_prod
if "%ENVIRONMENT%"=="kubernetes" goto deploy_kubernetes
if "%ENVIRONMENT%"=="rollback" goto rollback
goto invalid_environment

:deploy_staging
echo  Fazendo deploy com Docker Compose para staging...

REM Parar containers existentes
echo ⏹  Parando containers existentes...
docker-compose -f docker-compose.staging.yml down >nul 2>&1

REM Fazer pull das imagens mais recentes
echo  Fazendo pull das imagens...
docker-compose -f docker-compose.staging.yml pull

REM Iniciar os serviços
echo   Iniciando serviços...
set VERSION=%VERSION%
set DOCKER_USERNAME=%DOCKER_USERNAME%
docker-compose -f docker-compose.staging.yml up -d

REM Aguardar serviços ficarem prontos
echo  Aguardando serviços ficarem prontos...
timeout /t 30 /nobreak >nul

REM Verificar saúde dos serviços
echo  Verificando saúde dos serviços...
call :check_services_health staging
goto end

:deploy_prod
echo  Fazendo deploy com Docker Compose para produção...

REM Verificar se arquivo de configuração existe
if not exist "config\prod.env" (
    echo  Arquivo config\prod.env não encontrado. Configure as variáveis de ambiente de produção.
    pause
    exit /b 1
)

REM Parar containers existentes
echo   Parando containers existentes...
docker-compose -f docker-compose.prod.yml down >nul 2>&1

REM Fazer pull das imagens mais recentes
echo  Fazendo pull das imagens...
docker-compose -f docker-compose.prod.yml pull

REM Iniciar os serviços
echo   Iniciando serviços...
set VERSION=%VERSION%
set DOCKER_USERNAME=%DOCKER_USERNAME%
docker-compose -f docker-compose.prod.yml up -d

REM Aguardar serviços ficarem prontos
echo  Aguardando serviços ficarem prontos...
timeout /t 30 /nobreak >nul

REM Verificar saúde dos serviços
echo  Verificando saúde dos serviços...
call :check_services_health prod
goto end

:deploy_kubernetes
echo   Fazendo deploy com Kubernetes...

REM Verificar se kubectl está instalado
kubectl version --client >nul 2>&1
if %errorlevel% neq 0 (
    echo  kubectl não está instalado
    pause
    exit /b 1
)

REM Aplicar manifestos
echo  Aplicando manifestos Kubernetes...
kubectl apply -f k8s\namespace.yaml
kubectl apply -f k8s\configmap.yaml
kubectl apply -f k8s\secrets.yaml
kubectl apply -f k8s\mysql.yaml
kubectl apply -f k8s\eureka-server.yaml
kubectl apply -f k8s\microservices.yaml
kubectl apply -f k8s\gateway.yaml

REM Aguardar deployments ficarem prontos
echo  Aguardando deployments ficarem prontos...
kubectl wait --for=condition=available --timeout=300s deployment/mysql -n sabores-conectados
kubectl wait --for=condition=available --timeout=300s deployment/eureka-server -n sabores-conectados
kubectl wait --for=condition=available --timeout=300s deployment/cardapio-service -n sabores-conectados
kubectl wait --for=condition=available --timeout=300s deployment/pedidos-service -n sabores-conectados
kubectl wait --for=condition=available --timeout=300s deployment/pagamentos-service -n sabores-conectados
kubectl wait --for=condition=available --timeout=300s deployment/gateway -n sabores-conectados

echo  Deploy Kubernetes concluído!
goto end

:rollback
echo  Fazendo rollback...
if "%VERSION%"=="kubernetes" (
    kubectl rollout undo deployment/mysql -n sabores-conectados
    kubectl rollout undo deployment/eureka-server -n sabores-conectados
    kubectl rollout undo deployment/cardapio-service -n sabores-conectados
    kubectl rollout undo deployment/pedidos-service -n sabores-conectados
    kubectl rollout undo deployment/pagamentos-service -n sabores-conectados
    kubectl rollout undo deployment/gateway -n sabores-conectados
) else (
    docker-compose -f docker-compose.%VERSION%.yml down
    docker-compose -f docker-compose.%VERSION%.yml up -d
)
echo  Rollback concluído!
goto end

:invalid_environment
echo  Ambiente inválido. Use: staging, prod, kubernetes ou rollback
pause
exit /b 1

:check_services_health
set ENV=%1
echo  Verificando saúde dos serviços...

REM Lista de serviços para verificar
set services=eureka-server:8761 cardapio-service:8082 pedidos-service:8083 pagamentos-service:8081 gateway:8084 auth-service:8085

for %%s in (%services%) do (
    for /f "tokens=1,2 delims=:" %%a in ("%%s") do (
        echo Verificando %%a...
        curl -f -s http://localhost:%%b/actuator/health >nul 2>&1
        if !errorlevel! equ 0 (
            echo  %%a está saudável
        ) else (
            echo  %%a não está respondendo
            exit /b 1
        )
    )
)

echo  Todos os serviços estão saudáveis!
goto :eof

:end
echo  Deploy concluído com sucesso!
echo  Para monitorar os serviços:
echo    - Eureka Dashboard: http://localhost:8761
echo    - Gateway: http://localhost:8084
echo    - Grafana: http://localhost:3000
echo    - Prometheus: http://localhost:9090
echo    - Kibana: http://localhost:5601
pause
