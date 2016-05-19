# Funksjonen fjerner rettiheter en bruker har til en delt postboks
function Remove-BrukerRettighetFraDeltPostboks() {
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    # Får tak i aliaset til brukeren som skal miste rettigheter
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal få rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Cleat-Host
    # Får tak i aliaset til kontoen brukeren skal miste rettigheter til
    $konto = Get-DeltPostboks "Skriv inn aliaset på den delte kontoen $bruker skal få rettighetheter til"
    # Fjerner annen utskrift fra konsollen for å gjøre den mer oversiktlig
    Clear-Host
    
    # Sender alias til bruker som skal miste rettigheter, og til kontoen det fratas rettighet fra
    Remove-Rettigheter $bruker $konto
}