# System Monitor Client - PowerShell Script
# Collects system metrics and sends to Flask server

param(
    [string]$ServerUrl = "http://localhost:5000"
)

function Get-SystemMetrics {
    # Get CPU usage
    $cpu = Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average | Select-Object -ExpandProperty Average
    
    # Get Memory usage
    $memory = Get-WmiObject -Class Win32_OperatingSystem
    $totalMemory = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
    $freeMemory = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
    $memoryUsage = [math]::Round(($totalMemory - $freeMemory) / $totalMemory * 100, 2)
    
    # Get Disk usage
    $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'"
    $diskUsage = [math]::Round(($disk.Size - $disk.FreeSpace) / $disk.Size * 100, 2)
    
    # Get additional system information
    $userName = $env:USERNAME
    $computerName = $env:COMPUTERNAME
    $os = (Get-WmiObject -Class Win32_OperatingSystem).Caption
    $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Ethernet*" | Where-Object {$_.AddressState -eq "Preferred"}).IPAddress
    if (-not $ipAddress) {
        $ipAddress = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*" | Where-Object {$_.AddressState -eq "Preferred"}).IPAddress
    }
    
    # Get current timestamp
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

    return @{
        cpu_usage = $cpu
        memory_usage = $memoryUsage
        disk_usage = $diskUsage
        user_name = $userName
        computer_name = $computerName
        os = $os
        ip_address = $ipAddress
        timestamp = $timestamp
    }
}

function Send-Metrics($metrics) {
    try {
        $body = @{
            cpu_usage = $metrics.cpu_usage
            memory_usage = $metrics.memory_usage
            disk_usage = $metrics.disk_usage
            user_name = $metrics.user_name
            computer_name = $metrics.computer_name
            os = $metrics.os
            ip_address = $metrics.ip_address
            timestamp = $metrics.timestamp
        }
        
        $jsonBody = $body | ConvertTo-Json
        $response = Invoke-RestMethod -Uri "$ServerUrl/stats" -Method Post -Body $jsonBody -ContentType "application/json"
        
        Write-Host "Metrics sent successfully: $($response.message)" -ForegroundColor Green
    }
    catch {
        Write-Host "Error sending metrics: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Main execution
Write-Host "System Monitor Client - Collecting metrics..." -ForegroundColor Yellow

$metrics = Get-SystemMetrics
Write-Host "CPU Usage: $($metrics.cpu_usage)%" -ForegroundColor Cyan
Write-Host "Memory Usage: $($metrics.memory_usage)%" -ForegroundColor Cyan
Write-Host "Disk Usage: $($metrics.disk_usage)%" -ForegroundColor Cyan
Write-Host "User Name: $($metrics.user_name)" -ForegroundColor Cyan
Write-Host "Computer Name: $($metrics.computer_name)" -ForegroundColor Cyan
Write-Host "OS: $($metrics.os)" -ForegroundColor Cyan
Write-Host "IP Address: $($metrics.ip_address)" -ForegroundColor Cyan

Send-Metrics $metrics
