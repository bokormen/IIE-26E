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