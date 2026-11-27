@echo off
cd /d "%~dp0"
start "" "%~dp0TheTowerDescent.exe" --rendering-method gl_compatibility --rendering-driver opengl3
