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

# Denne funksjonen skriver ut hovedmenyen frem til noen velger avlsutt i menyen
function Start-ExchangeAdminstrasjon() {
    # While løkken kjører frem til det kjøres en break med taggen exchangeAdministrasjon
    :exchangeAdministrasjon while ($true) {
        # While løkken kjører frem til det kjøres en break med taggen fortsettAdministrering
        # Denne er her slik at en bruker kan avslutte en uproduktiv leting etter en bruker blant annet, uten å måtte starte funksjonen som starter fjernadminstrering av exchange på nytt
        :fortsettAdministrering while($true) {
            # Åpner hovedmenyen
            Get-Hovedmeny
        }
    }
}

# Denne funksjonen spør brukeren etter et fqdn på en exchange server, den foreslår å bruke verdien som blir sendt som et parameter
function Get-FqdnExchange() {
    # Tar inn en verdi som foreslås som verdien som skal returneres
    param([string]$defaultExchangeNavn)

    # Spør brukeren etter et fqdn på maskinen han øsnker å koble til
    $exchangeNavn = Read-Host "Skriv inn FQDN på Exchangeserveren som skal administreres, om det er et navn i [] som stemmer, trykk enter [$defaultExchangeNavn]"
    
    # Sjekker om verdien brukeren skrev inn er tom, hvis den er det, så settes verdien til den foreslåtte verdien, gitt at ikke den og er tom
    if(($exchangeNavn -eq "") -and ($defaultExchangeNavn -ne "")) {
        $exchangeNavn = $defaultExchangeNavn
    }

    # Hvis verdien er tom når den kommer her, så blir man bedt om å skrive inn en verdi, da skriptet ikke har klart å lokalisere en exchange server selv
    if ($exchangeNavn -eq "") {
        Write-Host "Skriptet har ikke klart å foreslå et navn på en Exchange server for deg, så du må skrive inn et FQDN på Exchange serveren du ønsker å administrere" -ForegroundColor Yellow
    }

    # Tar utganspunkt i at navnet brukeren har gitt, er skrevet korrekt
    $exchangeNavneSjekk = "y"

    # denne do while løkken kjører så lenge brukeren ikke er fornøyd med den verdien som er gitt
    do {
        # Så lenge fqdn navnet brukeren gir, er tomt, så vil denne løkken kjøre, og ber brukeren om å skrive inn et fqdn på exchange serveren som skal adminsitreres
        while($exchangeNavn -eq "") {
            $exchangeNavn = Read-Host "Skriv inn et FQDN på Exchange serveren du ønsker å administrere, du kan ikke la det være blankt"
        }

        # Spør brukeren om inputen som er gitt er riktig
        $exchangeNavneSjekk = (Read-Host "Stemmer det at det er $exchangeNavn som er Exchange serveren du ønsker å administrere? [y/n]").Trim().ToLower()

        # Hvis inputen som er registrert ikke er riktig, så tømmes stringen som inneholder navnet på exchangeserveren, slik at funksjonen går inn i whileløkken ovenfor igjen når den returnerer der
        if ($exchangeNavneSjekk -ne "y") {
            $exchangeNavn = ""
        }
    # Sjekker om fqdn som er gitt, er det som brukeren ønsker å bruke    
    } while ($exchangeNavneSjekk -ne "y")

    # returnerer fqdn på en exchange server
    return $exchangeNavn
}

# Denne funksjonen spør brukeren etter et fqdn på en domenekontroller, den foreslår å bruke verdien som blir sendt som et parameter
function Get-FqdnDomeneKontroller() {
    # Tar inn en verdi som foreslås som verdien som skal returneres
    param([string]$defaultDomeneKontrollerNavn)

    # Spør brukeren etter et fqdn på maskinen han øsnker å koble til
    $domeneKontrollerNavn = Read-Host "Skriv inn FQDN på domene kontrolleren som skal administreres, om det er et navn i [] som stemmer, trykk enter [$defaultDomeneKontrollerNavn]"

    # Sjekker om verdien brukeren skrev inn er tom, hvis den er det, så settes verdien til den foreslåtte verdien, gitt at ikke den og er tom
    if(($domeneKontrollerNavn -eq "") -and ($defaultDomeneKontrollerNavn -ne "")) {
        $domeneKontrollerNavn = $defaultDomeneKontrollerNavn
    }

    # Hvis verdien er tom når den kommer her, så blir man bedt om å skrive inn en verdi, da skriptet ikke har klart å lokalisere en domenekontroller selv
    if ($domeneKontrollerNavn -eq "") {
        Write-Host "Skriptet har ikke klart å foreslå et navn på en domene kontroller for deg, så du må skrive inn et FQDN på domene kontrolleren du ønsker å administrere" -ForegroundColor Yellow
    }

    # Tar utganspunkt i at navnet brukeren har gitt, er skrevet korrekt
    $domeneKontrollerNavneSjekk = "y"

    # denne do while løkken kjører så lenge brukeren ikke er fornøyd med den verdien som er gitt
    do {

        # Så lenge fqdn navnet brukeren gir, er tomt, så vil denne løkken kjøre, og ber brukeren om å skrive inn et fqdn på domenekontrolleren det skal kobles til
        while($domeneKontrollerNavn -eq "") {
            $domeneKontrollerNavn = Read-Host "Skriv inn et FQDN på domene kontrolleren du ønsker å administrere, du kan ikke la det være blankt"
        }

        # Spør brukeren om inputen som er gitt er riktig
        $domeneKontrollerNavneSjekk = (Read-Host "Stemmer det at det er $domeneKontrollerNavn som er domene kontrolleren du ønsker å administrere? [y/n]").Trim().ToLower()

        # Hvis inputen som er registrert ikke er riktig, så tømmes stringen som inneholder navnet på en domenekontroller, slik at funksjonen går inn i whileløkken ovenfor igjen når den returnerer der
        if ($domeneKontrollerNavneSjekk -ne "y") {
            $domeneKontrollerNavn = ""
        }
        
    # Sjekker om fqdn som er gitt, er det som brukeren ønsker å bruke    
    } while ($domeneKontrollerNavneSjekk -ne "y")

    # returnerer fqdn på en domenekontroller
    return $domeneKontrollerNavn
}

# denne funksjonen spør brukeren etter porten som brukes for å koble til domenekontrollren, den foreslår standarporten
function Get-FjernadministreringsPort() {
    # paramteret skal være en tallverdi som er standarporten for fjernstilkobling til powershell
    param([string]$defaultPort)

    # Spør brukeren etter et protnummer som skal brukes, foreslår å bruke standardporten
    $port = Read-Host "Skriv inn portnummer til domene kontrolleren som skal administreres, om portnummeret i [] stemmer, trykk enter [$defaultPort]"

    # Hvis inpurten fra brukeren er tom, så brukes standarporten
    if($port -eq "") {
        $port = $defaultPort
    }
    # Variablen som brukes for å sjekke om brukeren mener valget han har gjort er rett
    $portSjekk = "n"

    # Denne løkken kjører frem til brukeren er fornøyd med det valget som er gjort
    do {
        # Denne while løkken kjører til inputen som blir gitt er et tall
        While(![bool]($port -as [int] -is [int])) {
            Write-Host "Portnummeret må være et tall" -ForegroundColor Yellow
            $port = Read-Host "Skriv inn portnummer til domene kontrolleren som skal administreres, om portnummeret i [] stemmer, trykk enter [$defaultPort]"
            # Hvis inputen er tom, så settes verdien til standerverdien
            if($port -eq "") {
                $port = $defaultPort
            }
        }
        # Sjekker om brukeren mener inputen som er gitt er korrekt
        $portSjekk = (Read-Host "Stemmer det at det er port:$port som brukes for å kontakte domene kontrolleren du ønsker å administrere? [y/n]").Trim().ToLower()

        # Hvis ikke brukeren er fornøyd, så setter portnummeret til en verdie som sørger for at den går inn i whileløkken ovenfor
        if ($portSjekk -ne "y") {
            $port = "i"
        }
    # Sjekker om brukeren er fornøyd med den verdien han har gitt
    } while($portSjekk -ne "y")

    # Returnerer et portnummer
    return $port

}

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

# Denne funksjoenne gir en bruker rettighet(er) til en annen brukerkonto
function Add-Brukerrettigheter() {
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til brukeren som skal få rettigheter
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal få rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til kontoen brukeren skal få rettigheter til
    $konto = Get-Epostkonto "Skriv inn navnet på kontoen som $bruker skal få rettighet til"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host

    # Sender alias til bruker som skal få rettighet, og til kontoen det skal bli gitt rettighet til
    Add-Rettigheter $bruker $konto
}

