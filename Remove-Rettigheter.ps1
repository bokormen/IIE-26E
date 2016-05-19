# Denne funksjoenne fjerner en kontos rettighet(er) til en annen brukerkonto
function Remove-Rettigheter() {

    # Funksjonen tar inn to stringer, som hver er et alias som beksriver en bruker og en konto
    param([string]$bruker,[string]$konto)

    # Får tak i en liste over hvilke rettigheter brukeren alt har, som jeg legger inn i en arraylist for å gjøre det enklere å bearbeide
    $rettigheterSomKanMistes = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Legger til et valg om å ikke gjøre endringer i rettigheter brukren har til kontoen
    $rettigheterSomKanMistes.Add("Ønsker ikke å frata $bruker rettigheter til kontoen $konto") | Out-Null

    # Hvis brukeren har en eller flere rettigheter til koentoen, så listes de ut, samt en tallverdi foran rettighene som representerer rettigheten når den senre kan bli valgt
    if($rettigheterSomKanMistes.Count -gt 1) {
        Write-Host "Rettigheter $bruker kan bli fratatt fra kontoen $konto :"
        # Telleren som angir verdien som kan bli balgt for rettigheten
        $i = 0
        foreach($rettighet in $rettigheterSomKanMistes) {
            # Utskrift av rettighetene
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        # Hvis det ikke er noen rettigheter å fjerne, blir det skrevet ut en beskjed om det, og funksjonen avsluttes
        Write-Host "$bruker kan ikke bli fratatt flere rettigheter til kontoen $konto `n"
        Pause
        Return
    }

    # Booslk verdi somb rukes for å sjekke at det som skrives inn er verdier som kan brukes videre
    $erRetteVerdier = [boolean]$true
    # De ulike rettighetene som skal fjernes fra brukeren til kontoen
    $gamleRettigheter = ""

    do {

        # Antar at det som skrives inn er rett, frem til det motsatte er bevist
        $erRetteVerdier = [boolean]$true

        # Får inn valget til brukeren over hvilke rettigheter som skal fjernes
        $gamleRettigheter = [System.Collections.ArrayList]((Read-Host "`n`nSkriv inn nummeret som står før rettigheten du ønsker å frata $bruker til kontoen $konto`nOm du ønsker å frata flere rettigheter, så kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene på rettigheten(e) du ønsker å frata").Trim()).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        # lagrer de unike verdiene i arrayen i en array som senere brukes for å kontrollere at det kun er gitt unike verdier
        $temp = $gamleRettigheter | Get-Unique

        # Sjekker at det er gjort et valg
        if($gamleRettigheter.Count -eq 0) {
            
            # Skrivet ut en beskjed detsom det ikke er gjort et valg, og setter $erRetteVerdier til false
            Write-Host "Du kan ikke bare trykke på enter, du måt gjøre et valg, om du øsnker å avslutte, kan du skrive inn" ($rettigheterSomKanMistes.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false

        # Hvis det er gjort et valg, så sjekkes det at alle valgene som er gjort, er unike
        } elseif($temp.count -eq $gamleRettigheter.Count) {
            
            # Går igjennom alle valgen og sjekker at de er tall, og at tallverdien er innenfor menystørrelsen
            foreach($valg in $gamleRettigheter) {
                #Sjekker at det er et tal som er skrevet inn
                if(![boolean]($valg -as [int] -is [int])) {
                     # skriver ut en advarsel om at valget ikke er et tall, og setter verdien $erRetteVerdier til false
                    Write-Host "$valg er ikke et tall, du må liste opp rettighetene du ønsker å frata på nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                    Break

                } else {
                    # caster valget til int
                    $valg = [int]$valg

                    # Sjekket om valget er innenfor de verdiene som menyen inneholder
                    if(($valg -lt 0) -or ($valg -ge $rettigheterSomKanMistes.Count)) {

                        # Skriver ut en advarsel om at valget ikke er innenfor de verdiene som menyen inneholder, og setter verdien $erRetteVerdier til false
                        Write-Host "$valg er ikke er tall mellom 0 og" ($rettigheterSomKanMistes.Count-1) ", du må skrive inn valgene på nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        # går ut av foreach løkken da jeg alt ha oppdaget et valg som ikke kan brukes videre, og det da ikke er noe poeng i å gå gjennom flere
                        Break
                    # Sjekker at det ikke er gjort et valg om å ikke legge til flere rettigheter, samtidig som det er valgt rettigheter som skal taes fra brukeren
                    } elseif (($valg -eq ($rettigheterSomKanMistes.Count-1)) -and ($gamleRettigheter.Count -gt 1)) {
                        # Gir beskjed om at valgene som er gjort, er lokgisk gale, og setter $erRetteVerdier til false
                        Write-Host "Du kan ikke frata rettigheter, og samtidig gjøre valget:" $rettigheterSomKanMistes[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($rettigheterSomKanMistes.Count-2) "separert med komma, eller bare" ($rettigheterSomKanMistes.Count-1)  -ForegroundColor Red
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

    # Hvis valget er å ikke gjøre noen endringer, så avluttes funksjonen
    if($gamleRettigheter[0] -eq ($rettigheter.Count -1)) {
        return
    }
    
    # et par av funksjonene for å frata rettigheter tar ikke imot alias som en gyldig verdi, så må anskaffe DistinguishedName for kontoen det skal fratas rettighet på
    $kontoNavn = (Get-Mailbox $konto –ErrorAction SilentlyContinue | Select DistinguishedName | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace("`n","").Replace("`r","").Trim()

    # For hvert valg som er gjort, går valget inn i switchen, og koden for å fjerne valgt rettighet kjøres
    foreach($valg in $gamleRettigheter) {
        switch ($rettigheterSomKanMistes[[int]$valg]) {
            "FullAccess"{
                Remove-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false | Out-Null
            }
            "SendAs"{
                Remove-ADPermission -Identity $kontoNavn -User $bruker -ExtendedRights 'Send-As' -InheritanceType 'All' -ChildObjectTypes $null -InheritedObjectType $null -Properties $null -Confirm:$false | Out-Null
            }
            "SendOnBehalfOf"{
                # Må bruke scriptblock for at berdien for $bruker skal sendes videre som aliaset til brukeren, og ikke som en string "$bruker"
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Remove=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                # Det skal ikke være mulig å havne her, men skulle det ha skjedd en feil, så bør systemansvarlig gies beskjed slik at logiken kan rettes på
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $rettigheterSomKanMistes[[int]$valg] "ble forsøkt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    # Henter en liste over det rettighetene brukeren nå har til kontoen
    $rettigheterSomKanMistes = [System.Collections.ArrayList](Get-ListeOverGitteBrukerrettigher $bruker $konto).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    # Fjerner tidligere utskrift for å gjøre konsollvinduet oversiktlig
    Clear-Host
    # Gir beksjed om at rettighetene ser ut til å ha blitt gjernet, og lister ut de rettighetene brukeren fortsatt har til kontoen
    Write-Host "Rettigheter er blitt fjernet, rettighetene $bruker forsatt har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheterSomKanMistes) {
        Write-Host "    - $rettighet"
    }
    # Pauser før funksjonen avlsuttes, slik at brukeren rekker å lese utskriften
    Pause
    Clear-Host
}