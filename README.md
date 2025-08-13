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
- [Deployment](#deployment)
- [Usage](#usage)
- [Built Using](#built_using)
- [Authors](#authors)
- [Acknowledgments](#acknowledgement)
- [PSAppDeployToolkit Documentation](https://psappdeploytoolkit.com)

## 🧐 About <a name = "about"></a>

AS Windows 10 end of life is planned on 14th October 2025. Several small, medium and large enterprises have to plan to upgrade to Windows 11 with minimum end user impact. Otherwise, they will end up with devices which will not be able to receive patches. 
However, with the minimum requirements of Windows 11 being UEFI enablement and TPM 2.0 etc. Many existing devices will have to be replaced, which is a big dent in the IT budget. To avoid this I have written a script which sets up some registry values which trick windows in thinking that it already meets these prerequisites to start Windows 11 upgrade.
This uses the PSADT wrapper to execute Windows 11 Installation Assistant tool with parameters which are passed through to windows 11 setup which is downloaded by Windows 11 Installation Assistant tool. 


## 🏁 Getting Started <a name = "getting_started"></a>

This repository contains a PowerShell script, `Invoke-AppDeployToolkit.ps1`, designed to automate the installation, uninstallation, or repair of the Windows 11 24H2 Feature Upgrade using the PSAppDeployToolkit framework. The script provides a robust, customizable, and user-friendly experience for end users.
The ‘Install.ps1’ uses ‘ServiceUI.exe' to initiate the `Invoke-AppDeployToolkit.ps1’ script which although runs in the system account context, the 'ServiceUI.exe' finds the logged-on user session and then project the User Interface of the script to the logged in user. Since the application would be deployed in bulk via tools such as Microsoft System Center Configuration Manager or Microsoft Intune, which will run the installation as system account, the end user would not be aware of any action being performed in the background. This creates a challenge where the end user might accidentally power off or reboot the device and cause the upgrade to fail.
 

### Prerequisites

Prerequisites of the script are kept under ../files folder

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running.

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo.

## 🔧 Running the tests <a name = "tests"></a>

Explain how to run the automated tests for this system.

### Break down into end to end tests

Explain what these tests test and why

```
Give an example
```

### And coding style tests

Explain what these tests test and why

```
Give an example
```

## 🎈 Usage <a name="usage"></a>

Add notes about how to use the system.

## 🚀 Deployment <a name = "deployment"></a>

Add additional notes about how to deploy this on a live system.

## ⛏️ Built Using <a name = "built_using"></a>

- [MongoDB](https://www.mongodb.com/) - Database
- [Express](https://expressjs.com/) - Server Framework
- [VueJs](https://vuejs.org/) - Web Framework
- [NodeJs](https://nodejs.org/en/) - Server Environment

## ✍️ Authors <a name = "authors"></a>

- Bhushan Kelkar [@kountilya](https://github.com/kountilya) - Idea & Initial work
- PSAppDeployToolkit Team (Toolkit Authors)



## 🎉 Acknowledgements <a name = "acknowledgement"></a>

- Hat tip to anyone whose code was used
- Inspiration
- References
