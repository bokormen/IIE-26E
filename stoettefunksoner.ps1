# Denne funksjonen sp�r brukeren etter et fqdn p� en exchange server, den foresl�r � bruke verdien som blir sendt som et parameter
function Get-FqdnExchange() {
    # Tar inn en verdi som foresl�s som verdien som skal returneres
    param([string]$defaultExchangeNavn)

    # Sp�r brukeren etter et fqdn p� maskinen han �snker � koble til
    $exchangeNavn = Read-Host "Skriv inn FQDN p� Exchangeserveren som skal administreres, om det er et navn i [] som stemmer, trykk enter [$defaultExchangeNavn]"
    
    # Sjekker om verdien brukeren skrev inn er tom, hvis den er det, s� settes verdien til den foresl�tte verdien, gitt at ikke den og er tom
    if(($exchangeNavn -eq "") -and ($defaultExchangeNavn -ne "")) {
        $exchangeNavn = $defaultExchangeNavn
    }

    # Hvis verdien er tom n�r den kommer her, s� blir man bedt om � skrive inn en verdi, da skriptet ikke har klart � lokalisere en exchange server selv
    if ($exchangeNavn -eq "") {
        Write-Host "Skriptet har ikke klart � foresl� et navn p� en Exchange server for deg, s� du m� skrive inn et FQDN p� Exchange serveren du �nsker � administrere" -ForegroundColor Yellow
    }

    # Tar utganspunkt i at navnet brukeren har gitt, er skrevet korrekt
    $exchangeNavneSjekk = "y"

    # denne do while l�kken kj�rer s� lenge brukeren ikke er forn�yd med den verdien som er gitt
    do {
        # S� lenge fqdn navnet brukeren gir, er tomt, s� vil denne l�kken kj�re, og ber brukeren om � skrive inn et fqdn p� exchange serveren som skal adminsitreres
        while($exchangeNavn -eq "") {
            $exchangeNavn = Read-Host "Skriv inn et FQDN p� Exchange serveren du �nsker � administrere, du kan ikke la det v�re blankt"
        }

        # Sp�r brukeren om inputen som er gitt er riktig
        $exchangeNavneSjekk = (Read-Host "Stemmer det at det er $exchangeNavn som er Exchange serveren du �nsker � administrere? [y/n]").Trim().ToLower()

        # Hvis inputen som er registrert ikke er riktig, s� t�mmes stringen som inneholder navnet p� exchangeserveren, slik at funksjonen g�r inn i whilel�kken ovenfor igjen n�r den returnerer der
        if ($exchangeNavneSjekk -ne "y") {
            $exchangeNavn = ""
        }
    # Sjekker om fqdn som er gitt, er det som brukeren �nsker � bruke    
    } while ($exchangeNavneSjekk -ne "y")

    # returnerer fqdn p� en exchange server
    return $exchangeNavn
}

