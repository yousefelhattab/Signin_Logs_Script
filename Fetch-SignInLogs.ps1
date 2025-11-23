# ==============================================

# Fetch last 30 days of sign-in logs safely

# with readable TrustType, DeviceManaged (True/False), CorrelationId

# ==============================================
 
Write-Host "📦 Checking and loading Microsoft Graph modules..." -ForegroundColor Cyan

 
# Import required submodules

Import-Module Microsoft.Graph.Authentication -ErrorAction Stop

Import-Module Microsoft.Graph.Reports -ErrorAction Stop
 
# Temporarily bypass execution policy for this session

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
 
# --------------------------

# Connect to Microsoft Graph

# --------------------------

Write-Host "🔐 Connecting to Microsoft Graph..." -ForegroundColor Cyan

Connect-MgGraph -Scopes "AuditLog.Read.All","Directory.Read.All"
 
$ctx = Get-MgContext

if (-not $ctx) {

    Write-Host "❌ Failed to connect to Microsoft Graph." -ForegroundColor Red

    exit

}

Write-Host "✅ Connected as: $($ctx.Account) | Tenant: $($ctx.TenantId)" -ForegroundColor Green
 
# --------------------------

# TrustType Mapping

# --------------------------

$trustTypeMap = @{

    0 = "AzureAd"

    1 = "Workplace"

    2 = "ServerAd"

    3 = "Hybrid"

}
 
# --------------------------

# Fetch logs in 1-day chunks (last 30 days including today)

# --------------------------

Write-Host "`nFetching sign-in logs in 1-day chunks (last 30 days including today)..." -ForegroundColor Cyan
 
$allLogs = @()

$today = Get-Date
 
for ($i = 29; $i -ge 0; $i--) {

    $startDate = $today.AddDays(-$i).Date

    $endDate = $startDate.AddDays(1).AddSeconds(-1)
 
    $filter = "createdDateTime ge $($startDate.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')) and createdDateTime le $($endDate.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'))"
 
    Write-Host "Fetching logs from $startDate to $endDate ..." -ForegroundColor Yellow

    try {

        $chunk = Get-MgAuditLogSignIn -Filter $filter -All

        if ($chunk) { $allLogs += $chunk }

        Start-Sleep -Milliseconds 500  # reduce throttling

    } catch {

        $errMsg = $_.Exception.Message

        Write-Host ("⚠️ Error fetching logs for " + $startDate + ": " + $errMsg) -ForegroundColor Red

    }

}
 
Write-Host "`n✅ Total logs fetched: $($allLogs.Count)" -ForegroundColor Green
 
# --------------------------

# Extract key details

# --------------------------

$export = $allLogs | Select-Object `

    @{Name="Date"; Expression = { $_.CreatedDateTime }},

    @{Name="UPN"; Expression = { $_.UserPrincipalName }},

    @{Name="AppName"; Expression = { $_.AppDisplayName }},

    @{Name="IPAddress"; Expression = { $_.IpAddress }},

    @{Name="DeviceManaged"; Expression = { if ($_.DeviceDetail -ne $null -and $_.DeviceDetail.IsManaged -ne $null) { $_.DeviceDetail.IsManaged } else { $false } }},

    @{Name="TrustType"; Expression = {

        if ($_.DeviceDetail -and $_.DeviceDetail.TrustType -ne $null) {

            $val = $_.DeviceDetail.TrustType

            if ($val -match '^\d+$') { $trustTypeMap[[int]$val] } else { $val }

        } else {

            "NoDeviceDetail"

        }

    }},

    @{Name="CorrelationId"; Expression = { $_.CorrelationId }}
 
# --------------------------

# Show sample table

# --------------------------

Write-Host "`n✅ Sample of logs:`n" -ForegroundColor Green

$export | Select-Object -First 15 | Format-Table -AutoSize
 
# --------------------------

# Export to CSV

# --------------------------

$csvPath = Join-Path -Path (Get-Location) -ChildPath "SignInLogs_Last30Days.csv"

$export | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8 -UseCulture
 
Write-Host "`n✅ Done! Exported to: $csvPath" -ForegroundColor Green
 
