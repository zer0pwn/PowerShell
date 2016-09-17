<#
Author: William Foster
Purpose: Watch Service and Restart if it fails
#>

$ServiceName = "wuauserv"
$A = Get-Service $ServiceName

while($true)
{
  while ($A.Status -eq "Running") 
    {
     Write-Host -ForegroundColor Yellow $A.name "is running"
     Start-Sleep -s 5
     $A = get-service $ServiceName
     Clear-Host
    } 
  Write-Host -ForegroundColor Red $A.name "failed. Restarting now."
  $Date = Get-Date
  "$($A.name) failed at $($Date)" | Tee-Object C:\SrvcLogs\ConnectWiseService.txt -Append
  Start-Service $A.Name
  $A = get-service $ServiceName
} 
