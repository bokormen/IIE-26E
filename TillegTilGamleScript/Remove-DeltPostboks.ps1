#Funksjonen sletter en delt epost 
function Remove-DeltPostboks{ 
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
    # F�r tak i aliaset til en delt postboks
    $entydig = Get-DeltPostboks "Skriv inn navnet p� en deltpostboks du �nsker � slette"
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
    
    #Sletter en delt postboks 
    Remove-Mailbox $entydig
 
    # Sjekker om postboksen fortsatt eksisterer    
    if((Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue) -eq $null){
        # Skriver ut en beskjed om at slettingen var vellykket
        Write-Host "`nDen delte postboksen $navn eksisterer ikke lengre" -ForegroundColor Green
    } else {
        # SKriver ut beskjed om at noe ser ut til � ha g�tt galt
        Write-Host "`nDen delte postboksen $navn ser fortsatt ut til � eksistere" -ForegroundColor Red
    }
    # Setter skriptet p� pause, slik at brukeren f�r lest meldingen
    Pause
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
}
