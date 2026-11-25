@echo off
cd /d "%~dp0"
start "" "%~dp0TheTowerDescent.exe" --rendering-method forward_plus --rendering-driver vulkan
