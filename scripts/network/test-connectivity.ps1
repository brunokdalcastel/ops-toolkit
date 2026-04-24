<#
.SYNOPSIS
Diagnóstico rápido de conectividade de rede para um host ou endereço IP.

.DESCRIPTION
Realiza três verificações independentes: resolução DNS, ping (ICMP) e traceroute
resumido. Retorna um objeto estruturado com os resultados. Falha em um bloco não
cancela as demais verificações. Compatível com PowerShell 5.1+.

.PARAMETER Target
Nome de host ou endereço IP a ser testado. Obrigatório.

.PARAMETER Count
Número de pacotes ICMP enviados no ping. Padrão: 4.

.EXAMPLE
.\test-connectivity.ps1 -Target google.com

Target       : google.com
DnsResolved  : True
IpAddress    : 142.250.219.206
PingSuccess  : True
AvgLatencyMs : 18
HopCount     : 7
TestedAt     : 2026-04-24 09:15:33

.EXAMPLE
.\test-connectivity.ps1 -Target 192.168.1.1 -Count 2

.NOTES
Autor: Bruno K. Dalcastel
Versão mínima: PowerShell 5.1
Requer: Permissão de rede para ICMP. tracert disponível no Windows.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Target,

    [Parameter()]
    [ValidateRange(1, 100)]
    [int]$Count = 4
)

function Invoke-Tracert {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TargetHost
    )
    & tracert -d -h 15 $TargetHost 2>&1
}

function Get-ConnectivityResult {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Target,

        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Count = 4
    )

    Set-StrictMode -Version Latest
    $ErrorActionPreference = 'Stop'

    $result = [PSCustomObject]@{
        Target       = $Target
        DnsResolved  = $false
        IpAddress    = $null
        PingSuccess  = $false
        AvgLatencyMs = $null
        HopCount     = $null
        TestedAt     = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }

    try {
        $dnsResult = Resolve-DnsName -Name $Target -ErrorAction Stop
        $ipEntry = $dnsResult | Where-Object { $_.Type -eq 'A' -or $_.Type -eq 'AAAA' } | Select-Object -First 1
        if ($null -ne $ipEntry) {
            $result.DnsResolved = $true
            $result.IpAddress = $ipEntry.IPAddress
        }
    }
    catch {
        Write-Verbose "DNS resolution failed for '$Target': $_"
    }

    try {
        $pingResults = Test-Connection -ComputerName $Target -Count $Count -ErrorAction Stop
        $result.PingSuccess = $true
        $avgLatency = ($pingResults | Measure-Object -Property ResponseTime -Average).Average
        $result.AvgLatencyMs = [math]::Round($avgLatency)
    }
    catch {
        Write-Verbose "Ping failed for '$Target': $_"
    }

    try {
        $tracertOutput = Invoke-Tracert -TargetHost $Target
        $hopLines = $tracertOutput | Where-Object { $_ -match '^\s+\d+\s' }
        $result.HopCount = ($hopLines | Measure-Object).Count
    }
    catch {
        Write-Verbose "Traceroute failed for '$Target': $_"
    }

    $result
}

Get-ConnectivityResult -Target $Target -Count $Count
