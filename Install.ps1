Start-Transcript -Path $env:windir\logs\serviceui.log -Force -Verbose

If (Test-Path -LiteralPath 'variable:HostInvocation' -Verbose ) {
        $InvocationInfo = $HostInvocation
    }
    Else {
        $InvocationInfo = $MyInvocation
    } 
    [String]$scriptDirectory = Split-Path -Path $InvocationInfo.MyCommand.Definition -Parent

$targetprocesses = Get-WmiObject -Query "Select * FROM Win32_Process WHERE Name='explorer.exe'" -ErrorAction SilentlyContinue 

$Username = $targetprocesses.GetOwner().User

Write-output "$Username logged in, running with SerivuceUI"

try {

$serviceUI = "$scriptDirectory\ServiceUI.exe"


Start-Process -FilePath $serviceUI -ArgumentList "-Process:explorer.exe $scriptDirectory\Invoke-AppDeployToolkit.exe" -Wait -PassThru -Verbose -Verb RunAs

}

Catch { 
$ErrorMessage=$_.Exception.Message

$ErrorMessage
}


Write-Output "Install Exit Code = $LASTEXITCODE "

Exit $LASTEXITCODE

Stop-Transcript -Verbose