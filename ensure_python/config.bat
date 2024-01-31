@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

set "PYTHON_VERSION=3.7"
set "REQUIREMENTS_LIST=..\examples\requirements.txt"

set "PYTHON_INSTALLER=python-installer.bat"
set "VENV_DIR=.python-venv-windows"
echo %~dp0%VENV_DIR% | findstr /C:"%USERPROFILE%" > nul
if errorlevel 1 (
    set "ABS_VENV_DIR=%~dp0%VENV_DIR%"
    @REM echo "WorkSpace path:%cd%"
) else (
    set "ABS_VENV_DIR=C:\%VENV_DIR%"
    if exist "%VENV_DIR%" (
    rd /q /s "%VENV_DIR%"
    )
    mklink /J "%VENV_DIR%" "!ABS_VENV_DIR!"
    @REM echo "WorkSpace path:%cd% in UserProfile, path length may exceed windows limit(260 words), use C: as root of venv!"
)
set "CHECKSUM_FILE=%ABS_VENV_DIR%\requirements.md5"

goto main

:check_python_version
set "python_exe=%~1"
if "%python_exe%"=="" set "python_exe=python"
for /f "delims=" %%V in ('"%python_exe%" --version 2^>^&1') do set "version_str=%%V"
echo !version_str! | findstr /C:"Python %PYTHON_VERSION%" > nul
if errorlevel 1 (
    exit /b 1
) else (
    exit /b 0
)

:ensure_python_venv
if exist %ABS_VENV_DIR% (
    call :check_python_version "%ABS_VENV_DIR%\Scripts\python.exe"
    if !errorlevel! equ 1 rmdir /s /q %ABS_VENV_DIR%
)
if not exist %ABS_VENV_DIR% (
    python -m venv %ABS_VENV_DIR%
)
call %ABS_VENV_DIR%\Scripts\activate.bat
exit /b 0

:ensure_requirements
set "REINSTALL_REQUIREMENTS=false"
for %%R in (%REQUIREMENTS_LIST%) do (
    if exist "%%R" (
        set "CURRENT_CHECKSUM="
        for /f %%H in ('certutil -hashfile "%%R" MD5 ^| find /v "CertUtil" ^| find /v "MD5"') do set "CURRENT_CHECKSUM=%%H"
        set "STORED_CHECKSUM="
        if exist "%CHECKSUM_FILE%" (
            for /f "tokens=1,* delims= " %%A in ('findstr /C:"%%R" "%CHECKSUM_FILE%"') do set "STORED_CHECKSUM=%%B"
        )
        @REM echo !CURRENT_CHECKSUM!,!STORED_CHECKSUM!
        if not "!CURRENT_CHECKSUM!"=="!STORED_CHECKSUM!" set "REINSTALL_REQUIREMENTS=true"
    )
)
if "!REINSTALL_REQUIREMENTS!"=="true" (
    echo Changes detected in requirements files. Reinstalling dependencies...
    %ABS_VENV_DIR%\Scripts\python.exe -m pip install --upgrade pip
    if exist "%CHECKSUM_FILE%" del "%CHECKSUM_FILE%"
    for %%R in (%REQUIREMENTS_LIST%) do (
        if exist "%%R" (
            %ABS_VENV_DIR%\Scripts\pip install -r "%%R"
            if !errorlevel! equ 0 (
                certutil -hashfile "%%R" MD5 > temp.md5
                for /f %%H in ('type temp.md5 ^| find /v "CertUtil" ^| find /v "MD5"') do (
                    echo %%R %%H>> "%CHECKSUM_FILE%"
                )
                del temp.md5
            ) else (
                echo "error when pip install file:%%R" >&2
                exit /b 1
            )
        )
    )
)
exit /b 0


:main
call :check_python_version
if errorlevel 1 (
    set "found_path="
    for /f "delims=" %%a in ('where python') do (
        call :check_python_version "%%a"
        if !errorlevel! equ 0 (
            set "found_path=%%a"
            for %%i in ("%%a") do set "PYTHON_DIR=%%~dpi"
            set "PATH=!PYTHON_DIR!;!PATH!"
            echo Updated PATH with Python at !PYTHON_DIR!
            goto after_check_path
        )
    )
    :after_check_path
    if "%found_path%"=="" (
        echo Python %PYTHON_VERSION% is not installed.
        echo Continue to open install Program, ensure to check option "Add Python to PATH" or "Add Python to environment variables"
        pause
        start "" "%PYTHON_INSTALLER%"
        exit /b 0
    )
)

call :check_python_version
if errorlevel 1 (
    echo The correct version of Python is not installed >&2
    exit /b 1
)
call :ensure_python_venv
if errorlevel 1 (
    exit /b 1
)
call :ensure_requirements
if errorlevel 1 (
    exit /b 1
)

endlocal && call %ABS_VENV_DIR%\Scripts\activate.bat