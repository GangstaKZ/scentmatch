@echo off
setlocal
cd /d "%~dp0"
for %%I in ("..\..\work") do set "SCENTMATCH_WORK=%%~fI"
rem The migrated theme requires Flutter 3.32+; the bundled 3.24 SDK is too old.
set "SCENTMATCH_FLUTTER=C:\src\flutter"
set "PATH=C:\Program Files\Git\cmd;%SystemRoot%\System32;%PATH%"
rem Trust only this Codex-created SDK for this process and its children.
rem The user's global Git configuration remains unchanged.
set "GIT_CONFIG_COUNT=1"
set "GIT_CONFIG_KEY_0=safe.directory"
set "GIT_CONFIG_VALUE_0=%SCENTMATCH_FLUTTER%"
set "PUB_CACHE=%SCENTMATCH_WORK%\pub-cache"
if not exist "%SCENTMATCH_FLUTTER%\bin\flutter.bat" (
  echo Install Flutter 3.32+ in C:\src\flutter or use flutter run from your terminal.
  goto failed
)
echo Preparing ScentMatch...
call "%SCENTMATCH_FLUTTER%\bin\flutter.bat" pub get --offline
if errorlevel 1 (
  echo Retrying dependency download online...
  call "%SCENTMATCH_FLUTTER%\bin\flutter.bat" pub get
  if errorlevel 1 goto failed
)
if /i "%~1"=="--check" exit /b 0
echo Opening ScentMatch in Chrome. Keep this window open.
call "%SCENTMATCH_FLUTTER%\bin\flutter.bat" run -d chrome
if errorlevel 1 goto failed
exit /b 0
:failed
echo.
echo Startup failed. Send a screenshot of this window to the chat.
if /i not "%~1"=="--check" pause
exit /b 1
