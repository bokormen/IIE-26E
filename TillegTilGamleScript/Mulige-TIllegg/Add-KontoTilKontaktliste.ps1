# Legger en konto til en kontaktliste
function Add-KontoTilKontaktliste() {
    Clear-Host
    $bruker = Get-Epostkonto "Skriv inn aliaset på brukeren som skal lagges til i en liste"
    Clear-Host
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen $bruker skal legges til i"
    Clear-Host

    Add-DistributionGroupMember -Identity $liste -Member $bruker

    # Sjekker om bruker er medlem i kontktlisten    
    if((Get-DistributionGroupMember -identity $liste -ErrorAction SilentlyContinue | Where {$_.Alias -eq $bruker}) -ne $null){
        # Skriver ut en beskjed om at brukeren nå er medlem av listen
        Write-Host "`n$bruker er nå en del av $liste" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til å ha gått galt
        Write-Host "`n$bruker ser ikke ut til å finnes i $liste" -ForegroundColor Red
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    Clear-Host
}