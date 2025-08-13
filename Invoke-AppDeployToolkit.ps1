<#

.SYNOPSIS
PSAppDeployToolkit - This script performs the installation or uninstallation of an application(s).

.DESCRIPTION
- The script is provided as a template to perform an install, uninstall, or repair of an application(s).
- The script either performs an "Install", "Uninstall", or "Repair" deployment type.
- The install deployment type is broken down into 3 main sections/phases: Pre-Install, Install, and Post-Install.

The script imports the PSAppDeployToolkit module which contains the logic and functions required to install or uninstall an application.

PSAppDeployToolkit is licensed under the GNU LGPLv3 License - (C) 2025 PSAppDeployToolkit Team (Sean Lillis, Dan Cunningham, Muhammad Mashwani, Mitch Richters, Dan Gough).

This program is free software: you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation, either version 3 of the License, or any later version. This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
for more details. You should have received a copy of the GNU Lesser General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.

.PARAMETER DeploymentType
The type of deployment to perform.

.PARAMETER DeployMode
Specifies whether the installation should be run in Interactive (shows dialogs), Silent (no dialogs), or NonInteractive (dialogs without prompts) mode.

NonInteractive mode is automatically set if it is detected that the process is not user interactive.

.PARAMETER AllowRebootPassThru
Allows the 3010 return code (requires restart) to be passed back to the parent process (e.g. SCCM) if detected from an installation. If 3010 is passed back to SCCM, a reboot prompt will be triggered.

.PARAMETER TerminalServerMode
Changes to "user install mode" and back to "user execute mode" for installing/uninstalling applications for Remote Desktop Session Hosts/Citrix servers.

.PARAMETER DisableLogging
Disables logging to file for the script.

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeployMode Silent

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -AllowRebootPassThru

.EXAMPLE
powershell.exe -File Invoke-AppDeployToolkit.ps1 -DeploymentType Uninstall

.EXAMPLE
Invoke-AppDeployToolkit.exe -DeploymentType "Install" -DeployMode "Silent"

.INPUTS
None. You cannot pipe objects to this script.

.OUTPUTS
None. This script does not generate any output.

.NOTES
Toolkit Exit Code Ranges:
- 60000 - 68999: Reserved for built-in exit codes in Invoke-AppDeployToolkit.ps1, and Invoke-AppDeployToolkit.exe
- 69000 - 69999: Recommended for user customized exit codes in Invoke-AppDeployToolkit.ps1
- 70000 - 79999: Recommended for user customized exit codes in PSAppDeployToolkit.Extensions module.

.LINK
https://psappdeploytoolkit.com

#>

[CmdletBinding()]
param
(
    [Parameter(Mandatory = $false)]
    [ValidateSet('Install', 'Uninstall', 'Repair')]
    [PSDefaultValue(Help = 'Install', Value = 'Install')]
    [System.String]$DeploymentType,

    [Parameter(Mandatory = $false)]
    [ValidateSet('Interactive', 'Silent', 'NonInteractive')]
    [PSDefaultValue(Help = 'Interactive', Value = 'Interactive')]
    [System.String]$DeployMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$AllowRebootPassThru,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$TerminalServerMode,

    [Parameter(Mandatory = $false)]
    [System.Management.Automation.SwitchParameter]$DisableLogging
)


##================================================
## MARK: Variables
##================================================

$adtSession = @{
    # App variables.
    AppVendor = 'Microsoft'
    AppName = 'Windows 11 24H2 Feature Upgrade'
    AppVersion = ''
    AppArch = 'X64'
    AppLang = 'EN'
    AppRevision = '01'
    AppSuccessExitCodes = @(0)
    AppRebootExitCodes = @(1641, 3010)
    AppScriptVersion = '1.0.0'
    AppScriptDate = '2025-07-16'
    AppScriptAuthor = 'Bhushan Kelkar'

    # Install Titles (Only set here to override defaults set by the toolkit).
    InstallName = ''
    InstallTitle = ''

    # Script variables.
    DeployAppScriptFriendlyName = $MyInvocation.MyCommand.Name
    DeployAppScriptVersion = '4.0.6'
    DeployAppScriptParameters = $PSBoundParameters
}

 ## Variables: Environment
    If (Test-Path -LiteralPath 'variable:HostInvocation') {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    }
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent


