#Funksjonen sjekker om alias navnet finnes
function Test-PostboksAlias{

    do{
        [string]$entydig = Read-Host "Skriv inn entydig alias på postboks"
        #Sjekker om brukernavnet finnes. navnsjekk inneholder $null hvis ikke brukere finnes
        $navnSjekk = Get-Mailbox -Filter "Alias -eq '$entydig'" –ErrorAction SilentlyContinue
        
        if($navnSjekk -ne $null){
            Write-Host "Aliaset til postboksen eksisterer allerede. Skriv inn nytt" -ForegroundColor Red
        }
    }while($navnSjekk -ne $null -or $entydig -eq "")
    
    return $entydig
}