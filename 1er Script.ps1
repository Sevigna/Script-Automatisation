#---------------------------------------------------------[Lancement Admin]--------------------------------------------------------
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $Command = "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
        Start-Process -FilePath PowerShell.exe -Verb RunAs -ArgumentList $Command
        Exit
 }
}

$ErrorActionPreference = 'silentlycontinue'


Set-ExecutionPolicy -ExecutionPolicy Unrestricted

#--------------------------------------------------------------[Fonctions]--------------------------------------------------------------
 function debloat {

        #Disables scheduled tasks that are considered unnecessary 
    Write-Host "Disabling scheduled tasks"
    $task3 = Get-ScheduledTask -TaskName Consolidator -ErrorAction SilentlyContinue
    if ($null -ne $task3) {
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }
    $task4 = Get-ScheduledTask -TaskName UsbCeip -ErrorAction SilentlyContinue
    if ($null -ne $task4) {
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }
    $task5 = Get-ScheduledTask -TaskName DmClient -ErrorAction SilentlyContinue
    if ($null -ne $task5) {
    Get-ScheduledTask  DmClient | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }
    $task6 = Get-ScheduledTask -TaskName DmClientOnScenarioDownload -ErrorAction SilentlyContinue
    if ($null -ne $task6) {
    Get-ScheduledTask  DmClientOnScenarioDownload | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }
    $task7 = Get-ScheduledTask -TaskName ScheduledDefrag -ErrorAction SilentlyContinue
    if ($null -ne $task7) {
    Get-ScheduledTask  ScheduledDefrag | Disable-ScheduledTask -ErrorAction SilentlyContinue
    }

    #Disables Windows Feedback Experience
    Write-Host "Disabling Windows Feedback Experience program"
    $Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (!(Test-Path $Advertising)) {
        New-Item $Advertising
    }
    If (Test-Path $Advertising) {
        Set-ItemProperty $Advertising Enabled -Value 0 
    }
            
    #Stops Cortana from being used as part of your Windows Search Function
    Write-Host "Stopping Cortana from being used as part of your Windows Search Function"
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (!(Test-Path $Search)) {
        New-Item $Search
    }
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }

    #Disables Web Search in Start Menu
    Write-Host "Disabling Bing Search in Start Menu"
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1 

    ##Loop through all user SIDs in the registry and disable Bing Search
    foreach ($sid in $UserSIDs) {
        $WebSearch = "HKU:\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
        If (!(Test-Path $WebSearch)) {
            New-Item $WebSearch
        }
        Set-ItemProperty $WebSearch BingSearchEnabled -Value 0
    }
    
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" BingSearchEnabled -Value 0 

            
    #Stops the Windows Feedback Experience from sending anonymous data
    Write-Host "Stopping the Windows Feedback Experience program"
    $Period = "HKCU:\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) { 
        New-Item $Period
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 

    ##Loop and do the same
    foreach ($sid in $UserSIDs) {
        $Period = "HKU:\$sid\Software\Microsoft\Siuf\Rules"
        If (!(Test-Path $Period)) { 
            New-Item $Period
        }
        Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 
    }

    #Prevents bloatware applications from returning and removes Start Menu suggestions               
    Write-Host "Adding Registry key to prevent bloatware apps from returning"
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0  
    
    ##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $registryOEM = "HKU:\$sid\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
        If (!(Test-Path $registryOEM)) {
            New-Item $registryOEM
        }
        Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
        Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
        Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
        Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
        Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
        Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0 
    }
    
    #Preping mixed Reality Portal for removal    
    Write-Host "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
    $Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
    }

    ##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $Holo = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Holographic"    
        If (Test-Path $Holo) {
            Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
        }
    }
            
    #Disables live tiles
    Write-Host "Disabling live tiles"
    $Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
    If (!(Test-Path $Live)) {      
        New-Item $Live
    }
    Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 

    ##Loop through users and do the same
    foreach ($sid in $UserSIDs) {
        $Live = "HKU:\$sid\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"    
        If (!(Test-Path $Live)) {      
            New-Item $Live
        }
        Set-ItemProperty $Live  NoTileApplicationNotification -Value 1 
    }
        
    Write-Host "Turning off Data Collection"
    $DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
    If (Test-Path $DataCollection1) {
        Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection2) {
        Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection3) {
        Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 
    }



############################################################################################################
#                                             Disable Services                                             #
#                                                                                                          #
############################################################################################################
    Write-Host "Stopping and disabling Diagnostics Tracking Service"
    #Disabling the Diagnostics Tracking Service
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled

    #Remove Cortana
    Get-AppxPackage -allusers Microsoft.549981C3F5F10 | Remove-AppxPackage
    write-host "Removed Cortana"

    #Remove GetStarted
    Get-AppxPackage -allusers *getstarted* | Remove-AppxPackage
    write-host "Removed Get Started"

   #Remove Teams Chat
$MSTeams = "MicrosoftTeams"

$WinPackage = Get-AppxPackage -allusers | Where-Object {$_.Name -eq $MSTeams}
$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -eq $WinPackage }
If ($null -ne $WinPackage) 
{
    Remove-AppxPackage  -Package $WinPackage.PackageFullName
} 

If ($null -ne $ProvisionedPackage) 
{
    Remove-AppxProvisionedPackage -online -Packagename $ProvisionedPackage.Packagename
}
}

