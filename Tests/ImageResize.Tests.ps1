$Verbose = @{}
if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
{
    $Verbose.add("Verbose",$True)
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module $PSScriptRoot\..\ImageResize -Force

#Integration test example
<# Describe "Get-SEObject PS$PSVersion Integrations tests" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'should get valid data' {
            $Output = Get-SEObject -Object sites
            $Output.count -gt 100 | Should be $True
            $Output.name -contains 'stack overflow'
        }
    }
} #>

Describe "Test proof Fails PS$PSVersion Integrations tests" {

    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'should get fail' {           
            $False | Should be $True
        }

        It 'should get pass' {           
            $True | Should be $True
        }
    }
}

#Unit test example
<# Describe "Get-SEObject PS$PSVersion Unit tests" {

    Mock -ModuleName PSStackExchange -CommandName Get-SEData { $Args }
    Context 'Strict mode' {

        Set-StrictMode -Version latest

        It 'should call Get-SEData' {
            $Output = Get-SEObject -Object sites
            Assert-MockCalled -CommandName Get-SEData -Scope It -ModuleName PSStackExchange
        }

        It 'should pass the right arguments to Get-SEData' {
            $Output = Get-SEObject -Object sites
            
            # Verify Maxresults
            $Output[3] | Should Be ([int]::MaxValue)

            # Verify IRMParams
            # Hard coding this expected value is delicate, will break if default URI or Version parameter values change
            $Output[1].Uri | Should Be 'https://api.stackexchange.com/2.2/sites'

            $Output[1].Body.Pagesize | Should Be 30
        }

    }
} #>
