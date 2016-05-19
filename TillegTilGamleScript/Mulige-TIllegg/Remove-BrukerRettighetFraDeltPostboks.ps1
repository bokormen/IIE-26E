# Funksjonen fjerner rettiheter en bruker har til en delt postboks
function Remove-BrukerRettighetFraDeltPostboks() {
    # Fjerner annen utskrift fra konsollen for � gj�re den mer oversiktlig
    Clear-Host
    # F�r tak i aliaset til brukeren som skal miste rettigheter
    $bruker = Get-Epostkonto "Skriv inn navnet p� brukeren som skal f� rettigheter til en annen konto (brukeren m� ha en e-postkonto aktivert)"
    # Fjerner annen utskrift fra konsollen for � gj�re den mer oversiktlig
    Cleat-Host
    # F�r tak i aliaset til kontoen brukeren skal miste rettigheter til
    $konto = Get-DeltPostboks "Skriv inn aliaset p� den delte kontoen $bruker skal f� rettighetheter til"
    # Fjerner annen utskrift fra konsollen for � gj�re den mer oversiktlig
    Clear-Host
    
    # Sender alias til bruker som skal miste rettigheter, og til kontoen det fratas rettighet fra
    Remove-Rettigheter $bruker $konto
}