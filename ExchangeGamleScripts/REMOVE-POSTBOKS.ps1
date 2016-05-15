#Funksjonen fjerner en postboks 
function Remove-postboks{ 
    $sjekk = $false 
 
    [string]$bruker = Read-Host "Skriv inn postboks som skal fjernes" 
    #Sjekker om postboksen finnes 
    $bruker = Test-Postboks $bruker 
     do{ 
        #Får to valg  enten fjerne brukeren helt eller deaktivere brukeren 
        $valg = Read-Host "1:Fjerne bruker og postboksen til $bruker`n2:Fjerne postboks, men behold $bruker i AD`n3:Avslutt`n" 
         if($valg -eq "1"){ 
            #fjerner brukeren og postboksen 
            Remove-Mailbox $bruker 
             
            #sjekker om brukeren er fjernet 
            $sjekkBruker = Get-Mailbox -Filter {SamAccountName -eq $bruker}             
            if($sjekkBruker -eq $null){ 
                Write-Host "Brukeren $bruker og tilhørende postboks ble fjernet!" -ForegroundColor Green 
            } 
            $sjekk = $true 
        }elseif($valg-eq"2"){ 
            #Deakriverer postboksen 
            Disable-Mailbox $bruker 
 
            #Sjekker om postboksen er deaktivert 
            $sjekkBruker = Get-Mailbox -Filter {SamAccountName -eq $bruker}             
            if($sjekkBruker -eq $null){ 
                Write-Host "Postboksen til $bruker ble deaktivert!" -ForegroundColor Green 
            } 
            $sjekk =$true 
        } 
    }while($sjekk -eq $false -or $valg -eq "3") 
     
}
