$InputFile = "scope.txt"
$OutputFile = "up.txt"
$Threads = 100
$Timeout = 150

function Convert-IpToInt {
    param([string]$IpAddress)
    try {
        $ip = [System.Net.IPAddress]::Parse($IpAddress).GetAddressBytes()
        if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($ip) }
        return [System.BitConverter]::ToUInt32($ip, 0)
    } catch { return 0 }
}

function Convert-IntToIp {
    param([uint32]$IpInt)
    $bytes = [System.BitConverter]::GetBytes($IpInt)
    if ([System.BitConverter]::IsLittleEndian) { [Array]::Reverse($bytes) }
    return ([System.Net.IPAddress]::new($bytes)).IPAddressToString
}

function Get-IpRange {
    param([string]$Cidr)
    $ips = @()
    if ($Cidr -notmatch "/") { return ,$Cidr }

    try {
        $parts = $Cidr -split "/"
        $baseIp = $parts[0]
        $subnetMask = [int]$parts[1]
        $ipInt = Convert-IpToInt $baseIp
        $maskInt = [uint32]::MaxValue -shl (32 - $subnetMask)
        $networkInt = $ipInt -band $maskInt
        $broadcastInt = $networkInt -bor (-bnot $maskInt)
        $start = $networkInt + 1
        $end = $broadcastInt - 1
        for ($i = $start; $i -le $end; $i++) { $ips += Convert-IntToIp $i }
    } catch { }
    return $ips
}

if (-not (Test-Path $InputFile)) {
    Write-Error "scope.txt bulunamadi"
    exit
}

Set-Content -Path $OutputFile -Value $null -Encoding UTF8

$TargetList = @()
$RawScope = Get-Content $InputFile
foreach ($line in $RawScope) {
    if (-not [string]::IsNullOrWhiteSpace($line)) {
        $generatedIps = Get-IpRange $line.Trim()
        $TargetList += $generatedIps
    }
}

$TotalCount = $TargetList.Count
if ($TotalCount -eq 0) { exit }

$runspacePool = [runspacefactory]::CreateRunspacePool(1, $Threads)
$runspacePool.Open()
$jobs = @()

foreach ($ip in $TargetList) {
    $scriptBlock = {
        param($target, $wait)
        $ping = New-Object System.Net.NetworkInformation.Ping
        try {
            $result = $ping.Send($target, $wait)
            if ($result.Status -eq "Success") { return $target }
        } catch {}
        return $null
    }

    $ps = [powershell]::Create()
    $ps.RunspacePool = $runspacePool
    $ps.AddScript($scriptBlock).AddArgument($ip).AddArgument($Timeout) | Out-Null
    
    $jobs += New-Object PSObject -Property @{ Pipe = $ps; Result = $ps.BeginInvoke() }
}

$counter = 0

foreach ($job in $jobs) {
    $res = $job.Pipe.EndInvoke($job.Result)
    $job.Pipe.Dispose()
    $counter++
    
    if ($counter % ([math]::Ceiling($TotalCount / 100)) -eq 0) {
        $percent = [math]::Round(($counter / $TotalCount) * 100)
        Write-Progress -Activity "Ping Tarama" -Status "%$percent Tamamlandi" -PercentComplete $percent
    }

    if ($res) {
        Write-Host $res
        Add-Content -Path $OutputFile -Value $res -Encoding UTF8
    }
}

$runspacePool.Close()
$runspacePool.Dispose()