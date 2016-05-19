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