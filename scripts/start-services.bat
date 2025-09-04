@echo off
echo Iniciando microservicos do Sabores Conectados...

echo.
echo 1. Iniciando Eureka Server...
start "Eureka Server" cmd /k "cd server\Server && mvn spring-boot:run"

timeout /t 10 /nobreak > nul

echo.
echo 2. Iniciando microservico de Cardapio...
start "Cardapio Service" cmd /k "cd cardapio\Cardapio && mvn spring-boot:run"

timeout /t 5 /nobreak > nul

echo.
echo 3. Iniciando microservico de Pedidos...
start "Pedidos Service" cmd /k "cd pedidos && mvn spring-boot:run"

timeout /t 5 /nobreak > nul

echo.
echo 4. Iniciando microservico de Pagamentos...
start "Pagamentos Service" cmd /k "cd pagamentos\Pagamentos && mvn spring-boot:run"

timeout /t 5 /nobreak > nul

echo.
echo 5. Iniciando Gateway...
start "Gateway" cmd /k "cd Gateway\Gateway && mvn spring-boot:run"

echo.
echo Todos os servicos foram iniciados!
echo.
echo Acesse:
echo - Eureka Dashboard: http://localhost:8761
echo - Gateway: http://localhost:8084
echo - Cardapio: http://localhost:8084/cardapio/
echo - Pedidos: http://localhost:8084/pedidos/
echo - Pagamentos: http://localhost:8084/pagamentos/
echo.
pause
