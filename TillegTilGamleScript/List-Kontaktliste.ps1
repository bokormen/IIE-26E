# Lister ut medlemene i en kontaktliste/distribusjonsgruppe
function List-KontaktlisteMedlemmer() {
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host
    $liste = Get-Kontaktliste "Skriv inn aliaset til listen du �nsker � se medlemmene til"
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host

    # Skriver ut listen med medlemer
    Write-Host "Medlemmer I $Liste :"
    Get-DistributionGroupMember -identity $liste | Select Name,Alias | Format-Table -AutoSize -Wrap

    # Pauser slik at brukeren skal kunne lese utskriften f�r skriptet g�r videre
    Pause
    # Fjerner innholdet i konsollen, for at det skal se ryddigere ut
    Clear-Host
}