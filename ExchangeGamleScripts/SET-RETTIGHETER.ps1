#Funksjonen lar deg velge mellom å sende på vegne av eller sette tilgang til en delt postboks 
function Set-Rettigheter{ 
    #Param er der slik at en har mulighet til å sende over navnet på den delte eposten.     
    param([Parameter(Mandatory=$false)]$navn)     
	do{ 
        $RettighetMeny = Read-Host "`n1:Sende på vegne av`n2:Sett tilgang til delt postboks`n3:Avslutt`n" 
        #Sjekker om $navn har innhold         
        if($navn -eq $null -or $navn -eq ""){             
        if($RettighetMeny -eq "1"){ 
                $navn = Read-Host "Skriv inn entydig postboks som skal gi rettigheter" 
                #Sjekker om det er et gyldig postboksnavn 
                $navn = Test-Postboks $navn 
 
 
            }elseif($RettighetMeny -eq "2"){ 
                
                #Henter ut alle postbokser som er delte 
                $navn = Get-Mailbox * | Where-Object {$_.IsShared -eq "True"}  
                
                #Lister ut alle delte postbokser                 
                for($i=0;$i -lt $navn.length; $i++){                     
                Write-Host $i : $navn[$i].Alias                 
                }         
                
                #Sjekker at det blir skrevet inn gyldig verdi                 
                do{ 
                    $sjekkiInt = $false 
                    $valgNavn = $null 
                    #Sjekker om det er tall som er skrevet inn                     
                    try{ 
                        [int]$valgNavn = Read-Host "Velg delt postboks (eks 1)" 
                    }catch{ 
                        Write-Host "Ugyldig input" -ForegroundColor Red 
                        $sjekkiInt = $true 
                    } 
                
                }while (($valgNavn -gt ($navn.length-1)) -or ($valgNavn -eq "") -or $sjekkiInt -eq $true) 
                #tar det valgte navnet fra objektet og velger det entydige navnet Alias 
                $navn = $navn[$ValgNavn].Alias 
            }             
        }else{ 
            $tempnavn = $navn 
        }
        if($RettighetMeny -eq "1"){  
            [string]$bruker = Read-Host "Skriv inn postboks som skal få rettigheter" 
            #Sjekker om postboksen eksisterer 
            $bruker = Test-Postboks $bruker 
 
            #Benytter send på vegne av funskjonen 
            Add-SendPaVegneAv $navn $bruker 
        }elseif($RettighetMeny -eq "2"){ 
            [string]$bruker = Read-Host "Skriv inn postboks som skal få rettigheter" 
            #Sjekker om postboksen eksisterer 
            $bruker = Test-Postboks $bruker 
 
            #Benytter rettigheter til postboks funksjonen 
            Add-RettigheterTilPostboks $navn $bruker 
        }         if($tempnavn -eq $null){ 
            $navn = "" 
        } 
    }while($RettighetMeny -ne "3") 
}