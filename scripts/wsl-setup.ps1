# Run as Administrator in PowerShell, then reboot once.
Set-ExecutionPolicy -Scope Process Bypass -Force
wsl --install -d Ubuntu-24.04
Write-Host ""
Write-Host "WSL installed. REBOOT the PC now, then open Ubuntu, create a user, and follow scripts/wsl-build.md"