function Install-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Install
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer if required, allow up to 3 deferrals, verify there is enough disk space to complete the install, and persist the prompt.
    Show-ADTInstallationWelcome -CheckDiskSpace -PersistPrompt  -RequiredDiskSpace 20000 

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress -WindowTitle "Windows 11 24H2 Feature Upgrade in progress" -StatusMessage "Installing Windows 11 24H2 Feature Upgrade" -StatusMessageDetail "This may take up to 3 hours depending on the internet connectivity and system performance, please be patient and continue your work. Your device will reboot once the installation is complete. Make sure to save your work before rebooting the device!"

    ## <Perform Pre-Installation tasks here>


    ##================================================
    ## MARK: Install
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI installations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
        if ($adtSession.DefaultMspFiles)
        {
            $adtSession.DefaultMspFiles | Start-ADTMsiProcess -Action Patch
        }
    }

    ## <Perform Installation tasks here>

        Get-ChildItem "$env:windir\temp\*" -Recurse -ErrorAction SilentlyContinue  | Remove-Item -Recurse -Force -Verbose -Confirm:$false -ErrorAction SilentlyContinue 

        Get-ChildItem "C:\Users\*\AppData\Local\Temp\*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Verbose -Confirm:$false -ErrorAction SilentlyContinue

        Get-ChildItem "C:\Temp\*" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -Verbose -Confirm:$false -ErrorAction SilentlyContinue

        $powercfg = "C:\Windows\System32\powercfg.exe"

        Start-Process $powercfg -ArgumentList "-duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "/S e9a42b02-d5df-448d-aa00-03f14749eb61" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -monitor-timeout-ac 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -monitor-timeout-dc 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -disk-timeout-ac 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -disk-timeout-dc 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -standby-timeout-ac 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -standby-timeout-dc 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -hibernate-timeout-ac 0" -Wait -PassThru -Verbose -Verb RunAs

        Start-Process $powercfg -ArgumentList "-x -hibernate-timeout-dc 0" -Wait -PassThru -Verbose -Verb RunAs



        
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\CompatMarkers" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Shared" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SYSTEM\Setup\MoSetup\Tracking"  -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "HKLM:\SYSTEM\Setup\MoSetup\Volatile"  -Recurse -Force -ErrorAction SilentlyContinue
       
        $reg = "C:\Windows\System32\reg.exe"

        $regkey = "$scriptDirectory\Files\Bypass.reg"
      
        $Configfile = "$scriptDirectory\Files\Setupconfig.ini"
                
        New-Item -ItemType Directory -Path "C:\Users\Default\AppData\Local\Microsoft\Windows\" -Name "WSUS" -Verbose -Force -ErrorAction SilentlyContinue

        Copy-Item -Path $Configfile -Destination "C:\Users\Default\AppData\Local\Microsoft\Windows\WSUS\" -Verbose -Force -ErrorAction SilentlyContinue
                
        start-process $reg -ArgumentList "import $regkey" -Wait -PassThru -Verbose -Verb RunAs

        $caffine = "$scriptDirectory\Files\caffeine64.exe" 

        Start-Process $caffine -ArgumentList "-noicon" -Verbose -Verb RunAs
        
        $setup = "$scriptDirectory\Files\Windows11InstallationAssistant.exe"

	    Start-Process -FilePath $setup  -ArgumentList "/forceuninstall" -Wait -PassThru -Verbose -Verb RunAs
        
        Start-Process -FilePath $setup  -ArgumentList "/skipeula /SkipCompatCheck /auto upgrade /QuietInstall /NoRestartUI" -Wait -PassThru -Verbose -Verb RunAs

        Start-Sleep -Seconds 300 

        Wait-Process -Name Windows10UpgraderApp -ErrorAction SilentlyContinue 

        Get-Process caffeine64 | Stop-Process -Verbose -Force

        Start-Process $powercfg -ArgumentList "/S 381b4222-f694-41f0-9685-ff5bb260df2e" -Wait -PassThru -Verbose -Verb RunAs
        

       
    ##================================================
    ## MARK: Post-Install
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Installation tasks here>


    ## Display a message at the end of the install.
    if (!$adtSession.UseDefaultMsi)
    {
        Show-ADTInstallationPrompt -Message 'Your device will reboot now, Please save your work before clicking "OK"!' -ButtonRightText 'OK' -Icon Information -NoWait 
    }
}

