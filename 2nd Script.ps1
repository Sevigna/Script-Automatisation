#---------------------------------------------------------[Lancement Admin]--------------------------------------------------------
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $Command = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $Command
        Exit
 }
}
Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#--------------------------------------------------------------[Fonctions]--------------------------------------------------------------
function Programmes-Java{
Start-sleep -seconds 3
Write-Host "Lancement Ouverture Appli"
[System.Diagnostics.Process]::Start("\\serveur\SERVEUR\Preparation fixe et portable\Automatisation\OuvertureApplis\bin\OuvertureApplis.exe")
Start-sleep -seconds 5
}

#--------------------------------------------------------------[Lancement Script]--------------------------------------------------------------
Programmes-Java
. "\\serveur\SERVEUR\Preparation fixe et portable\Automatisation\Desinstallation\Scripts\Cleanmgr.ps1"

copy "\\serveur\SERVEUR\Preparation fixe et portable\OEM\CMDavis.bat" "C:\Users\Utilisateur\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 1 -Force
REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /V "LowRiskFileTypes" /T "REG_SZ" /D "" /F  
del "C:\Users\Utilisateur\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\2nd Script.bat"



Set-ExecutionPolicy -ExecutionPolicy Undefined
