# Denne funksjonen sletter en bruker fra både domenet og e-post serveren
function Delete-Brukerkonto() {
        # Får tak i brukeren som skal slettes
        $bruker = Get-Epostkonto "Skriv inn navnet på brukeren hvor epostkontoen og domenebrukeren skal slettes (brukeren må ha en e-postkonto aktivert)"
        
        # Sletter brukeren
        Remove-ADUser $bruker

        #Sjekker om det forsatt eksisterer en brukerkonto tilhørende brukeren
        if (((Get-ADUser $bruker -ErrorAction SilentlyContinue) -eq $null) -and ((Get-Mailbox $bruker -ErrorAction SilentlyContinue) -eq $null)) {
            # Gir beskjed om at brukeren ikke lengre eksisterer
            Write-Host "$bruker's e-postkonto og domenebruker er nå slettet" -ForegroundColor Green
        } else {
            # Gir beskjed om at noe ser ut til å ha gått galt
            Write-Host "$bruker's e-postkonto eller domenebruker ser fortsatt ut til å eksistere" -ForegroundColor Red
        }
}