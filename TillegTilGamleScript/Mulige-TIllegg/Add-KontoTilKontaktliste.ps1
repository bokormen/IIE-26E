# Legger en konto til en kontaktliste
function Add-KontoTilKontaktliste() {
    Clear-Host
    $bruker = Get-Epostkonto "Skriv inn aliaset p� brukeren som skal lagges til i en liste"
    Clear-Host
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen $bruker skal legges til i"
    Clear-Host

    Add-DistributionGroupMember -Identity $liste -Member $bruker

    # Sjekker om bruker er medlem i kontktlisten    
    if((Get-DistributionGroupMember -identity $liste -ErrorAction SilentlyContinue | Where {$_.Alias -eq $bruker}) -ne $null){
        # Skriver ut en beskjed om at brukeren n� er medlem av listen
        Write-Host "`n$bruker er n� en del av $liste" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til � ha g�tt galt
        Write-Host "`n$bruker ser ikke ut til � finnes i $liste" -ForegroundColor Red
    }
    # Setter skriptet p� pause, slik at brukeren f�r lest meldingen
    Pause
    Clear-Host
}