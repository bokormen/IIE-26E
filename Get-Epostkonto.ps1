function Get-Epostkonto() {
    param([string]$spoereTekst)

    $bruker = ""
    $oenskerAaFortsette = "n"
    $riktigBruker = ""

    do {
        do {
            $count = 0
            do{
                Write-Host $spoereTekst
                $entydig = Read-Host "Skriv inn et entydig alias p� det du skal finne"
                #Sjekker om elementet finnes. bruker inneholder $null hvis ikke brukere finnes
                $bruker = Get-Mailbox $entydig �ErrorAction SilentlyContinue | Select Alias | Format-Table -HideTableHeaders | Out-String

                if($bruker -eq ""){
                    Write-Host "Det du skrev inn gav ikke et resultat" -ForegroundColor Red
                }
                if($entydig -eq "") {
                    Write-Host "Du m� skrive inn noe f�r du trykker enter" -ForegroundColor Red
                }

                $count++
            } while(($bruker -eq "" -or $entydig -eq "") -and $count -lt 5)

            if($bruker -eq "") {
                $oenskerAaFortsette = Read-Host "Du ser ut til � ha gjort noen fors�k uten � lykkes, �nsker du � forsette? [y/n]"
                $oenskerAaFortsette = $oenskerAaFortsette.ToLower().Trim()
            }

        } while($bruker -eq "" -and $oenskerAaFortsette -eq "y")

        $bruker = $bruker.Trim().Replace("`n","").Replace("`r","")

        $riktigBruker = Read-Host "var det $bruker du s� etter? [y/n]"
        $riktigBruker = $riktigBruker.ToLower().Trim()

    } while ($riktigBruker -ne "y")

    return $bruker
}