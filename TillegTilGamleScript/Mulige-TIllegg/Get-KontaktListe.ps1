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