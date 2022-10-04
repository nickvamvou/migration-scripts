[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-Module -Name AWSPowerShell -Force
Set-ExecutionPolicy RemoteSigned -Force
Get-AWSPowerShellVersion 
