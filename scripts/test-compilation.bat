@echo off
echo Testando compilacao de todos os microservicos...

echo.
echo 1. Testando Eureka Server...
cd server\Server\server
mvn clean compile
if %errorlevel% neq 0 (
    echo ERRO: Eureka Server nao compilou corretamente
    pause
    exit /b 1
)
cd ..\..\..

echo.
echo 2. Testando Gateway...
cd Gateway\Gateway
mvn clean compile
if %errorlevel% neq 0 (
    echo ERRO: Gateway nao compilou corretamente
    pause
    exit /b 1
)
cd ..\..

echo.
echo 3. Testando Cardapio...
cd cardapio\Cardapio
mvn clean compile
if %errorlevel% neq 0 (
    echo ERRO: Cardapio nao compilou corretamente
    pause
    exit /b 1
)
cd ..\..

echo.
echo 4. Testando Pedidos...
cd pedidos
mvn clean compile
if %errorlevel% neq 0 (
    echo ERRO: Pedidos nao compilou corretamente
    pause
    exit /b 1
)
cd ..

echo.
echo 5. Testando Pagamentos...
cd pagamentos\Pagamentos
mvn clean compile
if %errorlevel% neq 0 (
    echo ERRO: Pagamentos nao compilou corretamente
    pause
    exit /b 1
)
cd ..\..

echo.
echo  Todos os microservicos compilaram com sucesso!
echo.
echo Versoes utilizadas:
echo - Spring Boot: 3.3.4
echo - Spring Cloud: 2023.0.3
echo - Java: 17
echo.
pause
