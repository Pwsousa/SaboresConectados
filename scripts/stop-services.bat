@echo off
echo Parando todos os servicos do Sabores Conectados...

echo.
echo Parando processos Java relacionados aos microservicos...

for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8761') do taskkill /f /pid %%a
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8081') do taskkill /f /pid %%a
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8082') do taskkill /f /pid %%a
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8083') do taskkill /f /pid %%a
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8084') do taskkill /f /pid %%a

echo.
echo Todos os servicos foram parados!
echo.
pause
