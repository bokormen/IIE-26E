# Denne funksjoenne fjerner en brukers rettighet(er) til en annen brukerkonto
function Remove-Brukerrettigheter() {
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    Clear-Host
    # F�r tak i brukeren som skal miste rettighetet
    $bruker = Get-Epostkonto "Skriv inn navnet p� brukeren som skal miste rettigheter til en annen konto (brukeren m� ha en e-postkonto aktivert)"
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    # F�r tak i kontoen brukeren skal miste rettigheter til
    Clear-Host
    $konto = Get-Epostkonto "Skriv inn navnet p� kontoen som $bruker skal miste rettighet til"
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    Clear-Host

    # Starter funksjonen som sp�r hvilke rettigher som skal fjernes
    Remove-Rettigheter $bruker $konto
}