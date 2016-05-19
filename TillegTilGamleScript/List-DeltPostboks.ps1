# Funksjonen lister ut delte postbokser
function List-DeltPostboks() {
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host

    Write-Host "Delte postbokser: "

    # Får en liste over delte postbokser, og skriver ut navn og alias
    Get-mailbox -RecipientTypeDetails sharedmailbox -Resultsize unlimited | Select Name,Alias | Format-Table -AutoSize -Wrap
    
    # Pauser slik at brukeren skal kunne lese utskriften før skriptet går videre
    Pause
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host
}