@echo off
setlocal
cd /d "%~dp0"
where godot.exe >nul 2>nul
if %errorlevel% equ 0 (
  godot.exe --path "%~dp0prototype"
  exit /b
)
for %%F in ("%~dp0Godot*_win64.exe" "%~dp0godot.exe") do (
  if exist "%%~fF" (
    "%%~fF" --path "%~dp0prototype"
    exit /b
  )
)
echo Godot 4.7.2 standard est requis pour lancer le projet source.
echo Ouvrez https://godotengine.org/download/windows/
echo Importez prototype\project.godot dans Godot puis appuyez sur F5.
pause