function Désinstaller-Programmes {
$programmes = 
 "Norton Security",
 "ExpressVPN",
 "Acer Jumpstart",
 "App Explorer",
 "Solitaire",
 "Dame de Pique",
 "Spades",
 "Dropbox - offre promotionnelle",
 "Clipchamp",
 "Evernote",
 "McAfee LiveSafe",
 "Actualités",
 "Cortana",
 "MSN Météo",
 "Astuces Microsoft",
 "Office",
 "Microsoft Solitaire Collection",
 "Pense-bêtes Microsoft",
 "Contacts Microsoft",
 "Power Automate",
 "Microsoft To Do",
 "Hub de Commentaires",
 "Cartes Windows",
 "Courrier et calendrier",
 "Feedback Hub",
 "Get Help",
 "Votre téléphone",
 "Microsoft 365",
 "Microsoft OneDrive",
 "Microsoft OneNote",
 "Microsoft OneNote - fr-fr",
 "MicrosoftTeams_8wekyb3d8bbwe",
 "GoTrust ID",
 "Obtenir de l'aide"

foreach ($soft in $programmes)
{
  ""
  Write-Host "Désinstallation de" $soft
  winget uninstall $soft
}
}

function Désinstaller-Teams {
# Removal Machine-Wide Installer - This needs to be done before removing the .exe below!
Get-WmiObject -Class Win32_Product | Where-Object {$_.IdentifyingNumber -eq "{39AF0813-FA7B-4860-ADBE-93B9B214B914}"} | Remove-WmiObject

#Variables
$TeamsUsers = Get-ChildItem -Path "$($ENV:SystemDrive)\Users"

 $TeamsUsers | ForEach-Object {
    Try { 
        if (Test-Path "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Microsoft\Teams") {
            Start-Process -FilePath "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Microsoft\Teams\Update.exe" -ArgumentList "-uninstall -s"
        }
    } Catch { 
        Out-Null
    }
}

# Remove AppData folder for $($_.Name).
$TeamsUsers | ForEach-Object {
    Try {
        if (Test-Path "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Microsoft\Teams") {
            Remove-Item –Path "$($ENV:SystemDrive)\Users\$($_.Name)\AppData\Local\Microsoft\Teams" -Recurse -Force -ErrorAction Ignore
        }
    } Catch {
        Out-Null
    }
}
}

function Désinstaller-Office{
. "\\serveur\SERVEUR\Preparation fixe et portable\OEM\SOFT\UninstalleOffice.diagcab"
}

function WindowsUpdates{
Install-WindowsUpdate -AcceptAll -Install
}

function Installation-Modules{
Write-Host "Changement InstallationPolicy" -ForegroundColor Yellow
Set-PSRepository -Name 'PSGallery' -InstallationPolicy trusted
Write-Host "Fait" -ForegroundColor Green
Write-Host "Installation Nuget" -ForegroundColor Yellow
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Scope CurrentUser
clear
Write-Host "Fait" -ForegroundColor Green
Write-Host "Installation PSWindowsUpdate" -ForegroundColor Yellow
Install-Module -Name PSWindowsUpdate
Write-Host "Fait" -ForegroundColor Green
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Untrusted
Write-Host "InstallationPolicy reconfiguré par défault" -ForegroundColor Green
}

function FonctionInput {
    $input = read-host "Entrez [Y] pour continuer"
    start-pause -seconds 1
    switch ($input) `
    {
        'Y' {
            write-host ''
        }

        default {
            write-host 'Entrez la lettre [Y] si vous voulez continuer.'
            FonctionInput
        }
    }
}

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
$computerSystem = (Get-WmiObject -Class:Win32_ComputerSystem)
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force
REG ADD "HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Associations" /V "LowRiskFileTypes" /T "REG_SZ" /D ".avi;.bat;.cmd;.exe;.htm;.html;.lnk;.mpg;.mpeg;.mov;.mp3;.mp4;.mkv;.msi;.m3u;.rar;.reg;.txt;.vbs;.wav;.zip;.7z" /F   
Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\*' -Include *.lnk
Remove-Item 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\*' -Include *.url
copy "\\serveur\SERVEUR\Preparation fixe et portable\Automatisation\Desinstallation\2nd Script.bat" "C:\Users\Utilisateur\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"

#Ouverture de l'automatisation java
"==== Lancement programmes Java ===="
Start-Process -FilePath "\\192.168.1.201\SERVEUR\Preparation fixe et portable\Automatisation\Automatisation\bin\ExecutionAutomatique.exe"
Start-Sleep -seconds 5
Write-Host "Le premier programme java a dû se lancer, si ce n'est pas le cas, lancez le à la main"
Start-Sleep -seconds 5
clear
"==================================="

#Installation Winget
. "\\serveur\SERVEUR\Preparation fixe et portable\Automatisation\Desinstallation\Scripts\winget-install.ps1"
Start-Sleep -seconds 5

#---------------------------------------------------------[Installation Modules]--------------------------------------------------------
Write-Host "==== Installation Modules ===="
Installation-Modules
Write-Host "============================="
#---------------------------------------------------------[Lancement Script]--------------------------------------------------------

Write-Host "============================="
Write-Host "Lancement de la désinstallation 0/4"
Write-Host "Désinstallation des programmes"
Désinstaller-Programmes
Write-Host "Désinstallation progammes terminée. 1/4"

Write-Host "Lancement de la désinstallation de Teams" 
Désinstaller-Teams
Write-Host "Désinstallation Teams terminée. 2/4"

Write-Host "Désinstallation de Office"
Désinstaller-Office
clear
Write-Host "Désinstallez Office avec le programme, appuyez ensuite sur une touche pour continuer"
Write-Host ""
FonctionInput
Write-Host ""
Write-Host "Désinstallation de Office terminée 3/4"
Write-Host "============================="
Start-Sleep -Seconds 3

Write-Host "Debloating 4/4"
debloat
Write-Host "Débloating terminé/4"

#---------------------------------------------------------[Lancement Updates]--------------------------------------------------------
"==== Lancement Updates ===="
WindowsUpdates
clear
start-pause -seconds 2
FonctionInput
restart-computer
"============================"