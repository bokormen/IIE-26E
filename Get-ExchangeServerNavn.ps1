# Dette er en kodesnutt som er funnet på nettet, funksjonen finner en liste over exchange servere i domenet
# Kilde: http://mikepfeiffer.net/2010/04/find-exchange-servers-in-the-local-active-directory-site-using-powershell/
Function Get-ExchangeServerInSite {
    $ADSite = [System.DirectoryServices.ActiveDirectory.ActiveDirectorySite]
    $siteDN = $ADSite::GetComputerSite().GetDirectoryEntry().distinguishedName
    $configNC=([ADSI]"LDAP://RootDse").configurationNamingContext
    $search = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$configNC")
    $objectClass = "objectClass=msExchExchangeServer"
    #$version = "versionNumber>=1937801568"
    $site = "msExchServerSite=$siteDN"
    #$search.Filter = "(&($objectClass)($version)($site))"
    $search.Filter = "(&($objectClass)($site))"
    $search.PageSize=1000
    [void] $search.PropertiesToLoad.Add("name")
    [void] $search.PropertiesToLoad.Add("msexchcurrentserverroles")
    [void] $search.PropertiesToLoad.Add("networkaddress")
    $search.FindAll() | %{
        New-Object PSObject -Property @{
            Name = $_.Properties.name[0]
            FQDN = $_.Properties.networkaddress |
                %{if ($_ -match "ncacn_ip_tcp") {$_.split(":")[1]}}
            Roles = $_.Properties.msexchcurrentserverroles[0]
        }
    }
}

# Denne funksjonen tester om maskinen koden kjøres på er medlem i et domene, hvis den er det, så søkes det etter exchange servere, og fqdn på en av de eventuelle exchangeserveren returneres
function Get-ExchangeServerNavn() {
    # Variablen som skal returneres
    $exchangeServer = ""
    # Tester om maskinen er medlemm i et domene
    if ((gwmi win32_computersystem).partofdomain -eq $true) {
        # Får fqdn på en exchangeserver i domenet
        $exchangeServer = (Get-ExchangeServerInSite | select -first 1 | Select FQDN | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()
    }
    # returnrer et eventuelt fqdn om det ble funnet en exchangeserver, hvis ikke er stringen tom
    return $exchangeServer
}

# Denne funksjonen tester om maskinen koden kjøres på er medlem i et domene, hvis den er det, så søkes det etter domenekontrollere, og fqdn på en av de eventuelle domenekontrollerene returneres
function Get-DomeneKontrollerNavn() {
    # Variablen som skal returneres
    $domeneKontroller = ""
    # Tester om maskinen er medlemm i et domene
    if ((gwmi win32_computersystem).partofdomain -eq $true) {
        # Får fqdn på en domenekontroller i domenet
        $domeneKontroller = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().DomainControllers | select Name | Select -First 1 | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()
    }
    # Returnerer et eventuelt fqdn på en domenekontroller
    Return $domeneKontroller
}