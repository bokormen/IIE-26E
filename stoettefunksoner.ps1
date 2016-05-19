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