function Uninstall-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Uninstall
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Uninstallation tasks here>


    ##================================================
    ## MARK: Uninstall
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI uninstallations.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Uninstallation tasks here>


    ##================================================
    ## MARK: Post-Uninstallation
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Uninstallation tasks here>
}

function Repair-ADTDeployment
{
    ##================================================
    ## MARK: Pre-Repair
    ##================================================
    $adtSession.InstallPhase = "Pre-$($adtSession.DeploymentType)"

    ## Show Welcome Message, close Internet Explorer with a 60 second countdown before automatically closing.
    Show-ADTInstallationWelcome -CloseProcesses iexplore -CloseProcessesCountdown 60

    ## Show Progress Message (with the default message).
    Show-ADTInstallationProgress

    ## <Perform Pre-Repair tasks here>


    ##================================================
    ## MARK: Repair
    ##================================================
    $adtSession.InstallPhase = $adtSession.DeploymentType

    ## Handle Zero-Config MSI repairs.
    if ($adtSession.UseDefaultMsi)
    {
        $ExecuteDefaultMSISplat = @{ Action = $adtSession.DeploymentType; FilePath = $adtSession.DefaultMsiFile }
        if ($adtSession.DefaultMstFile)
        {
            $ExecuteDefaultMSISplat.Add('Transform', $adtSession.DefaultMstFile)
        }
        Start-ADTMsiProcess @ExecuteDefaultMSISplat
    }

    ## <Perform Repair tasks here>


    ##================================================
    ## MARK: Post-Repair
    ##================================================
    $adtSession.InstallPhase = "Post-$($adtSession.DeploymentType)"

    ## <Perform Post-Repair tasks here>
}


##================================================
## MARK: Initialization
##================================================

# Set strict error handling across entire operation.
$ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
Set-StrictMode -Version 1

# Import the module and instantiate a new session.
try
{
    $moduleName = if ([System.IO.File]::Exists("$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"))
    {
        Get-ChildItem -LiteralPath $PSScriptRoot\PSAppDeployToolkit -Recurse -File | Unblock-File -ErrorAction Ignore
        "$PSScriptRoot\PSAppDeployToolkit\PSAppDeployToolkit.psd1"
    }
    else
    {
        'PSAppDeployToolkit'
    }
    Import-Module -FullyQualifiedName @{ ModuleName = $moduleName; Guid = '8c3c366b-8606-4576-9f2d-4051144f7ca2'; ModuleVersion = '4.0.6' } -Force
    try
    {
        $iadtParams = Get-ADTBoundParametersAndDefaultValues -Invocation $MyInvocation
        $adtSession = Open-ADTSession -SessionState $ExecutionContext.SessionState @adtSession @iadtParams -PassThru
    }
    catch
    {
        Remove-Module -Name PSAppDeployToolkit* -Force
        throw
    }
}
catch
{
    $Host.UI.WriteErrorLine((Out-String -InputObject $_ -Width ([System.Int32]::MaxValue)))
    exit 60008
}


##================================================
## MARK: Invocation
##================================================

try
{
    Get-Item -Path $PSScriptRoot\PSAppDeployToolkit.* | & {
        process
        {
            Get-ChildItem -LiteralPath $_.FullName -Recurse -File | Unblock-File -ErrorAction Ignore
            Import-Module -Name $_.FullName -Force
        }
    }
    & "$($adtSession.DeploymentType)-ADTDeployment"
    Close-ADTSession
}
catch
{
    Write-ADTLogEntry -Message ($mainErrorMessage = Resolve-ADTErrorRecord -ErrorRecord $_) -Severity 3
    Show-ADTDialogBox -Text $mainErrorMessage -Icon Stop | Out-Null
    Close-ADTSession -ExitCode 60001
}
finally
{
    Remove-Module -Name PSAppDeployToolkit* -Force
}