# Funksjonen gir en bruker rettighet(er) til en annen postboks
function Add-Rettigheter() {
    
    # Funksjonen tar inn to stringer, som hver er et alias som beksriver en bruker og en konto
    param([string]$bruker,[string]$konto)

    # Får tak i en liste over hvilke rettigheter brukeren alt har, som jeg legger inn i en arraylist for å gjøre det enklere å bearbeide
    $rettigheter = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Liste over hvilke rettigheter brukeren kan bli gitt, inkluderer et valg om å ikke gjøre noen endringer
    $tilgjengeligeRettigher = [System.Collections.ArrayList]@("FullAccess","SendAs","SendOnBehalfOf","Ønsker ikke å legge til en ny rettighet")

    # Trimmer listen over hvilke rettigheter som kan bli gitt, slik at den ikke inneholder rettigheter brukeren alt har
    foreach ($rettighet in $rettigheter) {
        $tilgjengeligeRettigher.Remove($rettighet) | Out-Null
    }

    
    # Skriver ut en liste over hvilke rettigheter brukeren alt har til kontoen
    if($rettigheter.Count -gt 0) {
        Write-Host "Rettigheter $bruker allerede har til kontoen $konto :"
        foreach($rettighet in $rettigheter) {
            Write-Host "    - $rettighet"
        }
    }

    # Lister ut hvilke rettigheter brukeren kan tildeles kontoen, samt en tallverdi foran rettighene som representerer rettigheten når den senre kan bli valgt
    # Hvis ikke det er flere rettigheter å tildele, så skrives det ut en beskjed om det
    if($tilgjengeligeRettigher.Count -gt 1) {
        # Her skrives listen over tilgjendelige rettigheter ut
        Write-Host "`n`nRettigheter $bruker kan bli gitt til kontoen $konto :"
        $i = 0
        foreach($rettighet in $tilgjengeligeRettigher) {
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        # Her skrives beskjeden om at det ikke er mulig å tildele flere rettigheter ut
        Write-Host "`n`n$bruker kan ikke bli gitt flere rettigheter til kontoen $konto `n"
        Pause
        # Her går skriptet ut av denne funksjonen, da det ikke er mer å gjøre
        Return
    }

    # Variabel som brukes for å kontrollere at alle valgene som skrives inn er gyldige valg
    $erRetteVerdier = [boolean]$true
    # String som inneholder de nye rettighetene som skal legges til, adskilt med komma
    $nyeRettigheter = ""

    # Denne do while løkka sjekket at det som skrives inn er gyldige verdier
    do {
        # Valgene som er gjort, er gyldige til det motsatte er bevist
        $erRetteVerdier = [boolean]$true

        # Ber brukeren skive inn hvilke rettigheter brukeren ønsker å gi, det kan legges til flere rettigheter, men da må de adskilles med komma
        $nyeRettigheter = Read-Host "`n`nSkriv inn nummeret som står før rettigheten du ønsker å gi $bruker til kontoen $konto`nOm du ønsker å tildele flere rettigheter, så kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene på rettigheten(e) du ønsker å gi"

        # Fjerner "whitespace"
        $nyeRettigheter.Trim(" ") | Out-Null

        # legger valgene inn i en array
        $nyeRettigheter = [System.Collections.ArrayList]$nyeRettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        # fjerner alle doble valg
        $temp = $nyeRettigheter | Get-Unique

        # sjekker at brukeren har gitt en verdi, og ikke bare har trykket enter uten å skrive inn noe
        if($nyeRettigheter.Count -eq 0) {
            # Skriver ut en beskjed om at tomt valg ikek er en mulighet, og setter verdien $erRetteVerdier til false for å indikere at vi ikke har fått noe som kan jobbes videre med og det må spørres på nytt
            Write-Host "Du kan ikke bare trykke på enter, du måt gjøre et valg, om du øsnker å avslutte, kan du skrive inn" ($tilgjengeligeRettigher.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false
        # Sjekker at en rettighet ikke er skrevet inn to ganger, har valgt å ikke tillate det, hvis et valg ikke er oppgitt to ganger, så sjekker jeg at alle valgene er tall
        } elseif($temp.count -eq $nyeRettigheter.Count) {
            
            # Går igjennom alle valgene og sjekket at det er tall som tilsvarer menyelementene
            foreach($valg in $nyeRettigheter) {
                # Sjekker om valget er er tall
                if(![boolean]($valg -as [int] -is [int])) {
                    # skriver ut en advarsel om at valget ikke er et tall, og setter verdien $erRetteVerdier til false
                    Write-Host "$valg er ikke et tall, du må liste opp rettighetene du ønsker å tildele på nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                    Break

                } else {
                    # caster valget til int
                    $valg = [int]$valg

                    # Sjekket om valget er innenfor de verdiene som menyen inneholder
                    if(($valg -lt 0) -or ($valg -ge $tilgjengeligeRettigher.Count)) {
                        # Skriver ut en advarsel om at valget ikke er innenfor de verdiene som menyen inneholder, og setter verdien $erRetteVerdier til false
                        Write-Host "$valg er ikke er tall mellom 0 og" ($tilgjengeligeRettigher.Count-1) ", du må skrive inn valgene på nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break

                    # Sjekker om valget som er gjort er å ikke legge til flere rettigheter, samtidig som det er gjort flere andre valg også, da det ikke gir mening
                    } elseif (($valg -eq ($tilgjengeligeRettigher.Count-1)) -and ($nyeRettigheter.Count -gt 1)) {
                        # Skriver ut en advarsel om at valget ikke er logisk, og setter verdien $erRetteVerdier til false
                        Write-Host "Du kan ikke legge til rettigheter, og samtidig gjøre valget:" $tilgjengeligeRettigher[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($tilgjengeligeRettigher.Count-2) "separert med komma, eller bare" ($tilgjengeligeRettigher.Count-1)  -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break

                    }
                }
            }
        } else {
            # Gir beskjed om at det ikke er lov å liste opp en verdi to ganger, og setter $erRetteVerdier til false
            Write-Host "Du kan kunn skrive inn unike verdier, separert med komma, du kan ikke liste opp en rettighet to ganger" -ForegroundColor Red
            $erRetteVerdier = $false

        }
    # sjekker om det er riktige verdier som er skrevet inn, hvis ikke, så går løkken gjennom prosessen med å få valgene fra brukeren på nytt
    } while (!$erRetteVerdier)

    # Hvis valget er å ikke legge til flere rettigher, så avlsuttes funksjonen
    if($nyeRettigheter[0] -eq ($tilgjengeligeRettigher.Count -1)) {
        return
    }
    
    # et par av funksjonene for å legge til rettigheter tar ikke imot alias som en gyldig verdi, så må anskaffe DistinguishedName for kontoen det skal legges til rettighet på
    $kontoNavn = (Get-Mailbox $konto –ErrorAction SilentlyContinue | Select DistinguishedName | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()

    # For hvert valg som er gjort, legges det til en rettighet
    foreach($valg in $nyeRettigheter) {
        # Switchen gis beskjed om hvilken rettighet som sakl legges til, og kjører koden som sørger for at den rettigheten blir gitt
        switch ($tilgjengeligeRettigher[[int]$valg]) {
            "FullAccess"{
                Add-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights "FullAccess" | Out-Null
            }
            "SendAs"{
                Add-ADPermission -Identity $kontoNavn -User $bruker -Extendedrights "Send-As" | Out-Null
            }
            "SendOnBehalfOf"{
                # Må bruke scriptblock for at berdien for $bruker skal sendes videre som aliaset til brukeren, og ikke som en string "$bruker"
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Add=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                # Det skal ikke være mulig å havne her, men skulle det ha skjedd en feil, så bør systemansvarlig gies beskjed slik at logiken kan rettes på
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $tilgjengeligeRettigher[[int]$valg] "ble forsøkt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    # Får tak i listen over hvilke rettigheter brukeren nå har til kontoen
    $rettigheter = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Fjerner tildigere utskrift fra konsollen for at det skal se mer ryddig ut
    Clear-Host

    # Gir beskjed om at handlingene ser ut til å ha vært vellykkede, og lister ut de rettighetene brukeren nå har til kontoen
    Write-Host "Rettigheter er blitt lagt til, rettighetene $bruker nå har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheter) {
        Write-Host "    - $rettighet"
    }
    # Pauser koden slik at brukeren får med seg siste beskjed
    Pause
}

# Denne funksjonen sletter en bruker fra både domenet og e-post serveren
function Delete-Brukerkonto() {
        # Får tak i brukeren som skal slettes
        $bruker = Get-Epostkonto "Skriv inn navnet på brukeren hvor epostkontoen og domenebrukeren skal slettes (brukeren må ha en e-postkonto aktivert)"
        
        # Sletter brukeren
        Remove-ADUser $bruker

        #Sjekker om det forsatt eksisterer en brukerkonto tilhørende brukeren
        if (((Get-ADUser $bruker -ErrorAction SilentlyContinue) -eq $null) -and ((Get-Mailbox $bruker -ErrorAction SilentlyContinue) -eq $null)) {
            # Gir beskjed om at brukeren ikke lengre eksisterer
            Write-Host "$bruker's e-postkonto og domenebruker er nå slettet" -ForegroundColor Green
        } else {
            # Gir beskjed om at noe ser ut til å ha gått galt
            Write-Host "$bruker's e-postkonto eller domenebruker ser fortsatt ut til å eksistere" -ForegroundColor Red
        }
}

# Denne funksjonen fjerner e-postkontoen til en bruker
function Delete-Epostkonto() {
    # Får tak i brukeren det gjelder
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren hvor epostkontoen skal slettes (brukeren må ha en e-postkonto aktivert)"
    
    # Fjerner e-postkontoen
    Disable-Mailbox $bruker

    # Kontrollerer om det fortsatt finnes en e-postkonto tilhørende brukeren
    if((Get-Mailbox $bruker -ErrorAction SilentlyContinue) -eq $null) {
        # Gir beskjed om at det ikke lengre finnes en e-postkonto tilhørende brukeren
        Write-Host "$bruker's e-postkonto er nå slettet" -ForegroundColor Green
    } else {
        # Gir beskjed om at noe set ut til å ha gått galt
        Write-Host "$bruker's e-postkonto ser fortsatt ut til å eksistere" -ForegroundColor Red
    }
    
}

# Denne funskjonen returnerer aliaset til en bruker med postboks
function Get-Epostkonto() {
    # Tar inn en string som beskriver hvilken bruker programvaren spør etter
    param([string]$spoereTekst)

    # Oppretter de variablene som skal brukes senre i koden
    $bruker = ""
    $oenskerAaFortsette = "n"
    $riktigBruker = ""

    # Denne do while løkken kjører så lenge brukeren ikke gir beskjed om at det var riktig bruker koden fant
    do {
        # Denne do while løkken kjører så lenge brukeren ikke er funnet, eller brukeren ikke lengre ønsker å forsåke å finne en bruker
        do {
            # Denne variablen teller hvor mange ganger brukeren har forsøkt å finne en bruker, men ikke lykkes
            $count = 0
            do{
                # Skriver ut stringen som beskriver hva slags bruker det letes etter
                Write-Host $spoereTekst
                # Ber brukeren skrive inn noe som kan identifisere brukeren det spørres etter
                $entydig = Read-Host "Skriv inn et entydig alias på det du skal finne"

                # Tester om det ble skret inn noe som kan brukes for å finne en bruker
                if($entydig -eq "") {
                    # Gir beskjed om at det må skrives inne noe før enter trykkes
                    Write-Host "Du må skrive inn noe før du trykker enter" -ForegroundColor Red
                } else {
                    #Sjekker om brukeren finnes. bruker inneholder $null hvis ikke brukere finnes
                    $bruker = Get-Mailbox $entydig -RecipientTypeDetails UserMailbox –ErrorAction SilentlyContinue | Select Alias | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String
                }
                # Tester om det ble funnet en bruker
                if($bruker -eq ""){
                    # Gir beskjed om at det ikke ble funnet en bruker
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                
                $count++
            # Sjekker om det er funnet en bruker, og at det er gjort færre enn 5 forsøk siden sist bruker ble spurt om brukeren ønsket å ikke gjøre flere forsøk
            } while(($bruker -eq "" -or $entydig -eq "") -and $count -lt 5)

            # Sjekker om det er funnet en bruker, hvis ikke blir brukeren spurt om brukeren ønsker å gi seg, hvis brukeren øsnker å gi seg, så 
            if($bruker -eq "") {
                # Brukeren blir spurt om han øsnker å gi seg
                $oenskerAaFortsette = (Read-Host "Du ser ut til å ha gjort noen forsøk uten å lykkes, ønsker du å forsette? [y/n]").ToLower().Trim()
                # Hvis brukeren øsnker å gi seg, så returnerer koden til hovedmenyen
                if ($oenskerAaFortsette -ne "y") {
                    Break fortsettAdministrering
                }
            }

        # Sjekker at brukeren ikke er funnet ennå, og at brukeren ønsker å fortsette
        } while($bruker -eq "" -and $oenskerAaFortsette -eq "y")

        # Fjerner eventuell whitespace
        $bruker = $bruker.Trim().Replace("`n","").Replace("`r","")

        # Spør om det er riktig bruker som er funnet
        $riktigBruker = Read-Host "var det $bruker du så etter? [y/n]"
        $riktigBruker = $riktigBruker.ToLower().Trim()
    
    # Tester om brukeren har gitt beskjed om at det er riktig brukre som er funnet
    } while ($riktigBruker -ne "y")

    # Returnerer brukeren som er funnet
    return $bruker
}

#Funksjonen tar imot et brukernavn, og navnet på en e-postkonto, og returnerer en liste med rettigheter denne brukeren har til denne e-postkontoen. Funkjsonen forholder seg kun til rettighetene FullAccess, Send-As, og SendOnBehalfOf og tar ikke hensyn til arv
function Get-ListeOverGitteBrukerrettigher() {

    #parameterene som blir sendt til funksjonen får navn jeg kan bruke videre
    param([string]$bruker,[string]$epostkonto)


    # Initialiserer ArrayList-en som skal inneholde de forskjellige rettighetene brukeren har til e-postkontoen
    $Resultat = [System.Collections.ArrayList]@()

    
    # Denne bolken sjekker om brukeren har tilgangen FullAccess,
    # Utskriften fra funksjonen som sjekker for rettigheten behandles slik at vi sitter igjen med bare rettighetene brukeren har til e-postkontoen
    # Denne delen kan enkelt modifiseres til å sjekke for rettighetene DeleteItem, ReadPermission, ChangePermission, ChangeOwner ved å legge til flere ifsettniger som sjekker innholdet i arraylisten
    $ResultatMailboxPermission = [System.Collections.ArrayList]((Get-MailboxPermission -Identity $epostkonto -User $bruker | Select-Object AccessRights | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace('{','').Replace('}','').Replace("`n",", ").Replace("`r",", ").Trim()).Split(", ",[System.StringSplitOptions]::RemoveEmptyEntries)

    if($ResultatMailboxPermission.Contains("FullAccess")) {
        $Resultat.Add("FullAccess")  | Out-Null # Out-Null sørger for at utskriften fra denne kommandoen ikke blir en del av returverdien fra funksjonen
    }


    # Denne bolken sjekker om brukeren har tilgangen Send-As,
    # Utskriften fra funksjonen som sjekker for rettigheten behandles slik at vi sitter igjen med bare rettighetene brukeren har til e-postkontoen
    $ResultatSendAs = (Get-Mailbox -Identity $epostkonto | Get-ADPermission -User $bruker | where {($_.ExtendedRights -like “*Send-As*”)} | Select-Object ExtendedRights | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace('{','').Replace('}','').Replace("`n","").Replace("`r","").trim()
    
    if($ResultatSendAs -ne "") {
        $Resultat.Add("SendAs") | Out-Null
    }


    # Denne bolken sjekker om brukeren har tilgangen SendOnBehalfOf,
    # Utskriften fra funksjonen som sjekker for rettigheten behandles slik at vi sitter igjen med bare rettighetene brukeren har til e-postkontoen
    $ResultatSendOnBehalf = [System.Collections.ArrayList]((Get-Mailbox -resultsize unlimited | Where {($_.GrantSendOnBehalfTo -ne $null) -and ([string]$_.Alias -eq $epostkonto)} | Select-Object GrantSendOnBehalfTo | Format-Table -HideTableHeaders -Wrap | Out-String).Replace('{','').Replace('}','').Replace("`n","").Replace("`r","").Trim()).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)
    
    foreach ($element in $ResultatSendOnBehalf) {
        $temp = (Get-Mailbox $element.trim() | Select Alias | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Trim()

        if ($temp -eq $bruker) {
            $Resultat.Add("SendOnBehalfOf") | Out-Null # Out-Null sørger for at utskriften fra denne kommandoen ikke blir en del av returverdien fra funksjonen
        }
    }

    
    # Denne linjen forsikrer om at hver rettighet bare er listet en gang
    $Resultat = $Resultat | Select -Unique


    # Initialiserer returverdien, som er en string, har valgt å returnere en string, fordi PowerShell er litt sær når Array sendes mellom funksjoner
    $returverdi = ""

    # Rettighetene legges inn i stringen som skal returneres
    Foreach ($rettighet in $Resultat) {
        if ($rettighet -ne "") {
            $returverdi += "$rettighet,"
        }
    }

    # Hvis returverdien ikke er tom, inneholder den når et unødvendig komma på slutten, som fjernes i denne if settningen
    if ($returverdi-ne "") {
        $returverdi = $returverdi.Substring(0,($returverdi.Length-1))
    }

    # Funksjonen avsluttes
    return $returverdi

}

# Funksjonene tar inn en liste med valg, skriver dem ut, og spør brukeren hvilket valg brukeren øsnker å gjøre, valget brukeren gjør, valdieres, og returneres som en int
function Get-Menyvalg() {
    # Denne funksjoen tar inn en liste med stringer som beskriver valg som kan gjøres 
    param([string[]]$menyvalg)

    # Variablen som brukes for å skrive ut et tall som brukes for å velge menyelement
    [int]$i = 0

    # De ulike valgene listes ut med et tall foran hvert enkelt valg
    Foreach($mulighet in $menyvalg) {
        Write-Host $i ": " $mulighet
        $i++
    }

    # Brukeren blir bedt om å skrive inn valget sitt
    $valg = Read-Host -Prompt "Skriv inn valget ditt"
    # Denne variablen brukes sensere for å kontrollere at det er et helttall som er skrevet inn, og ikke et desimaltall
    $heltall = 0
    # Denne variablen brukes senere for å kontrollere om valget som er skrevet inn er et heltall og ikke et desimaltall
    $gyldigIntValg = $true
    
    # Denne do while løkken kjører fremt til valget som er skrevet inn tilsvarer et menyelement
    do {
        # Denne while løkken lister ut menyen på nytt, og ber brukeren oppgi et valg så lengre valget som blir gitt ikke tilsvarer et menyelement
        # Whileløkken tester om valget som er gjort er en int, eller om valget var tomt, $gyldigIntValg brukes for å sjekke om brukeren har skrevet inn noe som er et desimaltall
        while (![bool]($valg -as [int] -is [int]) -or !$gyldigIntValg -or $valg -eq "") {
            # Telleren som skriver ut et tall foran de ulike valgene settes til 0 igjen
            $i=0
            # De ulike valgmulighetene listes ut igjen
            Foreach($mulighet in $menyvalg) {
                Write-Host $i ": " $mulighet
                $i++
            }
            # Det skrives ut en beskjed om at valget som ble gitt ikke er er gyldig valg
            Write-Host "Du skrev inn noe som ikke er et heltall mellom 0 og " ($menyvalg.Length - 1) -ForegroundColor Red
            # Brukeren blir på nytt bedt om å skrive inn valget sitt
            $valg = Read-Host "Skriv inn valget ditt: "
            # Antar at valget er et gyldig valg frem til det motsatte er bevist
            $gyldigIntValg = $true
        
        }
        # Runder av tallet til et haltall, valget som kommet ut av whileløkken over er garantert å være et tall
        $heltall = [math]::Round($valg)
        # caster valget til en double verdi
        $valg=[double]$valg

        # Denne ifsettnignen sjekket om tallet som er skrevet inn er et heltall, og om dette heltallet er innenfor størelsen av menyen
        if (($valg -ne $heltall) -or ($valg -lt 0) -or ($valg -ge ($menyvalg.Length))) {
            # Hvis ikke tallet som er gitt er et heltall, eller tallet havner utenfor størrelsen til menyen, så er det ikke et tall som er gyldig
            $gyldigIntValg = $false
        }

    } while (!$gyldigIntValg)

    # Returnere en int som kan brukes for å plukke ut et menyvalg
    return [int]$valg
        
}

# Denne funksjoenne fjerner en brukers rettighet(er) til en annen brukerkonto
function Remove-Brukerrettigheter() {
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    Clear-Host
    # Får tak i brukeren som skal miste rettighetet
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal miste rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    # Får tak i kontoen brukeren skal miste rettigheter til
    Clear-Host
    $konto = Get-Epostkonto "Skriv inn navnet på kontoen som $bruker skal miste rettighet til"
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    Clear-Host

    # Starter funksjonen som spør hvilke rettigher som skal fjernes
    Remove-Rettigheter $bruker $konto
}

# Denne funksjoenne fjerner en kontos rettighet(er) til en annen brukerkonto
function Remove-Rettigheter() {

    # Funksjonen tar inn to stringer, som hver er et alias som beksriver en bruker og en konto
    param([string]$bruker,[string]$konto)

    # Får tak i en liste over hvilke rettigheter brukeren alt har, som jeg legger inn i en arraylist for å gjøre det enklere å bearbeide
    $rettigheterSomKanMistes = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Legger til et valg om å ikke gjøre endringer i rettigheter brukren har til kontoen
    $rettigheterSomKanMistes.Add("Ønsker ikke å frata $bruker rettigheter til kontoen $konto") | Out-Null

    # Hvis brukeren har en eller flere rettigheter til koentoen, så listes de ut, samt en tallverdi foran rettighene som representerer rettigheten når den senre kan bli valgt
    if($rettigheterSomKanMistes.Count -gt 1) {
        Write-Host "Rettigheter $bruker kan bli fratatt fra kontoen $konto :"
        # Telleren som angir verdien som kan bli balgt for rettigheten
        $i = 0
        foreach($rettighet in $rettigheterSomKanMistes) {
            # Utskrift av rettighetene
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        # Hvis det ikke er noen rettigheter å fjerne, blir det skrevet ut en beskjed om det, og funksjonen avsluttes
        Write-Host "$bruker kan ikke bli fratatt flere rettigheter til kontoen $konto `n"
        Pause
        Return
    }

    # Booslk verdi somb rukes for å sjekke at det som skrives inn er verdier som kan brukes videre
    $erRetteVerdier = [boolean]$true
    # De ulike rettighetene som skal fjernes fra brukeren til kontoen
    $gamleRettigheter = ""

    do {

        # Antar at det som skrives inn er rett, frem til det motsatte er bevist
        $erRetteVerdier = [boolean]$true

        # Får inn valget til brukeren over hvilke rettigheter som skal fjernes
        $gamleRettigheter = [System.Collections.ArrayList]((Read-Host "`n`nSkriv inn nummeret som står før rettigheten du ønsker å frata $bruker til kontoen $konto`nOm du ønsker å frata flere rettigheter, så kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene på rettigheten(e) du ønsker å frata").Trim()).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        # lagrer de unike verdiene i arrayen i en array som senere brukes for å kontrollere at det kun er gitt unike verdier
        $temp = $gamleRettigheter | Get-Unique

        # Sjekker at det er gjort et valg
        if($gamleRettigheter.Count -eq 0) {
            
            # Skrivet ut en beskjed detsom det ikke er gjort et valg, og setter $erRetteVerdier til false
            Write-Host "Du kan ikke bare trykke på enter, du måt gjøre et valg, om du øsnker å avslutte, kan du skrive inn" ($rettigheterSomKanMistes.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false

        # Hvis det er gjort et valg, så sjekkes det at alle valgene som er gjort, er unike
        } elseif($temp.count -eq $gamleRettigheter.Count) {
            
            # Går igjennom alle valgen og sjekker at de er tall, og at tallverdien er innenfor menystørrelsen
            foreach($valg in $gamleRettigheter) {
                #Sjekker at det er et tal som er skrevet inn
                if(![boolean]($valg -as [int] -is [int])) {
                     # skriver ut en advarsel om at valget ikke er et tall, og setter verdien $erRetteVerdier til false
                    Write-Host "$valg er ikke et tall, du må liste opp rettighetene du ønsker å frata på nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                    Break

                } else {
                    # caster valget til int
                    $valg = [int]$valg

                    # Sjekket om valget er innenfor de verdiene som menyen inneholder
                    if(($valg -lt 0) -or ($valg -ge $rettigheterSomKanMistes.Count)) {

                        # Skriver ut en advarsel om at valget ikke er innenfor de verdiene som menyen inneholder, og setter verdien $erRetteVerdier til false
                        Write-Host "$valg er ikke er tall mellom 0 og" ($rettigheterSomKanMistes.Count-1) ", du må skrive inn valgene på nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break
                    # Sjekker at det ikke er gjort et valg om å ikke legge til flere rettigheter, samtidig som det er valgt rettigheter som skal taes fra brukeren
                    } elseif (($valg -eq ($rettigheterSomKanMistes.Count-1)) -and ($gamleRettigheter.Count -gt 1)) {
                        # Gir beskjed om at valgene som er gjort, er lokgisk gale, og setter $erRetteVerdier til false
                        Write-Host "Du kan ikke frata rettigheter, og samtidig gjøre valget:" $rettigheterSomKanMistes[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($rettigheterSomKanMistes.Count-2) "separert med komma, eller bare" ($rettigheterSomKanMistes.Count-1)  -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break

                    }
                }
            }
        } else {
            # Gir beskjed om at det ikke er lov å liste opp en verdi to ganger, og setter $erRetteVerdier til false
            Write-Host "Du kan kunn skrive inn unike verdier, separert med komma, du kan ikke liste opp en rettighet to ganger" -ForegroundColor Red
            $erRetteVerdier = $false

        }

    # sjekker om det er riktige verdier som er skrevet inn, hvis ikke, så går løkken gjennom prosessen med å få valgene fra brukeren på nytt
    } while (!$erRetteVerdier)

    # Hvis valget er å ikke gjøre noen endringer, så avluttes funksjonen
    if($gamleRettigheter[0] -eq ($rettigheter.Count -1)) {
        return
    }
    
    # et par av funksjonene for å frata rettigheter tar ikke imot alias som en gyldig verdi, så må anskaffe DistinguishedName for kontoen det skal fratas rettighet på
    $kontoNavn = (Get-Mailbox $konto –ErrorAction SilentlyContinue | Select DistinguishedName | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()

    # For hvert valg som er gjort, går valget inn i switchen, og koden for å fjerne valgt rettighet kjøres
    foreach($valg in $gamleRettigheter) {
        switch ($rettigheterSomKanMistes[[int]$valg]) {
            "FullAccess"{
                Remove-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false | Out-Null
            }
            "SendAs"{
                Remove-ADPermission -Identity $kontoNavn -User $bruker -ExtendedRights 'Send-As' -InheritanceType 'All' -ChildObjectTypes $null -InheritedObjectType $null -Properties $null -Confirm:$false | Out-Null
            }
            "SendOnBehalfOf"{
                # Må bruke scriptblock for at berdien for $bruker skal sendes videre som aliaset til brukeren, og ikke som en string "$bruker"
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Remove=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                # Det skal ikke være mulig å havne her, men skulle det ha skjedd en feil, så bør systemansvarlig gies beskjed slik at logiken kan rettes på
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $rettigheterSomKanMistes[[int]$valg] "ble forsøkt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    # Henter en liste over det rettighetene brukeren nå har til kontoen
    $rettigheterSomKanMistes = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Fjerner tidligere utskrift for å gjøre konsollvinduet oversiktlig
    Clear-Host
    # Gir beksjed om at rettighetene ser ut til å ha blitt gjernet, og lister ut de rettighetene brukeren fortsatt har til kontoen
    Write-Host "Rettigheter er blitt fjernet, rettighetene $bruker forsatt har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheterSomKanMistes) {
        Write-Host "    - $rettighet"
    }
    # Pauser før funksjonen avlsuttes, slik at brukeren rekker å lese utskriften
    Pause
    Clear-Host
}

# Denne funksjonen gir en bruker rettigheter til en delt postboks
function Add-BrukerRettighetTilDeltPostboks() {
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til brukeren som skal få rettigheter
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal få rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Cleat-Host
    # Får tak i aliaset til kontoen brukeren skal få rettigheter til
    $konto = Get-DeltPostboks "Skriv inn aliaset på den delte kontoen $bruker skal få rettighetheter til"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    
    # Sender alias til bruker som skal få rettighet, og til kontoen det skal bli gitt rettighet til
    Add-Rettigheter $bruker $konto
}

# Legger en konto til en kontaktliste
function Add-KontoTilKontaktliste() {
    Clear-Host
    $bruker = Get-Epostkonto "Skriv inn aliaset på brukeren som skal lagges til i en liste"
    Clear-Host
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen $bruker skal legges til i"
    Clear-Host

    Add-DistributionGroupMember -Identity $liste -Member $bruker

    # Sjekker om bruker er medlem i kontktlisten    
    if((Get-DistributionGroupMember -identity $liste -ErrorAction SilentlyContinue | Where {$_.Alias -eq $bruker}) -ne $null){
        # Skriver ut en beskjed om at brukeren nå er medlem av listen
        Write-Host "`n$bruker er nå en del av $liste" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til å ha gått galt
        Write-Host "`n$bruker ser ikke ut til å finnes i $liste" -ForegroundColor Red
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    Clear-Host
}

 # Denne funskjonen returnerer aliaset til en delt postboks
function Get-DeltPostboks() {
    # Tar inn en string som beskriver hvilken konto programvaren spør etter
    param([string]$spoereTekst)

    # Oppretter de variablene som skal brukes senre i koden
    $konto = ""
    $oenskerAaFortsette = "n"
    $riktigKonto = ""

    # Denne do while løkken kjører så lenge brukeren ikke gir beskjed om at det var riktig konto koden fant
    do {
        # Denne do while løkken kjører så lenge kontoen ikke er funnet, eller brukeren ikke lengre ønsker å forsåke å finne en konto
        do {
            # Denne variablen teller hvor mange ganger brukeren har forsøkt å finne en konto, men ikke lykkes
            $count = 0
            do{
                # Skriver ut stringen som beskriver hva slags konto det letes etter
                Write-Host $spoereTekst
                # Ber brukeren skrive inn noe som kan identifisere kontoen det spørres etter
                $entydig = Read-Host "Skriv inn et entydig alias på det du skal finne"

                # Tester om det ble skret inn noe som kan brukes for å finne en konto
                if($entydig -eq "") {
                    # Gir beskjed om at det må skrives inne noe før enter trykkes
                    Write-Host "Du må skrive inn noe før du trykker enter" -ForegroundColor Red
                } else {
                    #Sjekker om kontoen finnes. konto inneholder $null hvis ikke kontoen finnes
                    $konto = Get-Mailbox $entydig -RecipientTypeDetails sharedmailbox –ErrorAction SilentlyContinue | Select Alias | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String
                }
                # Tester om det ble funnet en konto
                if($konto -eq ""){
                    # Gir beskjed om at det ikke ble funnet en konto
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                
                $count++
            # Sjekker om det er funnet en konto, og at det er gjort færre enn 5 forsøk siden sist bruker ble spurt om brukeren ønsket å ikke gjøre flere forsøk
            } while(($konto -eq "" -or $entydig -eq "") -and $count -lt 5)

            # Sjekker om det er funnet en konto, hvis ikke blir brukeren spurt om brukeren ønsker å gi seg, hvis brukeren øsnker å gi seg, så avluttes søket, og hovedmenyen lastes
            if($konto -eq "") {
                # Brukeren blir spurt om han øsnker å gi seg
                $oenskerAaFortsette = (Read-Host "Du ser ut til å ha gjort noen forsøk uten å lykkes, ønsker du å forsette? [y/n]").ToLower().Trim()
                # Hvis brukeren øsnker å gi seg, så returnerer koden til hovedmenyen
                if ($oenskerAaFortsette -ne "y") {
                    Break fortsettAdministrering
                }
            }

        # Sjekker at kontoen ikke er funnet ennå, og at brukeren ønsker å fortsette
        } while($konto -eq "" -and $oenskerAaFortsette -eq "y")

        # Fjerner eventuell whitespace
        $konto = $konto.Trim().Replace("`n","").Replace("`r","")

        # Spør om det er riktig konto som er funnet
        $riktigKonto = (Read-Host "var det $konto du så etter? [y/n]").ToLower().Trim()
    
    # Tester om brukeren har gitt beskjed om at det er riktig konto som er funnet
    } while ($riktigKonto -ne "y")

    # Returnerer kontoen som er funnet
    return $konto
}

# Denne funskjonen returnerer navnet til en kontaktliste
function Get-Kontaktliste() {
    # Tar inn en string som beskriver hvilken liste programvaren spør etter
    param([string]$spoereTekst)

    # Oppretter de variablene som skal brukes senre i koden
    $liste = ""
    $oenskerAaFortsette = "n"
    $riktigListe = ""

    # Denne do while løkken kjører så lenge brukeren ikke gir beskjed om at det var riktig liste koden fant
    do {
        # Denne do while løkken kjører så lenge listen ikke er funnet, eller brukeren ikke lengre ønsker å forsåke å finne en liste
        do {
            # Denne variablen teller hvor mange ganger brukeren har forsøkt å finne en liste, men ikke lykkes
            $count = 0
            do{
                # Skriver ut stringen som beskriver hva slags liste det letes etter
                Write-Host $spoereTekst
                # Ber brukeren skrive inn noe som kan identifisere listen det spørres etter
                $entydig = Read-Host "Skriv inn et entydig navn på det du skal finne"

                # Tester om det ble skret inn noe som kan brukes for å finne en liste
                if($entydig -eq "") {
                    # Gir beskjed om at det må skrives inne noe før enter trykkes
                    Write-Host "Du må skrive inn noe før du trykker enter" -ForegroundColor Red
                } else {
                    #Sjekker om listen finnes. liste tom string hvis ikke listen finnes
                    $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$entydig`"}")
                    $liste = (Invoke-Command -ScriptBlock $scriptblock –ErrorAction SilentlyContinue  | Select Name | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Trim()
                }
                # Tester om det ble funnet en liste
                if($liste -eq ""){
                    # Gir beskjed om at det ikke ble funnet en liste
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                
                $count++
            # Sjekker om det er funnet en liste, og at det er gjort færre enn 5 forsøk siden sist bruker ble spurt om brukeren ønsket å ikke gjøre flere forsøk
            } while(($liste -eq "" -or $entydig -eq "") -and $count -lt 5)

            # Sjekker om det er funnet en liste, hvis ikke blir brukeren spurt om brukeren ønsker å gi seg, hvis brukeren øsnker å gi seg, så avluttes søket, og hovedmenyen lastes
            if($liste -eq "") {
                # Brukeren blir spurt om han øsnker å gi seg
                $oenskerAaFortsette = (Read-Host "Du ser ut til å ha gjort noen forsøk uten å lykkes, ønsker du å forsette? [y/n]").ToLower().Trim()
                # Hvis brukeren øsnker å gi seg, så returnerer koden til hovedmenyen
                if ($oenskerAaFortsette -ne "y") {
                    Break fortsettAdministrering
                }
            }

        # Sjekker at listen ikke er funnet ennå, og at brukeren ønsker å fortsette
        } while($liste -eq "" -and $oenskerAaFortsette -eq "y")

        # Fjerner eventuell whitespace
        $liste = $liste.Trim().Replace("`n","").Replace("`r","")

        # Spør om det er riktig liste som er funnet
        $riktigListe = (Read-Host "var det $liste du så etter? [y/n]").ToLower().Trim()
    
    # Tester om brukeren har gitt beskjed om at det er riktig liste som er funnet
    } while ($riktigListe -ne "y")

    # Returnerer listen som er funnet
    return $liste
}

#Fjerner en bruker fra en kontaktliste
function Remove-BrukerFraKontaktliste() {
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til brukeren som skal fjernes fra listen
    $bruker = Get-Epostkonto "Skriv inn aliaset på brukeren som skal fjernes fra en liste"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Henter listen som bruker skal fjenes fra
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen $bruker skal fjernes fra"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host

    # Fjerner bruker fra liste
    Remove-DistributionGroupMember -Identity $liste -Member $bruker

    # Sjekker om bruker er medlem i kontktlisten    
    if((Get-DistributionGroupMember -identity $liste -ErrorAction SilentlyContinue | Where {$_.Alias -eq $bruker}) -eq $null){
        # Skriver ut en beskjed om at brukeren nå fjernet fra listen
        Write-Host "`n$bruker er ikke lengre en del av $liste" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til å ha gått galt
        Write-Host "`n$bruker ser fortsatt ut til å finnes i $liste" -ForegroundColor Red
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    Clear-Host
}

# Funksjonen fjerner rettiheter en bruker har til en delt postboks
function Remove-BrukerRettighetFraDeltPostboks() {
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til brukeren som skal miste rettigheter
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal få rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Cleat-Host
    # Får tak i aliaset til kontoen brukeren skal miste rettigheter til
    $konto = Get-DeltPostboks "Skriv inn aliaset på den delte kontoen $bruker skal få rettighetheter til"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    
    # Sender alias til bruker som skal miste rettigheter, og til kontoen det fratas rettighet fra
    Remove-Rettigheter $bruker $konto
}

# Funksjonen lister ut delte postbokser
function List-DeltPostboks() {
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host

    Write-Host "Delte postbokser: "

    # Får en liste over delte postbokser, og skriver ut navn og alias
    Get-mailbox -RecipientTypeDetails sharedmailbox -Resultsize unlimited | Select Name,Alias | Format-Table -AutoSize -Wrap
    
    # Pauser slik at brukeren skal kunne lese utskriften før skriptet går videre
    Pause
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host
}

# Lister ut medlemene i en kontaktliste/distribusjonsgruppe
function List-KontaktlisteMedlemmer() {
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen du ønsker å se medlemmene til"
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host

    # Skriver ut listen med medlemer
    Write-Host "Medlemmer I $Liste :"
    Get-DistributionGroupMember -identity $liste | Select Name,Alias | Format-Table -AutoSize -Wrap

    # Pauser slik at brukeren skal kunne lese utskriften før skriptet går videre
    Pause
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host
}

#Funksjonen sletter en delt epost 
function Remove-DeltPostboks{ 
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
    # Får tak i aliaset til en delt postboks
    $entydig = Get-DeltPostboks "Skriv inn navnet på en deltpostboks du ønsker å slette"
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
    
    #Sletter en delt postboks 
    Remove-Mailbox $entydig
 
    # Sjekker om postboksen fortsatt eksisterer    
    if((Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue) -eq $null){
        # Skriver ut en beskjed om at slettingen var vellykket
        Write-Host "`nDen delte postboksen $navn eksisterer ikke lengre" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til å ha gått galt
        Write-Host "`nDen delte postboksen $navn ser fortsatt ut til å eksistere" -ForegroundColor Red
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
}

# Sletter en kontaktliste 
function Remove-Kontaktliste{
    # Får navnet på en kontaktliste
    $navn = Get-Kontaktliste "Skriv inn navn på distribusjonsgruppe"

    #Sletter en kontaktliste, legger utskriften i en variabel, slik at vi har kontroll på hva som blir skrevet ut
    $enVariabel = Remove-DistributionGroup $navn
    
    #Tester om gruppen fortsatt eksisterer, når scriptblock'en kjøres, så returnes $null hvis alt har gått som det skal
    $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
    $eksistererGruppen = Invoke-Command -ScriptBlock $scriptblock

    # Skriver ut en melding til brukeren om resultatet av kjøringen
    if($eksistererGruppen -ne $null) {
        Write-Host "Det ser ut til å ha skjedd en feil, distribusjonsgruppen eksisterer fortsatt" -ForegroundColor Red
    } else {
        Write-Host "Distribusjonsgruppen $navn eksisterer ikke lengre" -ForegroundColor Green
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
}

# Legger en bruker til en Kontaktliste
function Add-BrukerTilKonakListe($Navn){ 

#en variabel som trengs senere for å få en riktig test
$errStoerelse = 0                 

$sjekk = $false          
do{ 
        #Valg mellom å legge til en bruker eller flere brukere fra en OU 
  $Valg = Read-Host "1:En bruker`n2:Flere brukere`n"                  
  if($Valg -eq "1"){ 
         
            [string]$bruker = Read-Host "Skriv inn postboks som skal legges til kontaktlisten" 
            #Sjekker om brukeren finnes 
            $bruker = Test-Postboks $bruker 
 
            #Tar ut all informasjon om en bruker 
            $temp = Get-Mailbox $bruker | select -Property * 
             
            #Legger brukeren inn i kontaktlisten 
            Add-DistributionGroupMember -Identity $Navn -Member $temp.UserPrincipalName 
            $sjekk = $true 
 
            Write-Host "Brukeren $bruker lagt til distribusjonsgruppen $Navn" -ForegroundColor Green 
        }elseif($Valg -eq "2"){ 
            #skriver ut alle OU-ene 
            $OU = Get-OU 
 
            #sjekker at gyldig verdi er skrevet inn
            do{ 
                $sjekkInt = $false 
                $valgOU = $null 
                [string]$ValgOU = Read-Host "Velg OU-en du ønsker å importere til  kontaktlisten (eks 1)" 
                if($ValgOU -ne $null){                     
                 #Sjekker om innskrevet verdi er tall                     
                    try{ 
                        [int]$ValgOU = $ValgOU 
                    }catch{ 
                        Write-Host "Ugyldig input" -ForegroundColor Red 
                        $sjekkInt = $true
                    }                     
                }else{ 
                        $sjekkInt = $true 
                    } 
                 
            }while (($ValgOU -gt $OU.length-1) -or $sjekkInt -eq $true) 
 
            #Først tar en ut alle brukere i en OU. Deretter går en gjennom alle brukerene som har mail i den OU-en, og legger de inn i distrubusjonsgruppa 
            Get-ADUser -Filter * -SearchBase $OU[$ValgOU].DistinguishedName -Properties *| ForEach-Object { 
                #Sjekker om bruker har mail
                
                if($_.Mail -ne ""){ 
                    #Legger en bruker til distubusjonsgruppa 
                    Add-DistributionGroupMember -Identity $Navn -Member $_.samaccountname <#-ErrorVariable err #>-ErrorAction SilentlyContinue
                    $scriptblock = [scriptblock]::Create("Get-DistributionGroupMember -Identity `"$Navn`" | Where-Object{`$_.Alias -eq `"$_.samAccountName`"}")
                    $sjekkResultat = Invoke-Command -ScriptBlock $scriptblock
                }                  
                if($sjekkResultat -eq ""){
                    $utskriftBruker += $_.SamAccountName + "`n" 
                    $errStoerelse++ | Out-Null
                } 
            } 
            Write-Host "Velykket opperasjon" -ForegroundColor Green             
            write-host "-------------------`n"             
            if($errStoerelse -ne 0) { 
                Write-Host "Brukere som feilet`n"                 
                write-Host $utskriftBruker 
            } 
                        
            $sjekk = $true 
        } 
    }while($sjekk -eq $false) 
} 

#Funksjonen gir en bruker rettigheter til en delt epost. 
function Add-RettigheterTilPostboks($navn,$bruker){
    
    #Oppretter en tabell med de ulike rettighetene en kan få 
    $rettigheter = @("ChangeOwner","ChangePermission","DeleteItem","ExternalAccount","FullAccess","ReadPermission") 
    
    #Skriver ut alle rettighetene med et tall foran slik at brukeren enkelt kan velge rettighet 
    #Write-Host $rettigheter[0] 
    for($i=0;$i-lt$rettigheter.Length;$i++){ 
        Write-Host $i":" $rettigheter[$i] 
    } 
     
    #Sjekker om det er gyldig input som er skrevet inn
    do{ 
        $sjekkInt = $false 
        $valgrettighet = $null 
        #Sjekker om rettigheten er et tall
        try{ 
            [int]$valgrettighet = Read-Host "Skriv inn ønsket rettighet (eks 1)" 
        }catch{ 
            Write-Host "Ugyldig input" -ForegroundColor Red 
            $sjekkInt = $true 
        }
        if ($valgrettighet -eq "") {
            Write-Host "Du må taste inn et valg"  -ForegroundColor Red
        }elseif ($valgrettighet -gt ($rettigheter.length-1)) {
            Write-Host "Verdien du har valgt er større enn menyalternativene" -ForegroundColor Red
        } 
    }while (($valgrettighet -gt ($rettigheter.length-1)) -or ($valgrettighet -eq "") -or $sjekkInt -eq $true) 
    #Setter rettigheten 
    Get-Mailbox -Identity $navn | Add-MailboxPermission -User $bruker -AccessRights $rettigheter[$valgrettighet] -InheritanceType All -ErrorVariable err 
 
    #Hvis $err[0] er lik $null har operasjonen gått bra
    if($err.length -eq 0){ 
        Write-Host "Velykket operasjon" -ForegroundColor Green 
    } 
}

#Funsksjonen setter mulighet for en bruker å sende på vegne av en annen 
function Add-SendPaVegneAv($navn, $bruker){  
    Set-Mailbox $navn -GrantSendOnBehalfTo $bruker -ErrorVariable err  
#Hvis en ikke får feilmelding vil en få en utskrift som sier at operasjonen er vellykket. 
    if($err.length -eq 0){ 
        Write-Host "$bruker kan nå sende på vegne av $navn" -ForegroundColor Green 
    } 
}  

function Confirm-Passord ($Passord){
    #Oppretter boolean sjekker for å finne feil ved passordet.
    $sjekkStor = $false
    $sjekkLiten = $false
    $SjekkTall = $false

    #sjekkPassord er sjekken som sier om passordet er godkjent eller ikke
    $sjekkPassord = $true

#Den første testen sjekker om lengden på passordet er godkjent. Den må være minst 8 tegn langt.
    if($Passord.Length -lt 8){
        Write-Host "Lengden på passordet er for kort" -ForegroundColor Red
        $sjekkPassord = $false
    }else{
        #Vi benytter for-løkke for vi skal gå igjennom alle bokstavene som er i passord teksten.
        for($i=0;$i-lt $Passord.length;$i++){
            #Denne linjen tar ut en og en bokstav. $i variabelen blir inkrementert med en, og dermed går en gjennom hele teksten
            $midlertidig = $Passord.Substring($i,1)

            #Sjekker om bokstaven er stor. I Ascii tabellen er store bokstaver mellom 65 og 90. Vi godkjenner ikke ÆØÅ
            if([char]$midlertidig -ge 65 -and [char]$midlertidig -le 90){
                #Setter sjekkStor til sann
                $sjekkStor = $true
            }
            #Sjekker om bokstaven er liten. I Ascii tabellen er litenbokstav mellom 97 til 122. Vi godkjenner ikke æøå
            if([char]$midlertidig -ge 97 -and [char]$midlertidig -le 122){
                $sjekkLiten = $true
            }
            #Sjekker om bokstaven er et tall. I Ascii tabellen er tall mellom 48 til 57. 
            if([char]$midlertidig -ge 48 -and [char]$midlertidig -le 57){
                $sjekkTall = $true
            }
        }
        #Hvis sjekkStor er usann. 
        if($sjekkStor -eq $false){
            Write-Host "Du mangler stor bokstav i passordet" -ForegroundColor Red
            #sjekkPassord settes til usann siden passordet mangler minst storbokstav
            $sjekkPassord = $false
        }
        if($sjekkLiten -eq $false){
            Write-Host "Du mangler liten bokstav i passordet" -ForegroundColor Red
            #sjekkPassord settes til usann siden passordet mangler minst litenbokstav
            $sjekkPassord = $false
        }
        if($SjekkTall -eq $false){
            Write-Host "Du mangler tall i passordet" -ForegroundColor Red
            #sjekkPassord settes til usann siden passordet mangler minst tall
            $sjekkPassord = $false
        }
    }
    #Returnerer sann eller usann
    return $sjekkPassord
} 

#Funksjonen tar imot et brukernavn og formaterer det til små bokstaver og endrer æøå til eoa 
function Format-Brukernavn ($brukernavn){
    #setter brukernavn til små bokstaver
    $brukernavn=$brukernavn.ToLower()
    #Erstatter æøå med eoa
    $brukernavn=$brukernavn.replace('æ','e')
    $brukernavn=$brukernavn.replace('ø','o')
    $brukernavn=$brukernavn.replace('å','a')
    #Returnere det formatere brukernavnet    
    return $brukernavn
} 

#Funksjonen skriver ut alle OU-ene i domenet
function Get-OU{
    #Henter ut alle OU-ene i domenet. Alle egenskapene bli hentet ut
    $OU = Get-ADOrganizationalUnit -Filter * -Properties *
    #Oppretter en teller som skal brukes til utskriften for brukeren.
    $teller = 0
    foreach ($i in $OU.DistinguishedName){
        <#
        legger en teller forann utskriften slik at brukeren av scriptet slipper å skrive inn heile stien til OU-en.
        I steden for kan brukeren bare skrive tallet forann OU-stien
        #>
        Write-Host $teller : $i
        $teller++
    }
    #Returnerer alle Ou-ene med alle egenskaper
    return $OU
}

#Funksjonen oppretter en ny delt epost 
function New-DeltPostboks{ 
    Write-Host "Opprett deltpostboks" 
     
    #Finner et ledig navn 
    $navn = Test-PostboksNavn 
    #Finner et ledig alias 
    $entydig = Test-PostboksAlias 
 
    #Opretter en nydelt postboks 
    New-Mailbox -Shared -Name $navn -DisplayName $navn -Alias $entydig

    $konto = Get-Mailbox $entydig -RecipientTypeDetails sharedmailbox  –ErrorAction SilentlyContinue
 
    #Godkjenings melding postboksen nå eksisterer   
    if($konto -ne $null){     
        Write-Host "`nDen delte postboksen $navn ble oprettet" -ForegroundColor Green 
    } 
     
    $Valg = Read-Host "Ønsker du å legge til rettigheter (eks: j/n)"     
    #Får valg om en ønsker å gi brukere rettigheter til den delte postboksen     
    if($Valg -eq "j"){     
        Set-Rettigheter $entydig 
    }  
}

#Oppretter en ny kontaktliste 
function New-Kontaktliste{

    [string]$navn = Read-Host "Skriv inn navn på distribusjonsgruppe"     
    if($navn -ne ""){ 
        #sjekker om kontaklisten finnes fra før 
        $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
        $sjekkNavn = Invoke-Command -ScriptBlock $scriptblock
    } 

    #oppretter en tall variabel utenfor løkken for å konne teste på den i do while løkken
    $eksistererGruppen = $null
    
    #Løkken går så lenge som opprettelsen av kontaktlisten ikke er lik null     
    do{ 
        #Løkken går så lenge navnet finnes fra før  
              
        while($sjekkNavn -ne $null -or $navn -eq ""){ 
             
            $navn = Read-Host "Navn finnes allerede. Skriv inn nytt navn på kontaktliste"             
            if($navn -ne ""){
                $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
                $sjekkNavn = Invoke-Command -ScriptBlock $scriptblock
            } 
        } 
        #Opretter en ny kontaktliste, legger utskriften i en variabel, slik at vi har kontroll på hva som blir skrevet ut
        $enVariabel = New-DistributionGroup -Name $navn -Type Distribution
        
        $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
        $eksistererGruppen = Invoke-Command -ScriptBlock $scriptblock

    }while($eksistererGruppen -eq $null)
     
    #Får et valg om en ønsker å legge til brukere til kontaktlisten     
    $valg = Read-Host "Ønsker du å legge til brukere i kontaktlisten (eks j/n)`_"     
    if($valg -eq "j"){ 
        Add-BrukerTilKonakListe $navn
    }
}

#Oppretter en ny postboks
function New-Postboks{
    $fornavn = Read-Host "Hva er fornavnet til brukeren?"
    #sjekker om lengden på fornavn er lengre enn 2
    while ($fornavn.length -lt 2){
        $fornavn = Read-Host "Fornavnet må inneholde minst to bokstaver. Skriv inn på
        nytt"
    }
    $etternavn = Read-Host "Hva er etternavnet til brukeren?"
    #sjekker om lengden på etternavn er lengre enn 2
    while ($etternavn.length -lt 2){
        $etternavn = Read-Host "Etternavnet må inneholde minst to bokstaver. Skriv inn
        på nytt"
    }
    #Oppretter fultnavn ut fra fornavn og etternavn
    $FultNavn = $Fornavn  + " " + $Etternavn
    #Får et unikt brukernavn
    [string]$Brukernavn = Set-Brukernavn $fornavn $etternavn
    #Tar bort mellomrom ol.
    $Brukernavn = $Brukernavn.Trim()
    #Henter ut domene
    $Domene = Get-ADDomain
    #Henter du forest navnet. Det inneholder domenenavnet
    $Forest = $Domene.forest

    #Skriver ut alle OU-ene
    $OU = Get-OU
    do{
        $sjekkInt = $false
        $valgOU = $null
        #Try-Catch er der for å sjekke om brukeren har skrevet inn et gyldig tall
        try{
            #Konverterer fra streng til int
            [int]$ValgOU = Read-Host "Velg OU-en du ønsker å legge brukeren til (eks 
	      1)"
        }catch{
            Write-Host "Ugyldig input" -ForegroundColor Red
            $sjekkInt = $true
        }
    }while (($ValgOU -gt $OU.length-1) -or ($ValgOU -eq "") -or $sjekkInt -eq $true)
  

    do{
        #Sjekker om passordet som er skrevet inn er like.
        do{
            $Passord = Read-Host "Skriv inn passord til brukeren" 
            $Passord2 = Read-Host "Gjenta passord" 

            if($Passord -ne $Passord2){
            Write-Host "Passordene smmsvarer ikke" -ForegroundColor Red
            }
        }while($Passord -ne $Passord2)
        #sjekker om passordet oppfyller de kravene vi har satt til passord
        $sjekkPassord = Confirm-Passord $Passord
    }while($sjekkPassord -eq $false)
    #konverterer passord over til sikker tekst
    $Passord = ConvertTo-SecureString $Passord -AsPlainText -force

    #Oppretter postboks
    New-Mailbox -UserPrincipalName $Brukernavn@$Forest -Alias $Brukernavn –name $FultNavn -OrganizationalUnit $OU[$ValgOU].CanonicalName -Password $Passord -FirstName $Fornavn -LastName $Etternavn -DisplayName $FultNavn -ResetPasswordOnNextLogon $false
    
    Write-Host "$FultNavn fikk en postboks" -ForegroundColor Green
}

#Oppretter en ny postboks fra en CSV-fil
Function New-PostboksCSV{
    #Henter ut domene
    $Domene = Get-ADDomain
    #Henter du forest navnet. Det inneholder domenenavnet
    $Forest = $domene.forest
    $Sti = Read-Host "Skriv inn sti til CSV-fil"
    #CSV-filen har parametrene fornavn, etternavn, ou og passord

    #Henter ut informasjonen som er i CSV-filen. Det som skiller de ulike argumentene er ;
    $Brukere = Import-CSV $sti -Delimiter ";"  
    #Går igjennom alle brukerene.
    foreach ($Bruker in $Brukere){   
        #Konverterer passordet over til sikker tekst
        $Passord = ConvertTo-SecureString $Bruker.Passord -AsPlainText -force
        #Henter ut etternavn
        $Etternavn = $Bruker.Etternavn 
        #Henter ut fornavn
        $Fornavn = $Bruker.Fornavn
        #Henter ut OU-sti
        $OU = $Bruker.OU
        #Får et unikt brukernavn
        [String]$Brukernavn = Set-Brukernavn $Fornavn $Etternavn
        #Tar bort mellomrom ol.
        $Brukernavn = $Brukernavn.Trim()
        
        
        #Oppretter fultnavn ut fra fornavn og etternavn
        $FultNavn = $Fornavn  + " " + $Etternavn
        #Oppretter postboks
        New-Mailbox -UserPrincipalName $brukernavn@$forest -Alias $Brukernavn –name $FultNavn -OrganizationalUnit $Forest/$OU -Password $Passord -FirstName $Fornavn -LastName $Etternavn -DisplayName $FultNavn -ResetPasswordOnNextLogon $false
    }
}

#Funksjonen tar inn fornavn og etternavn og lager et brukernavn ut av de første 3 bokstavene i hver.
function Set-Brukernavn($fornavn, $etternavn) {
    #Setter midlertidig variabelen til "" slik at den ikke inneholder noe fra tidligere.
    $MidlertidigBrukernavn = ""
    $sjekk = $true

    #If-testene under sjekker om lengden på fornavn og etternavn. Hvis etternavnet er på to bokstaver blir brukernavent på to bokstaver i stedet for tre
    if($fornavn.length -le 2){
        $brukernavn = $fornavn.substring(0,2) 
    }else{
        $brukernavn = $fornavn.substring(0,3)
    }
    if($etternavn.length -le 2){
        $brukernavn += $etternavn.substring(0,2) 
    }else{
        $brukernavn += $etternavn.substring(0,3)
    }
    #Telleren bli satt til en. Den skal brukes hvis brukernavnet allerede er i bruk
    $teller = 1
    #Bruker Format-Brukernavn
    $navn = Format-Brukernavn($brukernavn)
    $MidlertidigBrukernavn = $navn
    do{
        #Sjekker om brukernavnet er i bruk. Hvis brukernavn ikke finnes er resultatet $null, lager en scriptblock for at variablen $MidlertidigBrukernavn skal valideres før den sendes som et parameter inni en scriptblock 
        $scriptblock = [scriptblock]::Create("Get-ADUser -Filter {SamAccountName -eq `"$MidlertidigBrukernavn`"}")
        $finnes = Invoke-Command -ScriptBlock $scriptblock
        #Hvis $finnes er lik $null
        if($finnes -eq $null){
            $sjekk = $false
            $navn = $MidlertidigBrukernavn
        }else{
            #Hvis det er to like brukernavn vil teller bli lagt til slutten av
            brukernavnet for å skille de.
            $MidlertidigBrukernavn = $navn + $teller 
            #inkrementerer teller slik at en får et annet brukernavn neste gang.
            $teller +=1
        }
    }while($sjekk -eq $true)
    return $navn
} 

#Funksjonen lar deg velge mellom å sende på vegne av eller sette tilgang til en delt postboks 
function Set-Rettigheter{ 
    #Param er der slik at en har mulighet til å sende over navnet på den delte eposten.     
    param([Parameter(Mandatory=$false)]$navn)     
	do{ 
        $RettighetMeny = Read-Host "`n1:Sende på vegne av`n2:Sett tilgang til delt postboks`n3:Avslutt`n" 
        #Sjekker om $navn har innhold         
        if($navn -eq $null -or $navn -eq ""){             
        if($RettighetMeny -eq "1"){ 
                $navn = Read-Host "Skriv inn entydig postboks som skal gi rettigheter" 
                #Sjekker om det er et gyldig postboksnavn 
                $navn = Test-Postboks $navn 
 
 
            }elseif($RettighetMeny -eq "2"){ 
                
                #Henter ut alle postbokser som er delte 
                $navn = Get-Mailbox * | Where-Object {$_.IsShared -eq "True"}  
                
                #Lister ut alle delte postbokser                 
                for($i=0;$i -lt $navn.length; $i++){                     
                Write-Host $i : $navn[$i].Alias                 
                }         
                
                #Sjekker at det blir skrevet inn gyldig verdi                 
                do{ 
                    $sjekkiInt = $false 
                    $valgNavn = $null 
                    #Sjekker om det er tall som er skrevet inn                     
                    try{ 
                        [int]$valgNavn = Read-Host "Velg delt postboks (eks 1)" 
                    }catch{ 
                        Write-Host "Ugyldig input" -ForegroundColor Red 
                        $sjekkiInt = $true 
                    } 
                
                }while (($valgNavn -gt ($navn.length-1)) -or ($valgNavn -eq "") -or $sjekkiInt -eq $true) 
                #tar det valgte navnet fra objektet og velger det entydige navnet Alias 
                $navn = $navn[$ValgNavn].Alias 
            }             
        }else{ 
            $tempnavn = $navn 
        }
        if($RettighetMeny -eq "1"){  
            [string]$bruker = Read-Host "Skriv inn postboks som skal få rettigheter" 
            #Sjekker om postboksen eksisterer 
            $bruker = Test-Postboks $bruker 
 
            #Benytter send på vegne av funskjonen 
            Add-SendPaVegneAv $navn $bruker 
        }elseif($RettighetMeny -eq "2"){ 
            [string]$bruker = Read-Host "Skriv inn postboks som skal få rettigheter" 
            #Sjekker om postboksen eksisterer 
            $bruker = Test-Postboks $bruker 
 
            #Benytter rettigheter til postboks funksjonen 
            Add-RettigheterTilPostboks $navn $bruker 
        }         if($tempnavn -eq $null){ 
            $navn = "" 
        } 
    }while($RettighetMeny -ne "3") 
}

#Funksjonen sjekker om AD brukeren finnes og om han har epost knyttet til seg. 
function Test-AdBruker($bruker){ 
    [string]$bruker = $bruker 
         do{ 
        $sjekk = $false 
        #sjekker om brukeren finnes 
        $navnSjekk = Get-ADUser -Filter {SamAccountName -eq $bruker} -Properties * -ErrorAction SilentlyContinue
        if($navnSjekk -eq $null){ 
            [string]$bruker = Read-Host "Brukeren eksisterer ikke. Skriv inn ny" 
        } 
        #sjekker om brukeren har postboks registrert på seg
        if($navnSjekk.homeMDB -ne $null -and $navnSjekk -ne $null){ 
            [string]$bruker = Read-Host "Brukeren eksisterer, men det finnes allerede en postboks til brukeren. Skriv inn ny" 
        }
        if($navnsjekk.homeMDB -eq $null -and $navnSjekk -ne $null){ 
            $sjekk = $true 
        } 
         
    }while($sjekk -eq $false) 
     return navnSjekk 
}

#Funksjonen sjekker om alias navnet finnes
function Test-Postboks($entydig){
    [string]$entydig = $entydig
    
    $navnSjekk = Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue
    #Sjekker om brukernavnet finnes. navnsjekk inneholder $null hvis ikke brukere finnes
    while($navnSjekk -eq $null){
        [string]$entydig = Read-Host "Postboksen eksisterer ikke. Skriv inn ny"
        
        $navnSjekk = Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue
        
    }
    
    return $entydig
}

#Funksjonen sjekker om alias navnet finnes
function Test-PostboksAlias{

    do{
        [string]$entydig = Read-Host "Skriv inn entydig alias på postboks"
        #Sjekker om brukernavnet finnes. navnsjekk inneholder $null hvis ikke brukere finnes
        $navnSjekk = Get-Mailbox -Filter "Alias -eq '$entydig'" –ErrorAction SilentlyContinue
        
        if($navnSjekk -ne $null){
            Write-Host "Aliaset til postboksen eksisterer allerede. Skriv inn nytt" -ForegroundColor Red
        }
    }while($navnSjekk -ne $null -or $entydig -eq "")
    
    return $entydig
}

#Funskjonen sjekker om posboksnavnet finnes 
function Test-PostboksNavn{
    
    do{
        [string]$entydig = Read-Host "Skriv inn entydig navn på postboks"
        #Sjekker om brukernavnet finnes. navnsjekk inneholder $null hvis ikke brukere finnes
        $navnSjekk = Get-Mailbox -Filter "Name -eq '$entydig'" -ErrorAction SilentlyContinue
        
        if($navnSjekk -ne $null){
            Write-Host "Navnet til postboksen eksisterer allerede. Skriv inn nytt" -ForegroundColor Red
        }
    }while($navnSjekk -ne $null -or $entydig -eq "")
    
    return $entydig
}

function Get-Hovedmeny() {
    
    # Paramterene, $fremtidsvalg inneholder valg som skal gjøres, mens $valgGjort inneholder en historikk, begge to er stringer som inneholder tall, adskilt med komma
    # Disse to parameterene brukes for å kunne tilby tilbake valget i menyen
    param([string]$fremtidigeValg,[string]$valgGjort)

    # Fjerner tidligere utskrift fra konsollen, slik at brukeren får en ryddig meny
    Clear-Host

    # Boolsk verdi som brukes for å kontrollere at parameterene som er gitt, kunn inneholder tall, adskilt med komma
    [bool]$isRetteParametere = $true
    
    # Dette er en array som inneholder teksten på de forskjellige menyvalgene
    $menyElementer = @("Brukermeny","Delt postboksmeny","Kontaktliste meny","Avslutt")

    # Dette er variablen som brukes for å lagre menyvalget brukeren gjør
    [int]$valg = 0

    # Dette er variablen som brukes for å lagre valgene som skal gjøres i neste nivå av menyene
    $fremtidigeMenyValg = @()

    # Disse to variablene inneholder de to tilsendte variablene, men konveterer dem fra stringer til arrays for å gjøre dem enkelere å jobbe med
    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","


    # Denne løkken går igjennom innholdet i $fremtidigeValtSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $fremtidigeValgSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Denne løkken går igjennom innholdet i $valgGjortSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Hvis et element i $valgGjortSplittet eller $fremtidigeValtSplittet ikke er et tall, så vil koden videre gå utifra at det ikke er sendt ved noen paramentere til menyen, og det skrives ut en advarsel om dette
    if(!$isRetteParametere) {
        #Parameterene "nullstilles"
        $fremtidigeValg = ""
        $valgGjort = ""
        
        #det skrives ut en advarsel, og programmet settes på pause, slik at brukeren får anledning til å lese feilmeldingen før den viskes vekk av en CLear-Host senere i skriptet
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer bestående av tall, adskilt med komma.`nGår videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
        Pause
    }

    # Denne ifsettnigen sjekket om det er sendt ved en liste med valg som skal gjøres, hvis listen er tom, så spør den brukeren om hvilket valg som skal gjøres
    # Hvis listen med valg som skal gjøres ikke er tom, hentes valget ut fra listen, og fjernes fra listen
    if ($fremtidigeValg.Length -eq 0) {
        # spør brukeren som hvilket valg som skal bli gjort
        $valg = Get-Menyvalg $menyElementer
    } else {
        # Gjør stringen, som inneholder valgene som skal gjøres, om til en array som er enklere å jobbe videre med
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        # Henter ut valget som skal gjøres
        $valg = [int]$fremtidigeMenyValg[0]
        
        # I denne ifsettnigen fjernes valget som er gjort, og resten av arrayen gjøres om til en string som kan sendes videre,
        # hvis arrayen kun inneholder et element, så gjøres stringen som skal sendes videre om til en tom string
        if($fremtidigeMenyValg.Count -gt 1) {
            
            # Gjør stringen som skal sendes videre tom, så den kun inneholder de valgene som skal gjøres når de senere valgene legges til
            $fremtidigeValg = ""

            # Legger til de fremtidige valgene som skal gjøres
            if ($fremtidigeMenyValg.Count -eq 2) {
                # Hvis det barae er et valg, så legges dette valget inn i stringen
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {
                #Hvis det er flere valg som skal gjøres, så legges de første valgene inn foran i stringen, med et komma foran, før det siste legges til uten et komma før seg
                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    #De første valgene legges inn, fra siste valget som skal gjøres, til neest siste valget som senere skal gjøres, tallene legges til i starten stringer som skal innholde fremtidige valg
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }
                # Siste valget som skal gjøres i fremtiden legges inn, uten at det legges til et komma foran
                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            # Hvis listen over fremtidige valg kunn inneholdt et element, så sendes det med en tom string videre
            $fremtidigeValg = ""
        }
    }

    

    # Valget som er gjort i denne menyen legges til i historikken som sendes videre, dette gjørers som nevnt tidligere, slik at tilbakefunksjonaliteten skal fungere
    if ($valgGjort.Length -ge 1) {
        #Hvis historikken allerede inneholder et element, så legges vaglet for denne menyen til i starten av stringen, men et komma mellom valget, og stringen som inneholder hostorikken
        $valgGjort = $valgGjort + "," + [string]$valg
    } else {
        # Hvis det ikke er gjort noen tidligere valg, så legges valget som er gjort i denne menyen inn i en string som ikke skal inneholde noe annet
        $valgGjort = [string]$valg
    }


    # Valget som er gjort slåes opp i denne switch funksjonen, og valgets tilhørende kode utføres
    switch ([int]$valg) {
        0 {
            Clear-Host
            Get-BrukerMeny
        }
        1 {
            Clear-Host
            Get-DeltPostboksMeny
        }
        2 {
            Clear-Host
            Get-KontaktListeMeny
        }
        3 {
            # Hvis man ønsker å avslutte, så fjernes innholdet i konsollvinduet, og whileløkken som sørger for å vise menyen hver gang en funksjon har kjørt ferdig, avsluttes, slik at skriptet avsluttes
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {# Skulle koden som sjekket om valget som er sendt inn slippe igjennom et valg som ikke stemmer, så skrives det ut en advarsel og koden sender brukeren tilbake til hovedmenyen
            # Det skrives ut en feilmelding i rødt
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            # Menyelementene det kunne velges mellom vises og, disse skrives ut i gul skrift
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            # Skriptet settes på pause slik at brukeren kan få med seg feilmeldingen som er skrevet ut
            Pause

            Get-Hovedmeny
        }
    }
}

function Get-BrukerMeny() {
    
    # Paramterene, $fremtidsvalg inneholder valg som skal gjøres, mens $valgGjort inneholder en historikk, begge to er stringer som inneholder tall, adskilt med komma
    # Disse to parameterene brukes for å kunne tilby tilbake valget i menyen
    param([string]$fremtidigeValg,[string]$valgGjort)

    # Fjerner tidligere utskrift fra konsollen, slik at brukeren får en ryddig meny
    Clear-Host

    # Boolsk verdi som brukes for å kontrollere at parameterene som er gitt, kunn inneholder tall, adskilt med komma
    [bool]$isRetteParametere = $true
    
    # Dette er en array som inneholder teksten på de forskjellige menyvalgene
    $menyElementer = @("Legg til bruker","Legg til bruker(e) fra CVS fil","Legg rettighet til brukerkonto","Fjern rettighet til brukerkonto","Slett e-postkonto","Slett domenebruker","Tilbake","Til hovedmeny", "Avslutt")

    # Dette er variablen som brukes for å lagre menyvalget brukeren gjør
    [int]$valg = 0

    # Dette er variablen som brukes for å lagre valgene som skal gjøres i neste nivå av menyene
    $fremtidigeMenyValg = @()

    # Disse to variablene inneholder de to tilsendte variablene, men konveterer dem fra stringer til arrays for å gjøre dem enkelere å jobbe med
    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","

    # Denne løkken går igjennom innholdet i $fremtidigeValtSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $fremtidigeValgSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Denne løkken går igjennom innholdet i $valgGjortSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Hvis et element i $valgGjortSplittet eller $fremtidigeValtSplittet ikke er et tall, så vil koden videre gå utifra at det ikke er sendt ved noen paramentere til menyen, og det skrives ut en advarsel om dette
    if(!$isRetteParametere) {
        #Parameterene "nullstilles"
        $fremtidigeValg = ""
        $valgGjort = ""
        
        #det skrives ut en advarsel, og programmet settes på pause, slik at brukeren får anledning til å lese feilmeldingen før den viskes vekk av en CLear-Host senere i skriptet
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer bestående av tall, adskilt med komma.`nGår videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
        Pause
    }

    # Denne ifsettnigen sjekket om det er sendt ved en liste med valg som skal gjøres, hvis listen er tom, så spør den brukeren om hvilket valg som skal gjøres
    # Hvis listen med valg som skal gjøres ikke er tom, hentes valget ut fra listen, og fjernes fra listen
    if ($fremtidigeValg.Length -eq 0) {
        # spør brukeren som hvilket valg som skal bli gjort
        $valg = Get-Menyvalg $menyElementer
    } else {
        # Gjør stringen, som inneholder valgene som skal gjøres, om til en array som er enklere å jobbe videre med
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        # Henter ut valget som skal gjøres
        $valg = [int]$fremtidigeMenyValg[0]
        
        # I denne ifsettnigen fjernes valget som er gjort, og resten av arrayen gjøres om til en string som kan sendes videre,
        # hvis arrayen kun inneholder et element, så gjøres stringen som skal sendes videre om til en tom string
        if($fremtidigeMenyValg.Count -gt 1) {
            
            # Gjør stringen som skal sendes videre tom, så den kun inneholder de valgene som skal gjøres når de senere valgene legges til
            $fremtidigeValg = ""

            # Legger til de fremtidige valgene som skal gjøres
            if ($fremtidigeMenyValg.Count -eq 2) {
                # Hvis det barae er et valg, så legges dette valget inn i stringen
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {
                #Hvis det er flere valg som skal gjøres, så legges de første valgene inn foran i stringen, med et komma foran, før det siste legges til uten et komma før seg
                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    #De første valgene legges inn, fra siste valget som skal gjøres, til neest siste valget som senere skal gjøres, tallene legges til i starten stringer som skal innholde fremtidige valg
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }
                # Siste valget som skal gjøres i fremtiden legges inn, uten at det legges til et komma foran
                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            # Hvis listen over fremtidige valg kunn inneholdt et element, så sendes det med en tom string videre
            $fremtidigeValg = ""
        }
    }

    # Valget som er gjort i denne menyen legges til i historikken som sendes videre, dette gjørers som nevnt tidligere, slik at tilbakefunksjonaliteten skal fungere
    if ($valgGjort.Length -ge 1) {
        #Hvis historikken allerede inneholder et element, så legges vaglet for denne menyen til i starten av stringen, men et komma mellom valget, og stringen som inneholder hostorikken
        $valgGjort = $valgGjort + "," + [string]$valg
    } else {
        # Hvis det ikke er gjort noen tidligere valg, så legges valget som er gjort i denne menyen inn i en string som ikke skal inneholde noe annet
        $valgGjort = [string]$valg
    }

    # Valget som er gjort slåes opp i denne switch funksjonen, og valgets tilhørende kode utføres
    switch ([int]$valg) {
        0 {
            Clear-Host
            New-Postboks
            Pause
        }
        1 {
            Clear-Host
            New-PostboksCSV
            Pause
        }
        2 {
            Clear-Host
            Add-Brukerrettigheter
            Pause
        }
        3 {
            Clear-Host
            Remove-Brukerrettigheter
            Pause
        }
        4 {
            Clear-Host
            Delete-Epostkonto
            Pause
        }
        5 {
            Clear-Host
            Delete-Brukerkonto
            Pause
        }
        6 { # Dette er Tilbake valget, og grunnen til at funksjonen kan ta inn to variabler

            # Stringen som inneholder historikken splittes opp, og plasseres i en array for å gjøre det lettere å bearbeide den
            $fremtidigeMenyValg = $valgGjort -split ","

            # Det gjøres en sjekk på hvor mange valg som er gjort til nå, hvis det bare er gjort et, så sendes man rett tilbake til hovedmenyen
            if ($fremtidigeMenyValg.Count -gt 1) {
                write-host "valg gjort: " $valgGjort -ForegroundColor Green
                
                # Stringen som skal inneholde de fremtidige valgene som skal gjøres for å komme til menyen et hakk lengre opp i menyhireakiet en gjellende meny
                $fremtidigeValg = ""

                # I denne if settningen legges alle utenom de to siste valgene som er gjort (valget som ført frem til gjellende meny, og valget om å gå tilbake) inn i en string som forteller hvilke valg som skal gjøres for å komme til forrige meny
                if($fremtidigeMenyValg.Count -gt 2) {
                    
                    # Stringen som inneholder valgene som skal gjøres, tømmes før den fylles opp igjen
                    $fremtidigeValg = ""

                    # Fremtidige valg legges inn i stringen
                    if ($fremtidigeMenyValg.Count -eq 3) {
                        # Hvis det bare er et valg som skal gjøres, legges den rett inn i stringen, uten å legge til noe komma i tilleg
                       $fremtidigeValg = [string]$fremtidigeMenyValg[0]
                    } else {
                        # Hvis det skal gjøres flere valg, så legges de førest inn i starten av stringen, med et komma foran seg
                        for ($i=($fremtidigeMenyValg.Count-3);$i -gt 0;$i--) {
                            # Valgene legges inn i starten av stringen, og det legges til et komma først i stringen
                            $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i] + $fremtidigeValg
                        }
                        # Siste valget legges inn uten et komma
                        $fremtidigeValg = [string]$fremtidigeMenyValg[0] + $fremtidigeValg
                    }
                }
                write-host "fermtidige valg: " $fremtidigeValg -ForegroundColor Green
                pause
                # Valgene som skal gjøres for å gå tilbake til forrige meny sendes til hovedmenyen, med en tom historikk
                Get-Hovedmeny "$fremtidigeValg" ""
                
            } else {
                # Hvis det bare et gjort et valg, så skal brukeren sendes til hovedmenyen
                Get-Hovedmeny
            }
        }
        7 {
            # Hvis brukeren ønsker å gå tilbake til hovedmenyen, så sendes man tilbake til hovedmenyen, uten historikken om hvilke valg som er gjort til nå
            Get-Hovedmeny
        }
        8 {
            # Hvis man ønsker å avslutte, så fjernes innholdet i konsollvinduet, og whileløkken som sørger for å vise menyen hver gang en funksjon har kjørt ferdig, avsluttes, slik at skriptet avsluttes
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {# Skulle koden som sjekket om valget som er sendt inn slippe igjennom et valg som ikke stemmer, så skrives det ut en advarsel og koden sender brukeren tilbake til hovedmenyen
            # Det skrives ut en feilmelding i rødt
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            # Menyelementene det kunne velges mellom vises og, disse skrives ut i gul skrift
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            # Skriptet settes på pause slik at brukeren kan få med seg feilmeldingen som er skrevet ut
            Pause
            # Returnerer til hovedmenyen
            Get-Hovedmeny
        }
    }
}

function Get-DeltPostboksMeny() {
    
    # Paramterene, $fremtidsvalg inneholder valg som skal gjøres, mens $valgGjort inneholder en historikk, begge to er stringer som inneholder tall, adskilt med komma
    # Disse to parameterene brukes for å kunne tilby tilbake valget i menyen
    param([string]$fremtidigeValg,[string]$valgGjort)

    # Fjerner tidligere utskrift fra konsollen, slik at brukeren får en ryddig meny
    Clear-Host

    # Boolsk verdi som brukes for å kontrollere at parameterene som er gitt, kunn inneholder tall, adskilt med komma
    [bool]$isRetteParametere = $true
    
    # Dette er en array som inneholder teksten på de forskjellige menyvalgene
    $menyElementer = @("Opprett delt postpoks","Legg til rettigheter til delt postboks","Fjern rettigheter til delt postboks","Slett delt postboks","List delte postbokser","Tilbake","Til hovedmeny", "Avslutt")

    # Dette er variablen som brukes for å lagre menyvalget brukeren gjør
    [int]$valg = 0

    # Dette er variablen som brukes for å lagre valgene som skal gjøres i neste nivå av menyene
    $fremtidigeMenyValg = @()

    # Disse to variablene inneholder de to tilsendte variablene, men konveterer dem fra stringer til arrays for å gjøre dem enkelere å jobbe med
    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","


    # Denne løkken går igjennom innholdet i $fremtidigeValtSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $fremtidigeValgSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Denne løkken går igjennom innholdet i $valgGjortSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Hvis et element i $valgGjortSplittet eller $fremtidigeValtSplittet ikke er et tall, så vil koden videre gå utifra at det ikke er sendt ved noen paramentere til menyen, og det skrives ut en advarsel om dette
    if(!$isRetteParametere) {
        #Parameterene "nullstilles"
        $fremtidigeValg = ""
        $valgGjort = ""
        
        #det skrives ut en advarsel, og programmet settes på pause, slik at brukeren får anledning til å lese feilmeldingen før den viskes vekk av en CLear-Host senere i skriptet
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer bestående av tall, adskilt med komma.`nGår videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
        Pause
    }

    # Denne ifsettnigen sjekket om det er sendt ved en liste med valg som skal gjøres, hvis listen er tom, så spør den brukeren om hvilket valg som skal gjøres
    # Hvis listen med valg som skal gjøres ikke er tom, hentes valget ut fra listen, og fjernes fra listen
    if ($fremtidigeValg.Length -eq 0) {
        # spør brukeren som hvilket valg som skal bli gjort
        $valg = Get-Menyvalg $menyElementer
    } else {
        # Gjør stringen, som inneholder valgene som skal gjøres, om til en array som er enklere å jobbe videre med
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        # Henter ut valget som skal gjøres
        $valg = [int]$fremtidigeMenyValg[0]
        
        # I denne ifsettnigen fjernes valget som er gjort, og resten av arrayen gjøres om til en string som kan sendes videre,
        # hvis arrayen kun inneholder et element, så gjøres stringen som skal sendes videre om til en tom string
        if($fremtidigeMenyValg.Count -gt 1) {
            
            # Gjør stringen som skal sendes videre tom, så den kun inneholder de valgene som skal gjøres når de senere valgene legges til
            $fremtidigeValg = ""

            # Legger til de fremtidige valgene som skal gjøres
            if ($fremtidigeMenyValg.Count -eq 2) {
                # Hvis det barae er et valg, så legges dette valget inn i stringen
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {
                #Hvis det er flere valg som skal gjøres, så legges de første valgene inn foran i stringen, med et komma foran, før det siste legges til uten et komma før seg
                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    #De første valgene legges inn, fra siste valget som skal gjøres, til neest siste valget som senere skal gjøres, tallene legges til i starten stringer som skal innholde fremtidige valg
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }
                # Siste valget som skal gjøres i fremtiden legges inn, uten at det legges til et komma foran
                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            # Hvis listen over fremtidige valg kunn inneholdt et element, så sendes det med en tom string videre
            $fremtidigeValg = ""
        }
    }

    

    # Valget som er gjort i denne menyen legges til i historikken som sendes videre, dette gjørers som nevnt tidligere, slik at tilbakefunksjonaliteten skal fungere
    if ($valgGjort.Length -ge 1) {
        #Hvis historikken allerede inneholder et element, så legges vaglet for denne menyen til i starten av stringen, men et komma mellom valget, og stringen som inneholder hostorikken
        $valgGjort = $valgGjort + "," + [string]$valg
    } else {
        # Hvis det ikke er gjort noen tidligere valg, så legges valget som er gjort i denne menyen inn i en string som ikke skal inneholde noe annet
        $valgGjort = [string]$valg
    }


    # Valget som er gjort slåes opp i denne switch funksjonen, og valgets tilhørende kode utføres
    switch ([int]$valg) {
        0 {
            Clear-Host
            New-DeltPostboks
            Pause
        }
        1 {
            Clear-Host
            Add-BrukerRettighetTilDeltPostboks
            Pause
        }
        2 {
            Clear-Host
            Remove-BrukerRettighetFraDeltPostboks
            Pause
        }
        3 {
            Clear-Host
            Remove-DeltPostboks
            Pause
        }
        4{
            Clear-Host
            List-DeltPostboks
            Pause
        }
        5 { # Dette er Tilbake valget, og grunnen til at funksjonen kan ta inn to variabler
            
            # Stringen som inneholder historikken splittes opp, og plasseres i en array for å gjøre det lettere å bearbeide den
            $fremtidigeMenyValg = $valgGjort -split ","

            # Det gjøres en sjekk på hvor mange valg som er gjort til nå, hvis det bare er gjort et, så sendes man rett tilbake til hovedmenyen
            if ($fremtidigeMenyValg.Count -gt 1) {
                
                # Stringen som skal inneholde de fremtidige valgene som skal gjøres for å komme til menyen et hakk lengre opp i menyhireakiet en gjellende meny
                $fremtidigeValg = ""

                # I denne if settningen legges alle utenom de to siste valgene som er gjort (valget som ført frem til gjellende meny, og valget om å gå tilbake) inn i en string som forteller hvilke valg som skal gjøres for å komme til forrige meny
                if($fremtidigeMenyValg.Count -gt 2) {
                    
                    # Stringen som inneholder valgene som skal gjøres, tømmes før den fylles opp igjen
                    $fremtidigeValg = ""

                    # Fremtidige valg legges inn i stringen
                    if ($fremtidigeMenyValg.Count -eq 3) {
                        # Hvis det bare er et valg som skal gjøres, legges den rett inn i stringen, uten å legge til noe komma i tilleg
                       $fremtidigeValg = [string]$fremtidigeMenyValg[0]
                    } else {
                        # Hvis det skal gjøres flere valg, så legges de førest inn i starten av stringen, med et komma foran seg
                        for ($i=($fremtidigeMenyValg.Count-3);$i -gt 0;$i--) {
                            # Valgene legges inn i starten av stringen, og det legges til et komma først i stringen
                            $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i] + $fremtidigeValg
                        }
                        # Siste valget legges inn uten et komma
                        $fremtidigeValg = [string]$fremtidigeMenyValg[0] + $fremtidigeValg
                    }
                }

                # Valgene som skal gjøres for å gå tilbake til forrige meny sendes til hovedmenyen, med en tom historikk
                Get-Hovedmeny "$fremtidigeValg" ""
                
            } else {
                # Hvis det bare et gjort et valg, så skal brukeren sendes til hovedmenyen
                Get-Hovedmeny
            }
        }
        6 {
            # Hvis brukeren ønsker å gå tilbake til hovedmenyen, så sendes man tilbake til hovedmenyen, uten historikken om hvilke valg som er gjort til nå
            Get-Hovedmeny
        }
        7 {
            # Hvis man ønsker å avslutte, så fjernes innholdet i konsollvinduet, og whileløkken som sørger for å vise menyen hver gang en funksjon har kjørt ferdig, avsluttes, slik at skriptet avsluttes
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {# Skulle koden som sjekket om valget som er sendt inn slippe igjennom et valg som ikke stemmer, så skrives det ut en advarsel og koden sender brukeren tilbake til hovedmenyen
            # Det skrives ut en feilmelding i rødt
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            # Menyelementene det kunne velges mellom vises og, disse skrives ut i gul skrift
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            # Skriptet settes på pause slik at brukeren kan få med seg feilmeldingen som er skrevet ut
            Pause

            Get-Hovedmeny
        }
    }
}

function Get-KontaktListeMeny() {
    
    # Paramterene, $fremtidsvalg inneholder valg som skal gjøres, mens $valgGjort inneholder en historikk, begge to er stringer som inneholder tall, adskilt med komma
    # Disse to parameterene brukes for å kunne tilby tilbake valget i menyen
    param([string]$fremtidigeValg,[string]$valgGjort)

    # Fjerner tidligere utskrift fra konsollen, slik at brukeren får en ryddig meny
    Clear-Host

    # Boolsk verdi som brukes for å kontrollere at parameterene som er gitt, kunn inneholder tall, adskilt med komma
    [bool]$isRetteParametere = $true
    
    # Dette er en array som inneholder teksten på de forskjellige menyvalgene
    $menyElementer = @("Ny kontaktliste/distribuertgruppe","Legg til bruker i kontaktliste","Fjern bruker fra kontaktliste","Slett kontaktliste","List medlemer i kontaktliste","Tilbake","Til hovedmeny", "Avslutt")

    # Dette er variablen som brukes for å lagre menyvalget brukeren gjør
    [int]$valg = 0

    # Dette er variablen som brukes for å lagre valgene som skal gjøres i neste nivå av menyene
    $fremtidigeMenyValg = @()

    # Disse to variablene inneholder de to tilsendte variablene, men konveterer dem fra stringer til arrays for å gjøre dem enkelere å jobbe med
    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","


    # Denne løkken går igjennom innholdet i $fremtidigeValtSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $fremtidigeValgSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Denne løkken går igjennom innholdet i $valgGjortSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Hvis et element i $valgGjortSplittet eller $fremtidigeValtSplittet ikke er et tall, så vil koden videre gå utifra at det ikke er sendt ved noen paramentere til menyen, og det skrives ut en advarsel om dette
    if(!$isRetteParametere) {
        #Parameterene "nullstilles"
        $fremtidigeValg = ""
        $valgGjort = ""
        
        #det skrives ut en advarsel, og programmet settes på pause, slik at brukeren får anledning til å lese feilmeldingen før den viskes vekk av en CLear-Host senere i skriptet
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer bestående av tall, adskilt med komma.`nGår videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
        Pause
    }

    # Denne ifsettnigen sjekket om det er sendt ved en liste med valg som skal gjøres, hvis listen er tom, så spør den brukeren om hvilket valg som skal gjøres
    # Hvis listen med valg som skal gjøres ikke er tom, hentes valget ut fra listen, og fjernes fra listen
    if ($fremtidigeValg.Length -eq 0) {
        # spør brukeren som hvilket valg som skal bli gjort
        $valg = Get-Menyvalg $menyElementer
    } else {
        # Gjør stringen, som inneholder valgene som skal gjøres, om til en array som er enklere å jobbe videre med
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        # Henter ut valget som skal gjøres
        $valg = [int]$fremtidigeMenyValg[0]
        
        # I denne ifsettnigen fjernes valget som er gjort, og resten av arrayen gjøres om til en string som kan sendes videre,
        # hvis arrayen kun inneholder et element, så gjøres stringen som skal sendes videre om til en tom string
        if($fremtidigeMenyValg.Count -gt 1) {
            
            # Gjør stringen som skal sendes videre tom, så den kun inneholder de valgene som skal gjøres når de senere valgene legges til
            $fremtidigeValg = ""

            # Legger til de fremtidige valgene som skal gjøres
            if ($fremtidigeMenyValg.Count -eq 2) {
                # Hvis det barae er et valg, så legges dette valget inn i stringen
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {
                #Hvis det er flere valg som skal gjøres, så legges de første valgene inn foran i stringen, med et komma foran, før det siste legges til uten et komma før seg
                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    #De første valgene legges inn, fra siste valget som skal gjøres, til neest siste valget som senere skal gjøres, tallene legges til i starten stringer som skal innholde fremtidige valg
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }
                # Siste valget som skal gjøres i fremtiden legges inn, uten at det legges til et komma foran
                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            # Hvis listen over fremtidige valg kunn inneholdt et element, så sendes det med en tom string videre
            $fremtidigeValg = ""
        }
    }

    

    # Valget som er gjort i denne menyen legges til i historikken som sendes videre, dette gjørers som nevnt tidligere, slik at tilbakefunksjonaliteten skal fungere
    if ($valgGjort.Length -ge 1) {
        #Hvis historikken allerede inneholder et element, så legges vaglet for denne menyen til i starten av stringen, men et komma mellom valget, og stringen som inneholder hostorikken
        $valgGjort = $valgGjort + "," + [string]$valg
    } else {
        # Hvis det ikke er gjort noen tidligere valg, så legges valget som er gjort i denne menyen inn i en string som ikke skal inneholde noe annet
        $valgGjort = [string]$valg
    }


    # Valget som er gjort slåes opp i denne switch funksjonen, og valgets tilhørende kode utføres
    switch ([int]$valg) {
        0 {
            Clear-Host
            New-Kontaktliste
            Pause
        }
        1 {
            Clear-Host
            Add-KontoTilKontaktliste
            Pause
        }
        2 {
            Clear-Host
            Remove-BrukerFraKontaktliste
            Pause
        }
        3 {
            Clear-Host
            Remove-Kontaktliste
            Pause
        }
        4 {
            Clear-Host
            List-KontaktlisteMedlemmer
            Pause
        }
        5 { # Dette er Tilbake valget, og grunnen til at funksjonen kan ta inn to variabler
            
            # Stringen som inneholder historikken splittes opp, og plasseres i en array for å gjøre det lettere å bearbeide den
            $fremtidigeMenyValg = $valgGjort -split ","

            # Det gjøres en sjekk på hvor mange valg som er gjort til nå, hvis det bare er gjort et, så sendes man rett tilbake til hovedmenyen
            if ($fremtidigeMenyValg.Count -gt 1) {
                
                # Stringen som skal inneholde de fremtidige valgene som skal gjøres for å komme til menyen et hakk lengre opp i menyhireakiet en gjellende meny
                $fremtidigeValg = ""

                # I denne if settningen legges alle utenom de to siste valgene som er gjort (valget som ført frem til gjellende meny, og valget om å gå tilbake) inn i en string som forteller hvilke valg som skal gjøres for å komme til forrige meny
                if($fremtidigeMenyValg.Count -gt 2) {
                    
                    # Stringen som inneholder valgene som skal gjøres, tømmes før den fylles opp igjen
                    $fremtidigeValg = ""

                    # Fremtidige valg legges inn i stringen
                    if ($fremtidigeMenyValg.Count -eq 3) {
                        # Hvis det bare er et valg som skal gjøres, legges den rett inn i stringen, uten å legge til noe komma i tilleg
                       $fremtidigeValg = [string]$fremtidigeMenyValg[0]
                    } else {
                        # Hvis det skal gjøres flere valg, så legges de førest inn i starten av stringen, med et komma foran seg
                        for ($i=($fremtidigeMenyValg.Count-3);$i -gt 0;$i--) {
                            # Valgene legges inn i starten av stringen, og det legges til et komma først i stringen
                            $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i] + $fremtidigeValg
                        }
                        # Siste valget legges inn uten et komma
                        $fremtidigeValg = [string]$fremtidigeMenyValg[0] + $fremtidigeValg
                    }
                }

                # Valgene som skal gjøres for å gå tilbake til forrige meny sendes til hovedmenyen, med en tom historikk
                Get-Hovedmeny "$fremtidigeValg" ""
                
            } else {
                # Hvis det bare et gjort et valg, så skal brukeren sendes til hovedmenyen
                Get-Hovedmeny
            }
        }
        6 {
            # Hvis brukeren ønsker å gå tilbake til hovedmenyen, så sendes man tilbake til hovedmenyen, uten historikken om hvilke valg som er gjort til nå
            Get-Hovedmeny
        }
        7 {
            # Hvis man ønsker å avslutte, så fjernes innholdet i konsollvinduet, og whileløkken som sørger for å vise menyen hver gang en funksjon har kjørt ferdig, avsluttes, slik at skriptet avsluttes
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {# Skulle koden som sjekket om valget som er sendt inn slippe igjennom et valg som ikke stemmer, så skrives det ut en advarsel og koden sender brukeren tilbake til hovedmenyen
            # Det skrives ut en feilmelding i rødt
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            # Menyelementene det kunne velges mellom vises og, disse skrives ut i gul skrift
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            # Skriptet settes på pause slik at brukeren kan få med seg feilmeldingen som er skrevet ut
            Pause

            Get-Hovedmeny
        }
    }
}