# Funksjonen gir en bruker rettighet(er) til en annen postboks
function Add-Rettigheter() {
    
    # Funksjonen tar inn to stringer, som hver er et alias som beksriver en bruker og en konto
    param([string]$bruker,[string]$konto)

    # Får tak i en liste over hvilke rettigheter brukeren alt har, som jeg legger inn i en arraylist for å gjøre det enklere å bearbeide
    $rettigheter = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Liste over hvilke rettigheter brukeren kan bli gitt, inkluderer et valg om å ikke gjøre noen endringer
    $tilgjengeligeRettigher = [System.Collections.ArrayList]@("FullAccess","SendAs","SendOnBehalfOf","Ønsker ikke å legge til en ny rettighet")

    # Trimmer listen over hvilke rettigheter som kan bli gitt, slik at den ikke inneholder rettigheter brukeren alt har
    foreach ($rettighet in $rettigheter) {
        $tilgjengeligeRettigher.Remove($rettighet) | Out-Null
    }

    
    # Skriver ut en liste over hvilke rettigheter brukeren alt har til kontoen
    if($rettigheter.Count -gt 0) {
        Write-Host "Rettigheter $bruker allerede har til kontoen $konto :"
        foreach($rettighet in $rettigheter) {
            Write-Host "    - $rettighet"
        }
    }

    # Lister ut hvilke rettigheter brukeren kan tildeles kontoen, samt en tallverdi foran rettighene som representerer rettigheten når den senre kan bli valgt
    # Hvis ikke det er flere rettigheter å tildele, så skrives det ut en beskjed om det
    if($tilgjengeligeRettigher.Count -gt 1) {
        # Her skrives listen over tilgjendelige rettigheter ut
        Write-Host "`n`nRettigheter $bruker kan bli gitt til kontoen $konto :"
        $i = 0
        foreach($rettighet in $tilgjengeligeRettigher) {
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        # Her skrives beskjeden om at det ikke er mulig å tildele flere rettigheter ut
        Write-Host "`n`n$bruker kan ikke bli gitt flere rettigheter til kontoen $konto `n"
        Pause
        # Her går skriptet ut av denne funksjonen, da det ikke er mer å gjøre
        Return
    }

    # Variabel som brukes for å kontrollere at alle valgene som skrives inn er gyldige valg
    $erRetteVerdier = [boolean]$true
    # String som inneholder de nye rettighetene som skal legges til, adskilt med komma
    $nyeRettigheter = ""

    # Denne do while løkka sjekket at det som skrives inn er gyldige verdier
    do {
        # Valgene som er gjort, er gyldige til det motsatte er bevist
        $erRetteVerdier = [boolean]$true

        # Ber brukeren skive inn hvilke rettigheter brukeren ønsker å gi, det kan legges til flere rettigheter, men da må de adskilles med komma
        $nyeRettigheter = Read-Host "`n`nSkriv inn nummeret som står før rettigheten du ønsker å gi $bruker til kontoen $konto`nOm du ønsker å tildele flere rettigheter, så kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene på rettigheten(e) du ønsker å gi"

        # Fjerner "whitespace"
        $nyeRettigheter.Trim(" ") | Out-Null

        # legger valgene inn i en array
        $nyeRettigheter = [System.Collections.ArrayList]$nyeRettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        # fjerner alle doble valg
        $temp = $nyeRettigheter | Get-Unique

        # sjekker at brukeren har gitt en verdi, og ikke bare har trykket enter uten å skrive inn noe
        if($nyeRettigheter.Count -eq 0) {
            # Skriver ut en beskjed om at tomt valg ikek er en mulighet, og setter verdien $erRetteVerdier til false for å indikere at vi ikke har fått noe som kan jobbes videre med og det må spørres på nytt
            Write-Host "Du kan ikke bare trykke på enter, du måt gjøre et valg, om du øsnker å avslutte, kan du skrive inn" ($tilgjengeligeRettigher.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false
        # Sjekker at en rettighet ikke er skrevet inn to ganger, har valgt å ikke tillate det, hvis et valg ikke er oppgitt to ganger, så sjekker jeg at alle valgene er tall
        } elseif($temp.count -eq $nyeRettigheter.Count) {
            
            # Går igjennom alle valgene og sjekket at det er tall som tilsvarer menyelementene
            foreach($valg in $nyeRettigheter) {
                # Sjekker om valget er er tall
                if(![boolean]($valg -as [int] -is [int])) {
                    # skriver ut en advarsel om at valget ikke er et tall, og setter verdien $erRetteVerdier til false
                    Write-Host "$valg er ikke et tall, du må liste opp rettighetene du ønsker å tildele på nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                    Break

                } else {
                    # caster valget til int
                    $valg = [int]$valg

                    # Sjekket om valget er innenfor de verdiene som menyen inneholder
                    if(($valg -lt 0) -or ($valg -ge $tilgjengeligeRettigher.Count)) {
                        # Skriver ut en advarsel om at valget ikke er innenfor de verdiene som menyen inneholder, og setter verdien $erRetteVerdier til false
                        Write-Host "$valg er ikke er tall mellom 0 og" ($tilgjengeligeRettigher.Count-1) ", du må skrive inn valgene på nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break

                    # Sjekker om valget som er gjort er å ikke legge til flere rettigheter, samtidig som det er gjort flere andre valg også, da det ikke gir mening
                    } elseif (($valg -eq ($tilgjengeligeRettigher.Count-1)) -and ($nyeRettigheter.Count -gt 1)) {
                        # Skriver ut en advarsel om at valget ikke er logisk, og setter verdien $erRetteVerdier til false
                        Write-Host "Du kan ikke legge til rettigheter, og samtidig gjøre valget:" $tilgjengeligeRettigher[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($tilgjengeligeRettigher.Count-2) "separert med komma, eller bare" ($tilgjengeligeRettigher.Count-1)  -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break

                    }
                }
            }
        } else {
            # Gir beskjed om at det ikke er lov å liste opp en verdi to ganger, og setter $erRetteVerdier til false
            Write-Host "Du kan kunn skrive inn unike verdier, separert med komma, du kan ikke liste opp en rettighet to ganger" -ForegroundColor Red
            $erRetteVerdier = $false

        }
    # sjekker om det er riktige verdier som er skrevet inn, hvis ikke, så går løkken gjennom prosessen med å få valgene fra brukeren på nytt
    } while (!$erRetteVerdier)

    # Hvis valget er å ikke legge til flere rettigher, så avlsuttes funksjonen
    if($nyeRettigheter[0] -eq ($tilgjengeligeRettigher.Count -1)) {
        return
    }
    
    # et par av funksjonene for å legge til rettigheter tar ikke imot alias som en gyldig verdi, så må anskaffe DistinguishedName for kontoen det skal legges til rettighet på
    $kontoNavn = (Get-Mailbox $konto –ErrorAction SilentlyContinue | Select DistinguishedName | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()

    # For hvert valg som er gjort, legges det til en rettighet
    foreach($valg in $nyeRettigheter) {
        # Switchen gis beskjed om hvilken rettighet som sakl legges til, og kjører koden som sørger for at den rettigheten blir gitt
        switch ($tilgjengeligeRettigher[[int]$valg]) {
            "FullAccess"{
                Add-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights "FullAccess" | Out-Null
            }
            "SendAs"{
                Add-ADPermission -Identity $kontoNavn -User $bruker -Extendedrights "Send-As" | Out-Null
            }
            "SendOnBehalfOf"{
                # Må bruke scriptblock for at berdien for $bruker skal sendes videre som aliaset til brukeren, og ikke som en string "$bruker"
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Add=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                # Det skal ikke være mulig å havne her, men skulle det ha skjedd en feil, så bør systemansvarlig gies beskjed slik at logiken kan rettes på
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $tilgjengeligeRettigher[[int]$valg] "ble forsøkt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    # Får tak i listen over hvilke rettigheter brukeren nå har til kontoen
    $rettigheter = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Fjerner tildigere utskrift fra konsollen for at det skal se mer ryddig ut
    Clear-Host

    # Gir beskjed om at handlingene ser ut til å ha vært vellykkede, og lister ut de rettighetene brukeren nå har til kontoen
    Write-Host "Rettigheter er blitt lagt til, rettighetene $bruker nå har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheter) {
        Write-Host "    - $rettighet"
    }
    # Pauser koden slik at brukeren får med seg siste beskjed
    Pause
}