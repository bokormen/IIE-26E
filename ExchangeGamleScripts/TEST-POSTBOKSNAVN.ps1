#Funskjonen sjekker om posboksnavnet finnes 
function Test-PostboksNavn{
    
    do{
        [string]$entydig = Read-Host "Skriv inn entydig navn på postboks"
        #Sjekker om brukernavnet finnes. navnsjekk inneholder $null hvis ikke brukere finnes
        $navnSjekk = Get-Mailbox -Filter "Name -eq '$entydig'" -ErrorAction SilentlyContinue
        
        if($navnSjekk -ne $null){
            Write-Host "Navnet til postboksen eksisterer allerede. Skriv inn nytt" -ForegroundColor Red
        }
    }while($navnSjekk -ne $null -or $entydig -eq "")
    
    return $entydig
}