# Denne funksjonen sp�r brukeren etter et fqdn p� en domenekontroller, den foresl�r � bruke verdien som blir sendt som et parameter
function Get-FqdnDomeneKontroller() {
    # Tar inn en verdi som foresl�s som verdien som skal returneres
    param([string]$defaultDomeneKontrollerNavn)

    # Sp�r brukeren etter et fqdn p� maskinen han �snker � koble til
    $domeneKontrollerNavn = Read-Host "Skriv inn FQDN p� domene kontrolleren som skal administreres, om det er et navn i [] som stemmer, trykk enter [$defaultDomeneKontrollerNavn]"

    # Sjekker om verdien brukeren skrev inn er tom, hvis den er det, s� settes verdien til den foresl�tte verdien, gitt at ikke den og er tom
    if(($domeneKontrollerNavn -eq "") -and ($defaultDomeneKontrollerNavn -ne "")) {
        $domeneKontrollerNavn = $defaultDomeneKontrollerNavn
    }

    # Hvis verdien er tom n�r den kommer her, s� blir man bedt om � skrive inn en verdi, da skriptet ikke har klart � lokalisere en domenekontroller selv
    if ($domeneKontrollerNavn -eq "") {
        Write-Host "Skriptet har ikke klart � foresl� et navn p� en domene kontroller for deg, s� du m� skrive inn et FQDN p� domene kontrolleren du �nsker � administrere" -ForegroundColor Yellow
    }

    # Tar utganspunkt i at navnet brukeren har gitt, er skrevet korrekt
    $domeneKontrollerNavneSjekk = "y"

    # denne do while l�kken kj�rer s� lenge brukeren ikke er forn�yd med den verdien som er gitt
    do {

        # S� lenge fqdn navnet brukeren gir, er tomt, s� vil denne l�kken kj�re, og ber brukeren om � skrive inn et fqdn p� domenekontrolleren det skal kobles til
        while($domeneKontrollerNavn -eq "") {
            $domeneKontrollerNavn = Read-Host "Skriv inn et FQDN p� domene kontrolleren du �nsker � administrere, du kan ikke la det v�re blankt"
        }

        # Sp�r brukeren om inputen som er gitt er riktig
        $domeneKontrollerNavneSjekk = (Read-Host "Stemmer det at det er $domeneKontrollerNavn som er domene kontrolleren du �nsker � administrere? [y/n]").Trim().ToLower()

        # Hvis inputen som er registrert ikke er riktig, s� t�mmes stringen som inneholder navnet p� en domenekontroller, slik at funksjonen g�r inn i whilel�kken ovenfor igjen n�r den returnerer der
        if ($domeneKontrollerNavneSjekk -ne "y") {
            $domeneKontrollerNavn = ""
        }
        
    # Sjekker om fqdn som er gitt, er det som brukeren �nsker � bruke    
    } while ($domeneKontrollerNavneSjekk -ne "y")

    # returnerer fqdn p� en domenekontroller
    return $domeneKontrollerNavn
}

# denne funksjonen sp�r brukeren etter porten som brukes for � koble til domenekontrollren, den foresl�r standarporten
function Get-FjernadministreringsPort() {
    # paramteret skal v�re en tallverdi som er standarporten for fjernstilkobling til powershell
    param([string]$defaultPort)

    # Sp�r brukeren etter et protnummer som skal brukes, foresl�r � bruke standardporten
    $port = Read-Host "Skriv inn portnummer til domene kontrolleren som skal administreres, om portnummeret i [] stemmer, trykk enter [$defaultPort]"

    # Hvis inpurten fra brukeren er tom, s� brukes standarporten
    if($port -eq "") {
        $port = $defaultPort
    }
    # Variablen som brukes for � sjekke om brukeren mener valget han har gjort er rett
    $portSjekk = "n"

    # Denne l�kken kj�rer frem til brukeren er forn�yd med det valget som er gjort
    do {
        # Denne while l�kken kj�rer til inputen som blir gitt er et tall
        While(![bool]($port -as [int] -is [int])) {
            Write-Host "Portnummeret m� v�re et tall" -ForegroundColor Yellow
            $port = Read-Host "Skriv inn portnummer til domene kontrolleren som skal administreres, om portnummeret i [] stemmer, trykk enter [$defaultPort]"
            # Hvis inputen er tom, s� settes verdien til standerverdien
            if($port -eq "") {
                $port = $defaultPort
            }
        }
        # Sjekker om brukeren mener inputen som er gitt er korrekt
        $portSjekk = (Read-Host "Stemmer det at det er port:$port som brukes for � kontakte domene kontrolleren du �nsker � administrere? [y/n]").Trim().ToLower()

        # Hvis ikke brukeren er forn�yd, s� setter portnummeret til en verdie som s�rger for at den g�r inn i whilel�kken ovenfor
        if ($portSjekk -ne "y") {
            $port = "i"
        }
    # Sjekker om brukeren er forn�yd med den verdien han har gitt
    } while($portSjekk -ne "y")

    # Returnerer et portnummer
    return $port

}