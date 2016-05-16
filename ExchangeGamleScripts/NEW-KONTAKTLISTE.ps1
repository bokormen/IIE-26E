#Oppretter en ny kontaktliste 
function New-Kontaktliste{

    [string]$navn = Read-Host "Skriv inn navn på distribusjonsgruppe"     
    if($navn -ne ""){ 
        #sjekker om kontaklisten finnes fra før 
        $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
        $sjekkNavn = Invoke-Command -ScriptBlock $scriptblock
    } 

    #oppretter en tall variabel utenfor løkken for å konne teste på den i do while løkken
    $eksistererGruppen = $null
    
    #Løkken går så lenge som opprettelsen av kontaktlisten ikke er lik null     
    do{ 
        #Løkken går så lenge navnet finnes fra før  
              
        while($sjekkNavn -ne $null -or $navn -eq ""){ 
             
            $navn = Read-Host "Navn finnes allerede. Skriv inn nytt navn på kontaktliste"             
            if($navn -ne ""){
                $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
                $sjekkNavn = Invoke-Command -ScriptBlock $scriptblock
            } 
        } 
        #Opretter en ny kontaktliste, legger utskriften i en variabel, slik at vi har kontroll på hva som blir skrevet ut
        $enVariabel = New-DistributionGroup -Name $navn -Type Distribution
        
        $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
        $eksistererGruppen = Invoke-Command -ScriptBlock $scriptblock

    }while($eksistererGruppen -eq $null)
     
    #Får et valg om en ønsker å legge til brukere til kontaktlisten     
    $valg = Read-Host "Ønsker du å legge til brukere i kontaktlisten (eks j/n)`_"     
    if($valg -eq "j"){ 
        Add-BrukerTilKonakListe $navn
    }
}