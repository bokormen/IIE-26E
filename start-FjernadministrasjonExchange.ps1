# Det er denne funksjonen som brukes for å starte fjernadminsitrajsonen av exchange
Function Start-FjernadministrasjonExchange() {
    # Begynner med en blank konsoll
    Clear-Host
    # Prøver å tak i default verdier, om det fungerer bare hvis maskinen er medlem i et domene
    $defaultExchangeNavn = Get-ExchangeServerNavn
    $defaultDomeneKontrollerNavn = Get-DomeneKontrollerNavn
    $defaultPort = "5985"

    # Får innloggingsinformasjon
    $innlogginsInfo = Get-Credential

    # Får navnet på exchangeserveren det skal kobles til
    $exchangeNavn = Get-FqdnExchange $defaultExchangeNavn

    # Får navnet på domenekontrolleren det skal kobles til
    $domeneKontrollerNavn = Get-FqdnDomeneKontroller $defaultDomeneKontrollerNavn

    # Får portnummeret som brukes av domenekontrolleren
    $port = Get-FjernadministreringsPort $defaultPort

    # Setter innstillinger for tilkoblingen til exchange serveren
    $valg = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true


    # Oppretter en tilkobling til exchange serveren
    $exchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://$exchangeNavn/Powershell/ -Credential $innlogginsInfo -AllowRedirection -SessionOption $valg -Authentication Basic

    # Oppretter en tilkobling til domenekontrolleren
    $domeneKontrollerSession = New-PSSession -ComputerName $domeneKontrollerNavn -Port $port -Credential $innlogginsInfo

    # Henter modulen ActiveDirectory til sessjonen til domenekontrolleren, legger utskriften i en egen variabel, da jeg ikke er intresert i å se den på skjermen
    $v1 = Invoke-Command -Session $domeneKontrollerSession {Import-Module -Name ActiveDirectory}

    # Importerer cmdlet'ene som finnes i sessjonen tilhørende exchangeserveren, legger utskriften i en egen variabel, da jeg ikke er intresert i å se den på skjermen
    $v2 = Import-PSSession $exchangeSession -WarningAction silentlyContinue

    # Importerer cmdlet'ene i modulen ActiveDirectory fra sessjonen tilhørende domenekontrolleren, legger utskriften i en egen variabel, da jeg ikke er intresert i å se den på skjermen
    $v3 = Import-PSSession $domeneKontrollerSession -Module ActiveDirectory -WarningAction silentlyContinue

    
    # Hvis det oppstod tilkoblingsproblemmer er variablene $v2 og $v3 tomme, så da skrives det ut en feilmelding. Hvis alt har gått greit, så startes fjernadministrajsonen av exchangeserveren
    if(($v2 -eq $null) -or ($v3 -eq $null)){
        # Det skrives ut en feilmelding
        Write-Host "Noe gikk galt ved tilkoblingen til serverene, sjekk at du har skrevet alt riktig, og prøv igjen`nhvis det fortsatt ikke fungerer, kontakt systemansvarlig" -ForegroundColor Red
    }else {
        # Fjernadministrasjonen av exchange starter
        Start-ExchangeAdminstrasjon
    }


    # Når avministrasjonen er ferdig, så fjernes sesjonene som har vært brukt i fjernavministrasjonen
    $v4 = Remove-PSSession $exchangeSession
    $v5 = Remove-PSSession $domeneKontrollerSession
}