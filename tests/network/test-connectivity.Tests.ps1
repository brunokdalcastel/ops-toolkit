#Requires -Modules Pester

BeforeAll {
    # Dot-source the script to register Invoke-Tracert and Get-ConnectivityResult.
    # The entry point at the bottom runs once with a dummy target — errors are
    # expected and silenced here; all real assertions happen in the Contexts below.
    . "$PSScriptRoot/../../scripts/network/test-connectivity.ps1" `
        -Target 'noop-init' `
        -ErrorAction SilentlyContinue
}

Describe 'test-connectivity' {

    Context 'Happy path — DNS, ping and traceroute all succeed' {
        BeforeAll {
            Mock Resolve-DnsName {
                [PSCustomObject]@{ Type = 'A'; IPAddress = '8.8.8.8'; Name = 'google.com' }
            }
            Mock Test-Connection {
                @(
                    [PSCustomObject]@{ ResponseTime = 10 },
                    [PSCustomObject]@{ ResponseTime = 20 },
                    [PSCustomObject]@{ ResponseTime = 15 },
                    [PSCustomObject]@{ ResponseTime = 19 }
                )
            }
            Mock Invoke-Tracert {
                @(
                    '  1     2 ms     2 ms     1 ms  192.168.1.1',
                    '  2     8 ms     9 ms     8 ms  10.0.0.1',
                    '  3    18 ms    17 ms    18 ms  8.8.8.8'
                )
            }
            $script:r = Get-ConnectivityResult -Target 'google.com' -Count 4
        }

        It 'returns an object with exactly 7 properties' {
            $script:r.PSObject.Properties.Count | Should -Be 7
        }
        It 'Target matches the input' {
            $script:r.Target | Should -Be 'google.com'
        }
        It 'DnsResolved is True' {
            $script:r.DnsResolved | Should -Be $true
        }
        It 'IpAddress is populated' {
            $script:r.IpAddress | Should -Not -BeNullOrEmpty
        }
        It 'PingSuccess is True' {
            $script:r.PingSuccess | Should -Be $true
        }
        It 'AvgLatencyMs is a non-negative integer' {
            $script:r.AvgLatencyMs | Should -BeGreaterOrEqual 0
        }
        It 'HopCount equals number of hop lines returned' {
            $script:r.HopCount | Should -Be 3
        }
        It 'TestedAt matches yyyy-MM-dd HH:mm:ss format' {
            $script:r.TestedAt | Should -Match '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$'
        }
    }

    Context 'DNS resolution fails' {
        BeforeAll {
            Mock Resolve-DnsName { throw 'DNS resolution error' }
            Mock Test-Connection { throw 'Host not found' }
            Mock Invoke-Tracert { @() }
            $script:r = Get-ConnectivityResult -Target 'host-invalido-xyzxyz'
        }

        It 'DnsResolved is False' {
            $script:r.DnsResolved | Should -Be $false
        }
        It 'IpAddress is null' {
            $script:r.IpAddress | Should -BeNullOrEmpty
        }
        It 'PingSuccess is False' {
            $script:r.PingSuccess | Should -Be $false
        }
        It 'still returns a full object (other fields not null-ed out)' {
            $script:r.PSObject.Properties.Count | Should -Be 7
        }
    }

    Context 'Ping fails but DNS succeeds' {
        BeforeAll {
            Mock Resolve-DnsName {
                [PSCustomObject]@{ Type = 'A'; IPAddress = '1.2.3.4'; Name = 'unreachable.example.com' }
            }
            Mock Test-Connection { throw 'Request timed out' }
            Mock Invoke-Tracert { @() }
            $script:r = Get-ConnectivityResult -Target 'unreachable.example.com'
        }

        It 'DnsResolved is still True' {
            $script:r.DnsResolved | Should -Be $true
        }
        It 'IpAddress is populated' {
            $script:r.IpAddress | Should -Not -BeNullOrEmpty
        }
        It 'PingSuccess is False' {
            $script:r.PingSuccess | Should -Be $false
        }
        It 'AvgLatencyMs is null' {
            $script:r.AvgLatencyMs | Should -BeNullOrEmpty
        }
    }

    Context 'Parameter validation' {
        It 'throws when Target is an empty string' {
            { Get-ConnectivityResult -Target '' } | Should -Throw
        }
        It 'throws when Count is zero' {
            { Get-ConnectivityResult -Target 'example.com' -Count 0 } | Should -Throw
        }
        It 'throws when Count exceeds 100' {
            { Get-ConnectivityResult -Target 'example.com' -Count 101 } | Should -Throw
        }
    }
}
