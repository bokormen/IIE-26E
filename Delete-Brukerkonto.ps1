function Delete-Brukerkonto() {
        $bruker = Get-Epostkonto "Skriv inn navnet på brukeren hvor epostkontoen og domenebrukeren skal slettes (brukeren må ha en e-postkonto aktivert)"
        
        Remove-ADUser $bruker

        if (((Get-ADUser $bruker -ErrorAction SilentlyContinue) -eq $null) -and ((Get-Mailbox $bruker -ErrorAction SilentlyContinue) -eq $null)) {
        Write-Host "$bruker's e-postkonto og domenebruker er nå slettet" -ForegroundColor Green
        } else {
            Write-Host "$bruker's e-postkonto eller domenebruker ser fortsatt ut til å eksistere" -ForegroundColor Red
        }
}