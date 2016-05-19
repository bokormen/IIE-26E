# Denne funksjonen kan brukes til � starte en tilkobling til exchange hvis man �nsker � kj�re kommadnoer som ikke er dekket av de cmdlet'ene som f�lger med denne modulen
function Start-FjerntilkoblingExchange() {
    # Begynner med en blank konsoll
    Clear-Host
    # Pr�ver � tak i default verdier, om det fungerer bare hvis maskinen er medlem i et domene
    $defaultExchangeNavn = Get-ExchangeServerNavn
    $defaultDomeneKontrollerNavn = Get-DomeneKontrollerNavn
    $defaultPort = "5985"

    # F�r innloggingsinformasjon
    $innlogginsInfo = Get-Credential

    # F�r navnet p� exchangeserveren det skal kobles til
    $exchangeNavn = Get-FqdnExchange $defaultExchangeNavn

    # F�r navnet p� domenekontrolleren det skal kobles til
    $domeneKontrollerNavn = Get-FqdnDomeneKontroller $defaultDomeneKontrollerNavn

    # F�r portnummeret som brukes av domenekontrolleren
    $port = Get-FjernadministreringsPort $defaultPort

    # Setter innstillinger for tilkoblingen til exchange serveren
    $valg = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true


    # Oppretter en tilkobling til exchange serveren
    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://$exchangeNavn/Powershell/ -Credential $innlogginsInfo -AllowRedirection -SessionOption $valg -Authentication Basic

    # Oppretter en tilkobling til domenekontrolleren
    $domeneKontrollerSession = New-PSSession -ComputerName $domeneKontrollerNavn -Port $port -Credential $innlogginsInfo

    # Henter modulen ActiveDirectory til sessjonen til domenekontrolleren, legger utskriften i en egen variabel, da jeg ikke er intresert i � se den p� skjermen
    $v1 = Invoke-Command -Session $domeneKontrollerSession {Import-Module -Name ActiveDirectory}

    # Importerer cmdlet'ene som finnes i sessjonen tilh�rende exchangeserveren, legger utskriften i en egen variabel, da jeg ikke er intresert i � se den p� skjermen
    $v2 = Import-PSSession $exchangeSession -WarningAction silentlyContinue

    # Importerer cmdlet'ene i modulen ActiveDirectory fra sessjonen tilh�rende domenekontrolleren, legger utskriften i en egen variabel, da jeg ikke er intresert i � se den p� skjermen
    $v3 = Import-PSSession $domeneKontrollerSession -Module ActiveDirectory -WarningAction silentlyContinue

}