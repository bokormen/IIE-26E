# Denne funksjonen gir en bruker rettigheter til en delt postboks
function Add-BrukerRettighetTilDeltPostboks() {
    # Fjerner annen utskrift fra konsollen for � gj�re den mer oversiktlig
    Clear-Host
    # F�r tak i aliaset til brukeren som skal f� rettigheter
    $bruker = Get-Epostkonto "Skriv inn navnet p� brukeren som skal f� rettigheter til en annen konto (brukeren m� ha en e-postkonto aktivert)"
    # Fjerner annen utskrift fra konsollen for � gj�re den mer oversiktlig
    Cleat-Host
    # F�r tak i aliaset til kontoen brukeren skal f� rettigheter til
    $konto = Get-DeltPostboks "Skriv inn aliaset p� den delte kontoen $bruker skal f� rettighetheter til"
    # Fjerner annen utskrift fra konsollen for � gj�re den mer oversiktlig
    Clear-Host
    
    # Sender alias til bruker som skal f� rettighet, og til kontoen det skal bli gitt rettighet til
    Add-Rettigheter $bruker $konto
}