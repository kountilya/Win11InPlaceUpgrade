<p align="center">
  <a href="" rel="noopener">
 <img width=200px height=200px src="https://cdn-dynmedia-1.microsoft.com/is/image/microsoftcorp/sds-windows11-laptop-fy24?scl=1&fmt=png-alpha" alt="Project logo"></a>
</p>

<h3 align="center">Windows 11 InPlace Upgrade</h3>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![GitHub Issues](https://img.shields.io/github/issues/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/issues)
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr/kylelobo/The-Documentation-Compendium.svg)](https://github.com/kylelobo/The-Documentation-Compendium/pulls)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

</div>

---

<p align="center"> This is a simplest Windows 10 to Windows 11 upgrade tool. It will try to overcome most of the prerequisites which block Winows 11 Upgrade on older devices.
    <br> 
</p>

## 📝 Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Prerequisites](#Prerequisites)
- [Deployment](#deployment)
- [Built Using](#built_using)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)


## 🧐 About <a name = "about"></a>

AS Windows 10 end of life is planned on 14th October 2025. Several small, medium and large enterprises have to plan to upgrade to Windows 11 with minimum end user impact. Otherwise, they will end up with devices which will not be able to receive patches. 

However, with the minimum requirements of Windows 11 being UEFI enablement and TPM 2.0 etc. Many existing devices will have to be replaced, which is a big dent in the IT budget. To avoid this I have written a script which sets up some registry values which trick windows in thinking that it already meets these prerequisites to start Windows 11 upgrade.

This uses the PSADT wrapper to execute Windows 11 Installation Assistant tool with parameters which are passed through to windows 11 setup which is downloaded by Windows 11 Installation Assistant tool. 


## 🏁 Getting Started <a name = "getting_started"></a>

This repository contains a PowerShell script, `Invoke-AppDeployToolkit.ps1`, designed to automate the installation, uninstallation, or repair of the Windows 11 24H2 Feature Upgrade using the PSAppDeployToolkit framework. The script provides a robust, customizable, and user-friendly experience for End Users.

The `Install.ps1` uses `ServiceUI.exe` to initiate the `Invoke-AppDeployToolkit.ps1` script which although runs in the system account context, the `ServiceUI.exe` finds the logged-on user session and then projects the User Interface of the script to the logged in user. Since the application would be deployed in bulk via tools such as Microsoft System Center Configuration Manager or Microsoft Intune, which will run the installation as system account, the end user would not be aware of any action being performed in the background. This creates a challenge where the end user might accidentally power off or reboot the device and cause the upgrade to fail.

 

## Prerequisites <a name = "Prerequisites"></a>

Prerequisites of the script are kept under [files](https://github.com/kountilya/Win11InPlaceUpgrade/tree/main/Files) folder

The `Windows11InstallationAssistant.exe` that I have used in the current version is for Windows 11 24H2, I would recommend downloading the latest version of Windows 11 Installation Assistant from [this](https://www.microsoft.com/en-us/software-download/windows11) link.

I am using `Bypass.reg` for some registry keys that I was having hard time putting in the `Invoke-AppDeployToolkit.ps1` script. 

In some tests I found that some devices were going in sleep or hibernate mode. `caffeine64.exe` helps to keep it active during the installation. 

`Setupconfig.ini` provides parameters to the Windows 11 Setup to ignore compatibility check as an additional measure even though we are bypassing them using registry keys. Accepts End User License Agreement, sets the upgrade mode as auto, suspends BitLocker for the duration of Windows 11 installation and disables dynamic update as sometimes it takes longer to get them. Feel free to modify the same according to your requirements.



## 🚀 Deployment <a name = "deployment"></a>


When you are creating the SCCM or Intune package, use the below command to install. Make sure that you have selected install behavior as system.  

```
powershell.exe -ExecutionPolicy Bypass -file ".\Install.ps1"
```

And below detection rule to make sure that the app doesn't accidentally run again and again. 

```
[version]$WinVer = (Get-WMIObject win32_operatingsystem) | Select -ExpandProperty Version

if
 ($WinVer -ge [version]"10.0.22621")

{

Write-Host $true

}
```

***I would recommend to keep the reboot behavior as SCCM/Intune to force device reboot after installation.***


## ⛏️ Built Using <a name = "built_using"></a>

- [PSAppDeployToolkit](https://psappdeploytoolkit.com) - Wrapper
- [Windows11InstallationAssistant](https://www.microsoft.com/en-us/software-download/windows11) - Windows 11 Installation Assistant
- [Caffeine](https://www.zhornsoftware.co.uk/caffeine/) - Prevent your computer from going to sleep

## ✍️ Authors <a name = "authors"></a>

- Bhushan Kelkar [@kountilya](https://github.com/kountilya) - Idea & Initial work
- PSAppDeployToolkit Team [@PSAppDeployToolkit](https://github.com/PSAppDeployToolkit) - Toolkit Authors



## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Hat tip to anyone whose code was used
- References
  
Hardware Check bypass - https://learn.microsoft.com/en-us/windows/win32/api/_hwreqchk/ and https://github.com/pbatard/rufus/issues/2568#issuecomment-2387934171

SetupConfig.ini - https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-setup-command-line-options?view=windows-11 Make sure that you check the applicability section of each parameter to check if it works with `setupconfig.ini`!
