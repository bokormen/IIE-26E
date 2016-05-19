# Sletter en kontaktliste 
function Remove-Kontaktliste{
    # Får navnet på en kontaktliste
    $navn = Get-Kontaktliste "Skriv inn navn på distribusjonsgruppe"

    #Sletter en kontaktliste, legger utskriften i en variabel, slik at vi har kontroll på hva som blir skrevet ut
    $enVariabel = Remove-DistributionGroup $navn
    
    #Tester om gruppen fortsatt eksisterer, når scriptblock'en kjøres, så returnes $null hvis alt har gått som det skal
    $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
    $eksistererGruppen = Invoke-Command -ScriptBlock $scriptblock

    # Skriver ut en melding til brukeren om resultatet av kjøringen
    if($eksistererGruppen -ne $null) {
        Write-Host "Det ser ut til å ha skjedd en feil, distribusjonsgruppen eksisterer fortsatt" -ForegroundColor Red
    } else {
        Write-Host "Distribusjonsgruppen $navn eksisterer ikke lengre" -ForegroundColor Green
    }
    # Setter skriptet på pause, slik at brukeren får lest meldingen
    Pause
    # Fjernet innholdet i konsollen slik at det ser mer ryddig ut
    Clear-Host
}