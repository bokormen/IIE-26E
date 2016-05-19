# Funksjonene tar inn en liste med valg, skriver dem ut, og sp�r brukeren hvilket valg brukeren �snker � gj�re, valget brukeren gj�r, valdieres, og returneres som en int
function Get-Menyvalg() {
    # Denne funksjoen tar inn en liste med stringer som beskriver valg som kan gj�res 
    param([string[]]$menyvalg)

    # Variablen som brukes for � skrive ut et tall som brukes for � velge menyelement
    [int]$i = 0

    # De ulike valgene listes ut med et tall foran hvert enkelt valg
    Foreach($mulighet in $menyvalg) {
        Write-Host $i ": " $mulighet
        $i++
    }

    # Brukeren blir bedt om � skrive inn valget sitt
    $valg = Read-Host -Prompt "Skriv inn valget ditt"
    # Denne variablen brukes sensere for � kontrollere at det er et helttall som er skrevet inn, og ikke et desimaltall
    $heltall = 0
    # Denne variablen brukes senere for � kontrollere om valget som er skrevet inn er et heltall og ikke et desimaltall
    $gyldigIntValg = $true
    
    # Denne do while l�kken kj�rer fremt til valget som er skrevet inn tilsvarer et menyelement
    do {
        # Denne while l�kken lister ut menyen p� nytt, og ber brukeren oppgi et valg s� lengre valget som blir gitt ikke tilsvarer et menyelement
        # Whilel�kken tester om valget som er gjort er en int, eller om valget var tomt, $gyldigIntValg brukes for � sjekke om brukeren har skrevet inn noe som er et desimaltall
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
            # Brukeren blir p� nytt bedt om � skrive inn valget sitt
            $valg = Read-Host "Skriv inn valget ditt: "
            # Antar at valget er et gyldig valg frem til det motsatte er bevist
            $gyldigIntValg = $true
        
        }
        # Runder av tallet til et haltall, valget som kommet ut av whilel�kken over er garantert � v�re et tall
        $heltall = [math]::Round($valg)
        # caster valget til en double verdi
        $valg=[double]$valg

        # Denne ifsettnignen sjekket om tallet som er skrevet inn er et heltall, og om dette heltallet er innenfor st�relsen av menyen
        if (($valg -ne $heltall) -or ($valg -lt 0) -or ($valg -ge ($menyvalg.Length))) {
            # Hvis ikke tallet som er gitt er et heltall, eller tallet havner utenfor st�rrelsen til menyen, s� er det ikke et tall som er gyldig
            $gyldigIntValg = $false
        }

    } while (!$gyldigIntValg)

    # Returnere en int som kan brukes for � plukke ut et menyvalg
    return [int]$valg
        
}