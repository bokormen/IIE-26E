#Funksjonen sjekker om AD brukeren finnes og om han har epost knyttet til seg. 
function Test-AdBruker($bruker){ 
    [string]$bruker = $bruker 
         do{ 
        $sjekk = $false 
        #sjekker om brukeren finnes 
        $navnSjekk = Get-ADUser -Filter {SamAccountName -eq $bruker} -Properties * -ErrorAction SilentlyContinue
        if($navnSjekk -eq $null){ 
            [string]$bruker = Read-Host "Brukeren eksisterer ikke. Skriv inn ny" 
        } 
        #sjekker om brukeren har postboks registrert på seg
        if($navnSjekk.homeMDB -ne $null -and $navnSjekk -ne $null){ 
            [string]$bruker = Read-Host "Brukeren eksisterer, men det finnes allerede en postboks til brukeren. Skriv inn ny" 
        }
        if($navnsjekk.homeMDB -eq $null -and $navnSjekk -ne $null){ 
            $sjekk = $true 
        } 
         
    }while($sjekk -eq $false) 
     return navnSjekk 
}