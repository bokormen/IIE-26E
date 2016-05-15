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

function Get-ExchangeServerNavn() {
    $exchangeServer = ""
    if ((gwmi win32_computersystem).partofdomain -eq $true) {
        $exchangeServer = Get-ExchangeServerInSite | select -first 1 | Select FQDN | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String
        $exchangeServer = $exchangeServer.Replace("`n","").Replace("`r","").Trim()
    }
    return $exchangeServer
}