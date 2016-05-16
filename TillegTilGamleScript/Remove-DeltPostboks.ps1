#Funksjonen oppretter en ny delt epost 
function Remove-DeltPostboks{ 
    $entydig = Read-Host "Skriv inn navnet på en deltpostboks du ønsker å slette"
    
    While ((Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue) -eq $null -or $entydig -eq "") {
        $entydig = Read-Host "Navnet du skrev inn gav ikke noe resultat, prøv en gang til`nSkriv inn navnet på en deltpostboks du ønsker å slette"
    }
 
    #Opretter en nydelt postboks 
    Remove-Mailbox $entydig
 
    #Godkjenings melding hvis det ikke er noen feil     
    if((Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue) -eq $null){     
        Write-Host "`nDen delte postboksen $navn eksisterer ikke lengre" -ForegroundColor Green
    } else {
        Write-Host "`nDen delte postboksen $navn ser fortsatt ut til å eksistere" -ForegroundColor Red
    }
}
