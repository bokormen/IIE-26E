#Funksjonen sjekker om alias navnet finnes
function Test-Postboks($entydig){
    [string]$entydig = $entydig
    
    $navnSjekk = Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue
    #Sjekker om brukernavnet finnes. navnsjekk inneholder $null hvis ikke brukere finnes
    while($navnSjekk -eq $null){
        [string]$entydig = Read-Host "Postboksen eksisterer ikke. Skriv inn ny"
        
        $navnSjekk = Get-Mailbox -Filter "Alias -eq '$entydig'" -ErrorAction SilentlyContinue
        
    }
    
    return $entydig
}