#Oppretter en ny kontaktliste 
function New-Kontaktliste{ 
    [string]$navn = Read-Host "Skriv inn navn på distribusjonsgruppe"     
    if($navn -ne ""){ 
        #sjekker om kontaklisten finnes fra før 
        $sjekkNavn = Get-DistributionGroup -Filter {name -eq $navn} 
    } 

    #oppretter en tall variabel utenfor løkken for å konne teste på den i do while løkken
    $lengdeAvErr = 0

    #Løkken går så lenge som opprettelsen av kontaktlisten ikke er lik null     
    do{ 
        #Løkken går så lenge navnet finnes fra før         
        while($sjekkNavn -ne $null -or $navn -eq ""){ 
             
            $navn = Read-Host "Navn finnes allerede. Skriv inn nytt navn på kontaktliste"             
            if($navn -ne ""){ 
            $sjekkNavn = Get-DistributionGroup -Filter {name -eq $navn} 
            } 
        } 
        #Opretter en ny kontaktliste 
        New-DistributionGroup -Name $navn -Type Distribution -ErrorVariable err
        
        #brukes for å konne kontrollere errorvariablen utenfor do while løkken
        $lengdeAvErr = $err.length  
        if($err.length -ne 0){ 
            $sjekkNavn = "a"
        } 
    }while($lengdeAvErr -ne 0) 
     
    #Får et valg om en ønsker å legge til brukere til kontaktlisten     
    $valg = Read-Host "Ønsker du å legge til brukere i kontaktlisten (eks j/n)`_"     
    if($valg -eq "j"){ 
        Add-BrukerTilKonakListe $navn 
    } 
}