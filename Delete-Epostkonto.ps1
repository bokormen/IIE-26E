function Delete-Epostkonto() {
    
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren hvor epostkontoen skal slettes (brukeren må ha en e-postkonto aktivert)"
    
    Disable-Mailbox $bruker

    if((Get-Mailbox $bruker -ErrorAction SilentlyContinue) -eq $null) {
        Write-Host "$bruker's e-postkonto er nå slettet" -ForegroundColor Green
    } else {
        Write-Host "$bruker's e-postkonto ser fortsatt ut til å eksistere" -ForegroundColor Red
    }
    
}