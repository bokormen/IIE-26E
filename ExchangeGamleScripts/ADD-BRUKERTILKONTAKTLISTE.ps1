# Legger en bruker til en Kontaktliste
function Add-BrukerTilKonakListe($Navn){ 

#en variabel som trengs senere for å få en riktig test
$errStoerelse = 0                 

$sjekk = $false          
do{ 
        #Valg mellom å legge til en bruker eller flere brukere fra en OU 
  $Valg = Read-Host "1:En bruker`n2:Flere brukere`n"                  
  if($Valg -eq "1"){ 
         
            [string]$bruker = Read-Host "Skriv inn postboks som skal legges til kontaktlisten" 
            #Sjekker om brukeren finnes 
            $bruker = Test-Postboks $bruker 
 
            #Tar ut all informasjon om en bruker 
            $temp = Get-Mailbox $bruker | select -Property * 
             
            #Legger brukeren inn i kontaktlisten 
            Add-DistributionGroupMember -Identity $Navn -Member $temp.UserPrincipalName 
            $sjekk = $true 
 
            Write-Host "Brukeren $bruker lagt til distribusjonsgruppen $Navn" -ForegroundColor Green 
        }elseif($Valg -eq "2"){ 
            #skriver ut alle OU-ene 
            $OU = Get-OU 
 
            #sjekker at gyldig verdi er skrevet inn
            do{ 
                $sjekkInt = $false 
                $valgOU = $null 
                [string]$ValgOU = Read-Host "Velg OU-en du ønsker å importere til  kontaktlisten (eks 1)" 
                if($ValgOU -ne $null){                     
                 #Sjekker om innskrevet verdi er tall                     
                    try{ 
                        [int]$ValgOU = $ValgOU 
                    }catch{ 
                        Write-Host "Ugyldig input" -ForegroundColor Red 
                        $sjekkInt = $true
                    }                     
                }else{ 
                        $sjekkInt = $true 
                    } 
                 
            }while (($ValgOU -gt $OU.length-1) -or $sjekkInt -eq $true) 
 
            #Først tar en ut alle brukere i en OU. Deretter går en gjennom alle brukerene som har mail i den OU-en, og legger de inn i distrubusjonsgruppa 
            Get-ADUser -Filter * -SearchBase $OU[$ValgOU].DistinguishedName -Properties *| ForEach-Object { 
                #Sjekker om bruker har mail
                
                if($_.Mail -ne ""){ 
                    #Legger en bruker til distubusjonsgruppa 
                    Add-DistributionGroupMember -Identity $Navn -Member $_.samaccountname <#-ErrorVariable err #>-ErrorAction SilentlyContinue
                    $scriptblock = [scriptblock]::Create("Get-DistributionGroupMember -Identity `"$Navn`" | Where-Object{`$_.Alias -eq `"$_.samAccountName`"}")
                    $sjekkResultat = Invoke-Command -ScriptBlock $scriptblock
                }                  
                if($sjekkResultat -eq ""){
                    $utskriftBruker += $_.SamAccountName + "`n" 
                    $errStoerelse++ | Out-Null
                } 
            } 
            Write-Host "Velykket opperasjon" -ForegroundColor Green             
            write-host "-------------------`n"             
            if($errStoerelse -ne 0) { 
                Write-Host "Brukere som feilet`n"                 
                write-Host $utskriftBruker 
            } 
                        
            $sjekk = $true 
        } 
    }while($sjekk -eq $false) 
} 