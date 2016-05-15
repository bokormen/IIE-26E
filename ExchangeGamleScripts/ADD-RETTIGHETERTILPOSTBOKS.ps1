#Funksjonen gir en bruker rettigheter til en delt epost. 
function Add-RettigheterTilPostboks($navn,$bruker){
    
    #Oppretter en tabell med de ulike rettighetene en kan få 
    $rettigheter = @("ChangeOwner","ChangePermission","DeleteItem","ExternalAccount","FullAccess","ReadPermission") 
    
    #Skriver ut alle rettighetene med et tall foran slik at brukeren enkelt kan velge rettighet 
    #Write-Host $rettigheter[0] 
    for($i=0;$i-lt$rettigheter.Length;$i++){ 
        Write-Host $i":" $rettigheter[$i] 
    } 
     
    #Sjekker om det er gyldig input som er skrevet inn
    do{ 
        $sjekkInt = $false 
        $valgrettighet = $null 
        #Sjekker om rettigheten er et tall
        try{ 
            [int]$valgrettighet = Read-Host "Skriv inn ønsket rettighet (eks 1)" 
        }catch{ 
            Write-Host "Ugyldig input" -ForegroundColor Red 
            $sjekkInt = $true 
        }
        if ($valgrettighet -eq "") {
            Write-Host "Du må taste inn et valg"  -ForegroundColor Red
        }elseif ($valgrettighet -gt ($rettigheter.length-1)) {
            Write-Host "Verdien du har valgt er større enn menyalternativene" -ForegroundColor Red
        } 
    }while (($valgrettighet -gt ($rettigheter.length-1)) -or ($valgrettighet -eq "") -or $sjekkInt -eq $true) 
    #Setter rettigheten 
    Get-Mailbox -Identity $navn | Add-MailboxPermission -User $bruker -AccessRights $rettigheter[$valgrettighet] -InheritanceType All -ErrorVariable err 
 
    #Hvis $err[0] er lik $null har operasjonen gått bra
    if($err.length -eq 0){ 
        Write-Host "Velykket operasjon" -ForegroundColor Green 
    } 
}