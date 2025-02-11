<#
.SYNOPSIS
    Restarts GlobalProtect by stopping the service/process and then restarting it.

.DESCRIPTION
    This script stops the GlobalProtect (PanGPA) process and service,
    then restarts them. It supports a -restart switch to automatically restart after a short delay.
    Use this script to resolve issues with GlobalProtect connectivity.

.PARAMETER restart
    A switch that, when specified, will automatically restart GlobalProtect after a 5-second delay.
    If omitted, the script will prompt for user input before restarting.

.EXAMPLE
    .\gp.ps1 -restart
    Automatically restarts GlobalProtect after stopping it.

.EXAMPLE
    .\gp.ps1
    Stops GlobalProtect and then waits for the user to press ENTER before restarting.

.NOTES
    Author: Conrad Culling
    Version: 1.0.0
    Date: 2025-02-11

.LINK
    https://github.com/notbadrabbt
#>

param (
    [switch]$restart,
    [switch]$help
)

# If help flag is set, display help information and exit.
if ($help) {
    $helpText = @"
Usage: .\gp.ps1 [-restart] [-help]

    -restart    Automatically restarts GlobalProtect after a 5-second delay.
                If omitted, the script will wait for user input before restarting.
                
    -help       Displays this help message.
                
Description:
    This script stops the GlobalProtect (PanGPA) process and service,
    then restarts them. It also performs a check for admin privileges
    and logs its actions to C:\Temp\Logs\gp_log.txt.
"@
    Write-Output $helpText
    exit 0
}

$logFilePath = "C:\Temp\Logs\gp_log.txt"

$logDir = Split-Path $logFilePath
if (-not (Test-Path $logDir)) {
    New-Item -Path $logDir -ItemType Directory | Out-Null
}

[Console]::CursorVisible = $false

# Write Log
function Write-Log {
    param(
        [string]$message,
        [switch]$quiet
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFilePath -Value "$timestamp - $message"
    
    if (-not $quiet) {
        Write-Output $message
    }
}

function Show-Progress {
    param(
        [string]$baseMessage
    )
    
    $steps = 5
    for ($i = 1; $i -le $steps; $i++) {
        $percent = ($i / $steps) * 100
        $status = "$baseMessage" + " " + ("." * $i)
        Write-Progress -Activity $baseMessage -Status $status -PercentComplete $percent
        Start-Sleep -Milliseconds 500
    }
    
    # Clear the progress bar once complete.
    Write-Progress -Activity $baseMessage -Status "Completed" -PercentComplete 100 -Completed
}


# Admin privilege check function
function Ensure-Admin {
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Write-Log "Current User: $currentUser"
    
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Log "User not running as admin. Attempting to elevate privileges..."
        try {
            $arguments = "-File `"$PSCommandPath`""
            if ($restart) {
                $arguments += " -restart"
            }
            
            $startTime = Get-Date
            Start-Process powershell.exe -ArgumentList $arguments -Verb RunAs -ErrorAction Stop
            Write-Log "Privilege elevation initiated. Exiting current session."
            [Console]::CursorVisible = $true
            exit
        } catch {
            $duration = (New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds
            $message = if ($duration -ge 120) {
                "Privilege elevation failed due to timeout."
            } else {
                "Privilege elevation canceled by the user."
            }
            Write-Log $message
            Write-Output $message
            [Console]::CursorVisible = $true
            exit
        }
    }
}

# Call privilege check function
Ensure-Admin

# Stop GlobalProtect (PanGP) Process and Service
Show-Progress "Stopping GlobalProtect."
$panGPAProcess = Get-Process -Name pangpa -ErrorAction SilentlyContinue
if ($panGPAProcess) {
    Stop-Process -Id $panGPAProcess.Id -Force
    Write-Log "SUCCESS: PanGPA.exe with PID $($panGPAProcess.Id) has been terminated."
} else {
    Write-Log "PanGPA.exe process not found."
}
Stop-Service -Name PanGPS -Force -ErrorAction SilentlyContinue
Set-Service -Name PanGPS -StartupType Manual
Write-Log "GlobalProtect stopped!"

# Restart Logic
if ($restart) {
    Write-Log "Restarting GlobalProtect in 5 seconds..."
    Start-Sleep -Seconds 5
} else {
    Write-Log "Waiting for user input to restart GlobalProtect..." -quiet
    Write-Output "Press ENTER to restart GlobalProtect..."
    Read-Host | Out-Null
    Clear-Host
}

# Start GlobalProtect (PanGP) Service
[Console]::CursorVisible = $false
Show-Progress "Restarting GlobalProtect."
Start-Service -Name PanGPS

# Check if PanGPA.exe exists before attempting to start it
if (-Not (Test-Path "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe")) {
    Write-Log "ERROR: PanGPA.exe not found at the expected path."
    exit 1
}

$proc = Start-Process -FilePath "C:\Program Files\Palo Alto Networks\GlobalProtect\PanGPA.exe" -PassThru
Set-Service -Name PanGPS -StartupType Automatic
Write-Log "GlobalProtect restarted. PanGPA.exe with PID $($proc.Id) started."
Start-Sleep -Seconds 2
Write-Output "GlobalProtect restarted succesfully."
Start-Sleep -Seconds 3
[Console]::CursorVisible = $true