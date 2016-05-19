# Denne funskjonen returnerer aliaset til en bruker med postboks
function Get-Epostkonto() {
    # Tar inn en string som beskriver hvilken bruker programvaren sp�r etter
    param([string]$spoereTekst)

    # Oppretter de variablene som skal brukes senre i koden
    $bruker = ""
    $oenskerAaFortsette = "n"
    $riktigBruker = ""

    # Denne do while l�kken kj�rer s� lenge brukeren ikke gir beskjed om at det var riktig bruker koden fant
    do {
        # Denne do while l�kken kj�rer s� lenge brukeren ikke er funnet, eller brukeren ikke lengre �nsker � fors�ke � finne en bruker
        do {
            # Denne variablen teller hvor mange ganger brukeren har fors�kt � finne en bruker, men ikke lykkes
            $count = 0
            do{
                # Skriver ut stringen som beskriver hva slags bruker det letes etter
                Write-Host $spoereTekst
                # Ber brukeren skrive inn noe som kan identifisere brukeren det sp�rres etter
                $entydig = Read-Host "Skriv inn et entydig alias p� det du skal finne"

                # Tester om det ble skret inn noe som kan brukes for � finne en bruker
                if($entydig -eq "") {
                    # Gir beskjed om at det m� skrives inne noe f�r enter trykkes
                    Write-Host "Du m� skrive inn noe f�r du trykker enter" -ForegroundColor Red
                } else {
                    #Sjekker om brukeren finnes. bruker inneholder $null hvis ikke brukere finnes
                    $bruker = Get-Mailbox $entydig -RecipientTypeDetails UserMailbox �ErrorAction SilentlyContinue | Select Alias | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String
                }
                # Tester om det ble funnet en bruker
                if($bruker -eq ""){
                    # Gir beskjed om at det ikke ble funnet en bruker
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                
                $count++
            # Sjekker om det er funnet en bruker, og at det er gjort f�rre enn 5 fors�k siden sist bruker ble spurt om brukeren �nsket � ikke gj�re flere fors�k
            } while(($bruker -eq "" -or $entydig -eq "") -and $count -lt 5)

            # Sjekker om det er funnet en bruker, hvis ikke blir brukeren spurt om brukeren �nsker � gi seg, hvis brukeren �snker � gi seg, s� 
            if($bruker -eq "") {
                # Brukeren blir spurt om han �snker � gi seg
                $oenskerAaFortsette = (Read-Host "Du ser ut til � ha gjort noen fors�k uten � lykkes, �nsker du � forsette? [y/n]").ToLower().Trim()
                # Hvis brukeren �snker � gi seg, s� returnerer koden til hovedmenyen
                if ($oenskerAaFortsette -ne "y") {
                    Break fortsettAdministrering
                }
            }

        # Sjekker at brukeren ikke er funnet enn�, og at brukeren �nsker � fortsette
        } while($bruker -eq "" -and $oenskerAaFortsette -eq "y")

        # Fjerner eventuell whitespace
        $bruker = $bruker.Trim().Replace("`n","").Replace("`r","")

        # Sp�r om det er riktig bruker som er funnet
        $riktigBruker = Read-Host "var det $bruker du s� etter? [y/n]"
        $riktigBruker = $riktigBruker.ToLower().Trim()
    
    # Tester om brukeren har gitt beskjed om at det er riktig brukre som er funnet
    } while ($riktigBruker -ne "y")

    # Returnerer brukeren som er funnet
    return $bruker
}