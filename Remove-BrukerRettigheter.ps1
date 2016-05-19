# Denne funksjoenne fjerner en brukers rettighet(er) til en annen brukerkonto
function Remove-Brukerrettigheter() {
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    Clear-Host
    # Får tak i brukeren som skal miste rettighetet
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal miste rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    # Får tak i kontoen brukeren skal miste rettigheter til
    Clear-Host
    $konto = Get-Epostkonto "Skriv inn navnet på kontoen som $bruker skal miste rettighet til"
    # Fjerner utskriften i konsoll vinduet slik at det ser mer ryddig ut
    Clear-Host

    # Starter funksjonen som spør hvilke rettigher som skal fjernes
    Remove-Rettigheter $bruker $konto
}