# Funksjonene tar inn en liste med valg, skriver dem ut, og spør brukeren hvilket valg brukeren øsnker å gjøre, valget brukeren gjør, valdieres, og returneres som en int
function Get-Menyvalg() {
    # Denne funksjoen tar inn en liste med stringer som beskriver valg som kan gjøres 
    param([string[]]$menyvalg)

    # Variablen som brukes for å skrive ut et tall som brukes for å velge menyelement
    [int]$i = 0

    # De ulike valgene listes ut med et tall foran hvert enkelt valg
    Foreach($mulighet in $menyvalg) {
        Write-Host $i ": " $mulighet
        $i++
    }

    # Brukeren blir bedt om å skrive inn valget sitt
    $valg = Read-Host -Prompt "Skriv inn valget ditt"
    # Denne variablen brukes sensere for å kontrollere at det er et helttall som er skrevet inn, og ikke et desimaltall
    $heltall = 0
    # Denne variablen brukes senere for å kontrollere om valget som er skrevet inn er et heltall og ikke et desimaltall
    $gyldigIntValg = $true
    
    # Denne do while løkken kjører fremt til valget som er skrevet inn tilsvarer et menyelement
    do {
        # Denne while løkken lister ut menyen på nytt, og ber brukeren oppgi et valg så lengre valget som blir gitt ikke tilsvarer et menyelement
        # Whileløkken tester om valget som er gjort er en int, eller om valget var tomt, $gyldigIntValg brukes for å sjekke om brukeren har skrevet inn noe som er et desimaltall
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
            # Brukeren blir på nytt bedt om å skrive inn valget sitt
            $valg = Read-Host "Skriv inn valget ditt: "
            # Antar at valget er et gyldig valg frem til det motsatte er bevist
            $gyldigIntValg = $true
        
        }
        # Runder av tallet til et haltall, valget som kommet ut av whileløkken over er garantert å være et tall
        $heltall = [math]::Round($valg)
        # caster valget til en double verdi
        $valg=[double]$valg

        # Denne ifsettnignen sjekket om tallet som er skrevet inn er et heltall, og om dette heltallet er innenfor størelsen av menyen
        if (($valg -ne $heltall) -or ($valg -lt 0) -or ($valg -ge ($menyvalg.Length))) {
            # Hvis ikke tallet som er gitt er et heltall, eller tallet havner utenfor størrelsen til menyen, så er det ikke et tall som er gyldig
            $gyldigIntValg = $false
        }

    } while (!$gyldigIntValg)

    # Returnere en int som kan brukes for å plukke ut et menyvalg
    return [int]$valg
        
}