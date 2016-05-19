# Funksjonen gir en bruker rettighet(er) til en annen postboks
function Add-Rettigheter() {
    
    # Funksjonen tar inn to stringer, som hver er et alias som beksriver en bruker og en konto
    param([string]$bruker,[string]$konto)

    # F�r tak i en liste over hvilke rettigheter brukeren alt har, som jeg legger inn i en arraylist for � gj�re det enklere � bearbeide
    $rettigheter = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Liste over hvilke rettigheter brukeren kan bli gitt, inkluderer et valg om � ikke gj�re noen endringer
    $tilgjengeligeRettigher = [System.Collections.ArrayList]@("FullAccess","SendAs","SendOnBehalfOf","�nsker ikke � legge til en ny rettighet")

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

    # Lister ut hvilke rettigheter brukeren kan tildeles kontoen, samt en tallverdi foran rettighene som representerer rettigheten n�r den senre kan bli valgt
    # Hvis ikke det er flere rettigheter � tildele, s� skrives det ut en beskjed om det
    if($tilgjengeligeRettigher.Count -gt 1) {
        # Her skrives listen over tilgjendelige rettigheter ut
        Write-Host "`n`nRettigheter $bruker kan bli gitt til kontoen $konto :"
        $i = 0
        foreach($rettighet in $tilgjengeligeRettigher) {
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        # Her skrives beskjeden om at det ikke er mulig � tildele flere rettigheter ut
        Write-Host "`n`n$bruker kan ikke bli gitt flere rettigheter til kontoen $konto `n"
        Pause
        # Her g�r skriptet ut av denne funksjonen, da det ikke er mer � gj�re
        Return
    }

    # Variabel som brukes for � kontrollere at alle valgene som skrives inn er gyldige valg
    $erRetteVerdier = [boolean]$true
    # String som inneholder de nye rettighetene som skal legges til, adskilt med komma
    $nyeRettigheter = ""

    # Denne do while l�kka sjekket at det som skrives inn er gyldige verdier
    do {
        # Valgene som er gjort, er gyldige til det motsatte er bevist
        $erRetteVerdier = [boolean]$true

        # Ber brukeren skive inn hvilke rettigheter brukeren �nsker � gi, det kan legges til flere rettigheter, men da m� de adskilles med komma
        $nyeRettigheter = Read-Host "`n`nSkriv inn nummeret som st�r f�r rettigheten du �nsker � gi $bruker til kontoen $konto`nOm du �nsker � tildele flere rettigheter, s� kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene p� rettigheten(e) du �nsker � gi"

        # Fjerner "whitespace"
        $nyeRettigheter.Trim(" ") | Out-Null

        # legger valgene inn i en array
        $nyeRettigheter = [System.Collections.ArrayList]$nyeRettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        # fjerner alle doble valg
        $temp = $nyeRettigheter | Get-Unique

        # sjekker at brukeren har gitt en verdi, og ikke bare har trykket enter uten � skrive inn noe
        if($nyeRettigheter.Count -eq 0) {
            # Skriver ut en beskjed om at tomt valg ikek er en mulighet, og setter verdien $erRetteVerdier til false for � indikere at vi ikke har f�tt noe som kan jobbes videre med og det m� sp�rres p� nytt
            Write-Host "Du kan ikke bare trykke p� enter, du m�t gj�re et valg, om du �snker � avslutte, kan du skrive inn" ($tilgjengeligeRettigher.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false
        # Sjekker at en rettighet ikke er skrevet inn to ganger, har valgt � ikke tillate det, hvis et valg ikke er oppgitt to ganger, s� sjekker jeg at alle valgene er tall
        } elseif($temp.count -eq $nyeRettigheter.Count) {
            
            # G�r igjennom alle valgene og sjekket at det er tall som tilsvarer menyelementene
            foreach($valg in $nyeRettigheter) {
                # Sjekker om valget er er tall
                if(![boolean]($valg -as [int] -is [int])) {
                    # skriver ut en advarsel om at valget ikke er et tall, og setter verdien $erRetteVerdier til false
                    Write-Host "$valg er ikke et tall, du m� liste opp rettighetene du �nsker � tildele p� nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    # g�r ut av foreach l�kken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i � g� gjennom flere
                    Break

                } else {
                    # caster valget til int
                    $valg = [int]$valg

                    # Sjekket om valget er innenfor de verdiene som menyen inneholder
                    if(($valg -lt 0) -or ($valg -ge $tilgjengeligeRettigher.Count)) {
                        # Skriver ut en advarsel om at valget ikke er innenfor de verdiene som menyen inneholder, og setter verdien $erRetteVerdier til false
                        Write-Host "$valg er ikke er tall mellom 0 og" ($tilgjengeligeRettigher.Count-1) ", du m� skrive inn valgene p� nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        # g�r ut av foreach l�kken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i � g� gjennom flere
                        Break

                    # Sjekker om valget som er gjort er � ikke legge til flere rettigheter, samtidig som det er gjort flere andre valg ogs�, da det ikke gir mening
                    } elseif (($valg -eq ($tilgjengeligeRettigher.Count-1)) -and ($nyeRettigheter.Count -gt 1)) {
                        # Skriver ut en advarsel om at valget ikke er logisk, og setter verdien $erRetteVerdier til false
                        Write-Host "Du kan ikke legge til rettigheter, og samtidig gj�re valget:" $tilgjengeligeRettigher[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($tilgjengeligeRettigher.Count-2) "separert med komma, eller bare" ($tilgjengeligeRettigher.Count-1)  -ForegroundColor Red
                        $erRetteVerdier = $false
                        # g�r ut av foreach l�kken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i � g� gjennom flere
                        Break

                    }
                }
            }
        } else {
            # Gir beskjed om at det ikke er lov � liste opp en verdi to ganger, og setter $erRetteVerdier til false
            Write-Host "Du kan kunn skrive inn unike verdier, separert med komma, du kan ikke liste opp en rettighet to ganger" -ForegroundColor Red
            $erRetteVerdier = $false

        }
    # sjekker om det er riktige verdier som er skrevet inn, hvis ikke, s� g�r l�kken gjennom prosessen med � f� valgene fra brukeren p� nytt
    } while (!$erRetteVerdier)

    # Hvis valget er � ikke legge til flere rettigher, s� avlsuttes funksjonen
    if($nyeRettigheter[0] -eq ($tilgjengeligeRettigher.Count -1)) {
        return
    }
    
    # et par av funksjonene for � legge til rettigheter tar ikke imot alias som en gyldig verdi, s� m� anskaffe DistinguishedName for kontoen det skal legges til rettighet p�
    $kontoNavn = (Get-Mailbox $konto �ErrorAction SilentlyContinue | Select DistinguishedName | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()

    # For hvert valg som er gjort, legges det til en rettighet
    foreach($valg in $nyeRettigheter) {
        # Switchen gis beskjed om hvilken rettighet som sakl legges til, og kj�rer koden som s�rger for at den rettigheten blir gitt
        switch ($tilgjengeligeRettigher[[int]$valg]) {
            "FullAccess"{
                Add-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights "FullAccess" | Out-Null
            }
            "SendAs"{
                Add-ADPermission -Identity $kontoNavn -User $bruker -Extendedrights "Send-As" | Out-Null
            }
            "SendOnBehalfOf"{
                # M� bruke scriptblock for at berdien for $bruker skal sendes videre som aliaset til brukeren, og ikke som en string "$bruker"
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Add=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                # Det skal ikke v�re mulig � havne her, men skulle det ha skjedd en feil, s� b�r systemansvarlig gies beskjed slik at logiken kan rettes p�
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $tilgjengeligeRettigher[[int]$valg] "ble fors�kt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    # F�r tak i listen over hvilke rettigheter brukeren n� har til kontoen
    $rettigheter = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Fjerner tildigere utskrift fra konsollen for at det skal se mer ryddig ut
    Clear-Host

    # Gir beskjed om at handlingene ser ut til � ha v�rt vellykkede, og lister ut de rettighetene brukeren n� har til kontoen
    Write-Host "Rettigheter er blitt lagt til, rettighetene $bruker n� har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheter) {
        Write-Host "    - $rettighet"
    }
    # Pauser koden slik at brukeren f�r med seg siste beskjed
    Pause
}