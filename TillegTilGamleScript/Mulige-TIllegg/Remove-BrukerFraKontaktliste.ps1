#Fjerner en bruker fra en kontaktliste
function Remove-BrukerFraKontaktliste() {
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til brukeren som skal fjernes fra listen
    $bruker = Get-Epostkonto "Skriv inn aliaset på brukeren som skal fjernes fra en liste"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Henter listen som bruker skal fjenes fra
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen $bruker skal fjernes fra"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host

    # Fjerner bruker fra liste
    Remove-DistributionGroupMember -Identity $liste -Member $bruker

    # Sjekker om bruker er medlem i kontktlisten    
    if((Get-DistributionGroupMember -identity $liste -ErrorAction SilentlyContinue | Where {$_.Alias -eq $bruker}) -eq $null){
        # Skriver ut en beskjed om at brukeren nå fjernet fra listen
        Write-Host "`n$bruker er ikke lengre en del av $liste" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til å ha gått galt
        Write-Host "`n$bruker ser fortsatt ut til å finnes i $liste" -ForegroundColor Red
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    Clear-Host
}