#Funksjonen oppretter en ny delt epost 
function Remove-DeltPostboks{ 
    $entydig = Read-Host "Skriv inn navnet p� en deltpostboks du �nsker � slette"
    
    While ((Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue) -eq $null -or $entydig -eq "") {
        $entydig = Read-Host "Navnet du skrev inn gav ikke noe resultat, pr�v en gang til`nSkriv inn navnet p� en deltpostboks du �nsker � slette"
    }
 
    #Opretter en nydelt postboks 
    Remove-Mailbox $entydig
 
    #Godkjenings melding hvis det ikke er noen feil     
    if((Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue) -eq $null){     
        Write-Host "`nDen delte postboksen $navn eksisterer ikke lengre" -ForegroundColor Green
    } else {
        Write-Host "`nDen delte postboksen $navn ser fortsatt ut til � eksistere" -ForegroundColor Red
    }
}
