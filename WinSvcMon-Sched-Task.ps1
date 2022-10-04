$action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument '-File c:\scripts\service-monitoring-cw.ps1'
$tSettings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Hours 1) -Hidden
$tPrincipal = New-ScheduledTaskPrincipal -Id "Author" -UserId "Administrator" -LogonType Password -RunLevel Limited
$tCredential = Get-Credential
$tUser = $tCredential.Username
$tPass = [System.Net.NetworkCredential]::new("", $tCredential.Password).Password
$tPath = "Sizmek"
$tName = "service-monitoring"
$tDesc = "Monitors Windows service status and sends the metrics to AWS via CloudWatch"
if([environment]::OSVersion.Version.Major -eq 10) {
    $trigger = New-ScheduledTaskTrigger -Once -At 12am -RepetitionInterval (New-TimeSpan -Minutes 5) } else {
    $trigger = New-ScheduledTaskTrigger -Once -At 12am -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([TimeSpan]::MaxValue)
}
$task = New-ScheduledTask -Description $tDesc -Action $action -Principal $tPrincipal -Trigger $trigger -Settings $tSettings
$task = $task | Register-ScheduledTask -TaskName $tName -TaskPath $tPath -User $tUser -Password $tPass 
