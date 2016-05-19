 # Denne funskjonen returnerer aliaset til en delt postboks
function Get-DeltPostboks() {
    # Tar inn en string som beskriver hvilken konto programvaren sp�r etter
    param([string]$spoereTekst)

    # Oppretter de variablene som skal brukes senre i koden
    $konto = ""
    $oenskerAaFortsette = "n"
    $riktigKonto = ""

    # Denne do while l�kken kj�rer s� lenge brukeren ikke gir beskjed om at det var riktig konto koden fant
    do {
        # Denne do while l�kken kj�rer s� lenge kontoen ikke er funnet, eller brukeren ikke lengre �nsker � fors�ke � finne en konto
        do {
            # Denne variablen teller hvor mange ganger brukeren har fors�kt � finne en konto, men ikke lykkes
            $count = 0
            do{
                # Skriver ut stringen som beskriver hva slags konto det letes etter
                Write-Host $spoereTekst
                # Ber brukeren skrive inn noe som kan identifisere kontoen det sp�rres etter
                $entydig = Read-Host "Skriv inn et entydig alias p� det du skal finne"

                # Tester om det ble skret inn noe som kan brukes for � finne en konto
                if($entydig -eq "") {
                    # Gir beskjed om at det m� skrives inne noe f�r enter trykkes
                    Write-Host "Du m� skrive inn noe f�r du trykker enter" -ForegroundColor Red
                } else {
                    #Sjekker om kontoen finnes. konto inneholder $null hvis ikke kontoen finnes
                    $konto = Get-Mailbox $entydig -RecipientTypeDetails sharedmailbox �ErrorAction SilentlyContinue | Select Alias | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String
                }
                # Tester om det ble funnet en konto
                if($konto -eq ""){
                    # Gir beskjed om at det ikke ble funnet en konto
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                
                $count++
            # Sjekker om det er funnet en konto, og at det er gjort f�rre enn 5 fors�k siden sist bruker ble spurt om brukeren �nsket � ikke gj�re flere fors�k
            } while(($konto -eq "" -or $entydig -eq "") -and $count -lt 5)

            # Sjekker om det er funnet en konto, hvis ikke blir brukeren spurt om brukeren �nsker � gi seg, hvis brukeren �snker � gi seg, s� avluttes s�ket, og hovedmenyen lastes
            if($konto -eq "") {
                # Brukeren blir spurt om han �snker � gi seg
                $oenskerAaFortsette = (Read-Host "Du ser ut til � ha gjort noen fors�k uten � lykkes, �nsker du � forsette? [y/n]").ToLower().Trim()
                # Hvis brukeren �snker � gi seg, s� returnerer koden til hovedmenyen
                if ($oenskerAaFortsette -ne "y") {
                    Break fortsettAdministrering
                }
            }

        # Sjekker at kontoen ikke er funnet enn�, og at brukeren �nsker � fortsette
        } while($konto -eq "" -and $oenskerAaFortsette -eq "y")

        # Fjerner eventuell whitespace
        $konto = $konto.Trim().Replace("`n","").Replace("`r","")

        # Sp�r om det er riktig konto som er funnet
        $riktigKonto = (Read-Host "var det $konto du s� etter? [y/n]").ToLower().Trim()
    
    # Tester om brukeren har gitt beskjed om at det er riktig konto som er funnet
    } while ($riktigKonto -ne "y")

    # Returnerer kontoen som er funnet
    return $konto
}