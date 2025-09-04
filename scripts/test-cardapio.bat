@echo off
echo Testando microservico de cardapio...

echo.
echo 1. Compilando o projeto...
cd cardapio\Cardapio
mvn clean compile -q
if %errorlevel% neq 0 (
    echo  Erro na compilacao
    pause
    exit /b 1
)
echo  Compilacao bem-sucedida

echo.
echo 2. Executando testes...
mvn test -q
if %errorlevel% neq 0 (
    echo  Erro nos testes
    pause
    exit /b 1
)
echo  Testes passaram

echo.
echo 3. Iniciando servico em background...
start "Cardapio Service" cmd /k "mvn spring-boot:run -Dspring-boot.run.profiles=test"

echo.
echo  Aguardando servico inicializar...
timeout /t 15 /nobreak >nul

echo.
echo 4. Testando endpoints...
echo Testando health check...
curl -s http://localhost:8082/cardapio/itens/health
if %errorlevel% equ 0 (
    echo  Health check funcionando
) else (
    echo  Health check falhou
)

echo.
echo Testando listagem de itens...
curl -s http://localhost:8082/cardapio/itens
if %errorlevel% equ 0 (
    echo  Listagem funcionando
) else (
    echo  Listagem falhou
)

echo.
echo 5. Parando servico...
taskkill /f /im java.exe >nul 2>&1

echo.
echo  Teste do cardapio concluido!
pause
