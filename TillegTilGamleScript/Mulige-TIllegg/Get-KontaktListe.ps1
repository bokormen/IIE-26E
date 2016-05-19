# Denne funskjonen returnerer navnet til en kontaktliste
function Get-Kontaktliste() {
    # Tar inn en string som beskriver hvilken liste programvaren sp�r etter
    param([string]$spoereTekst)

    # Oppretter de variablene som skal brukes senre i koden
    $liste = ""
    $oenskerAaFortsette = "n"
    $riktigListe = ""

    # Denne do while l�kken kj�rer s� lenge brukeren ikke gir beskjed om at det var riktig liste koden fant
    do {
        # Denne do while l�kken kj�rer s� lenge listen ikke er funnet, eller brukeren ikke lengre �nsker � fors�ke � finne en liste
        do {
            # Denne variablen teller hvor mange ganger brukeren har fors�kt � finne en liste, men ikke lykkes
            $count = 0
            do{
                # Skriver ut stringen som beskriver hva slags liste det letes etter
                Write-Host $spoereTekst
                # Ber brukeren skrive inn noe som kan identifisere listen det sp�rres etter
                $entydig = Read-Host "Skriv inn et entydig navn p� det du skal finne"

                # Tester om det ble skret inn noe som kan brukes for � finne en liste
                if($entydig -eq "") {
                    # Gir beskjed om at det m� skrives inne noe f�r enter trykkes
                    Write-Host "Du m� skrive inn noe f�r du trykker enter" -ForegroundColor Red
                } else {
                    #Sjekker om listen finnes. liste tom string hvis ikke listen finnes
                    $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$entydig`"}")
                    $liste = (Invoke-Command -ScriptBlock $scriptblock �ErrorAction SilentlyContinue  | Select Name | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Trim()
                }
                # Tester om det ble funnet en liste
                if($liste -eq ""){
                    # Gir beskjed om at det ikke ble funnet en liste
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                
                $count++
            # Sjekker om det er funnet en liste, og at det er gjort f�rre enn 5 fors�k siden sist bruker ble spurt om brukeren �nsket � ikke gj�re flere fors�k
            } while(($liste -eq "" -or $entydig -eq "") -and $count -lt 5)

            # Sjekker om det er funnet en liste, hvis ikke blir brukeren spurt om brukeren �nsker � gi seg, hvis brukeren �snker � gi seg, s� avluttes s�ket, og hovedmenyen lastes
            if($liste -eq "") {
                # Brukeren blir spurt om han �snker � gi seg
                $oenskerAaFortsette = (Read-Host "Du ser ut til � ha gjort noen fors�k uten � lykkes, �nsker du � forsette? [y/n]").ToLower().Trim()
                # Hvis brukeren �snker � gi seg, s� returnerer koden til hovedmenyen
                if ($oenskerAaFortsette -ne "y") {
                    Break fortsettAdministrering
                }
            }

        # Sjekker at listen ikke er funnet enn�, og at brukeren �nsker � fortsette
        } while($liste -eq "" -and $oenskerAaFortsette -eq "y")

        # Fjerner eventuell whitespace
        $liste = $liste.Trim().Replace("`n","").Replace("`r","")

        # Sp�r om det er riktig liste som er funnet
        $riktigListe = (Read-Host "var det $liste du s� etter? [y/n]").ToLower().Trim()
    
    # Tester om brukeren har gitt beskjed om at det er riktig liste som er funnet
    } while ($riktigListe -ne "y")

    # Returnerer listen som er funnet
    return $liste
}