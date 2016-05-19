#Funksjonen oppretter en ny delt epost 
function New-DeltPostboks{ 
    Write-Host "Opprett deltpostboks" 
     
    #Finner et ledig navn 
    $navn = Test-PostboksNavn 
    #Finner et ledig alias 
    $entydig = Test-PostboksAlias 
 
    #Opretter en nydelt postboks 
    New-Mailbox -Shared -Name $navn -DisplayName $navn -Alias $entydig

    $konto = Get-Mailbox $entydig -RecipientTypeDetails sharedmailbox  –ErrorAction SilentlyContinue
 
    #Godkjenings melding postboksen nå eksisterer   
    if($konto -ne $null){     
        Write-Host "`nDen delte postboksen $navn ble oprettet" -ForegroundColor Green 
     
        $Valg = Read-Host "Ønsker du å legge til rettigheter (eks: j/n)"     
        #Får valg om en ønsker å gi brukere rettigheter til den delte postboksen     
        if($Valg -eq "j"){     
            Set-Rettigheter $entydig 
        }
    } else {
        Write-Host "Det ser ut til å ha skjedd en feil, og den delte postboksen har ikke blitt opprettet" -ForegroundColor Red
    }
}
