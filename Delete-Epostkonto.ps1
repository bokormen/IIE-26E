# Denne funksjonen fjerner e-postkontoen til en bruker
function Delete-Epostkonto() {
    # Får tak i brukeren det gjelder
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren hvor epostkontoen skal slettes (brukeren må ha en e-postkonto aktivert)"
    
    # Fjerner e-postkontoen
    Disable-Mailbox $bruker

    # Kontrollerer om det fortsatt finnes en e-postkonto tilhørende brukeren
    if((Get-Mailbox $bruker -ErrorAction SilentlyContinue) -eq $null) {
        # Gir beskjed om at det ikke lengre finnes en e-postkonto tilhørende brukeren
        Write-Host "$bruker's e-postkonto er nå slettet" -ForegroundColor Green
    } else {
        # Gir beskjed om at noe set ut til å ha gått galt
        Write-Host "$bruker's e-postkonto ser fortsatt ut til å eksistere" -ForegroundColor Red
    }
    
}