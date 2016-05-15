function Confirm-Passord ($Passord){
    #Oppretter boolean sjekker for å finne feil ved passordet.
    $sjekkStor = $false
    $sjekkLiten = $false
    $SjekkTall = $false

    #sjekkPassord er sjekken som sier om passordet er godkjent eller ikke
    $sjekkPassord = $true

#Den første testen sjekker om lengden på passordet er godkjent. Den må være minst 8 tegn langt.
    if($Passord.Length -lt 8){
        Write-Host "Lengden på passordet er for kort" -ForegroundColor Red
        $sjekkPassord = $false
    }else{
        #Vi benytter for-løkke for vi skal gå igjennom alle bokstavene som er i passord teksten.
        for($i=0;$i-lt $Passord.length;$i++){
            #Denne linjen tar ut en og en bokstav. $i variabelen blir inkrementert med en, og dermed går en gjennom hele teksten
            $midlertidig = $Passord.Substring($i,1)

            #Sjekker om bokstaven er stor. I Ascii tabellen er store bokstaver mellom 65 og 90. Vi godkjenner ikke ÆØÅ
            if([char]$midlertidig -ge 65 -and [char]$midlertidig -le 90){
                #Setter sjekkStor til sann
                $sjekkStor = $true
            }
            #Sjekker om bokstaven er liten. I Ascii tabellen er litenbokstav mellom 97 til 122. Vi godkjenner ikke æøå
            if([char]$midlertidig -ge 97 -and [char]$midlertidig -le 122){
                $sjekkLiten = $true
            }
            #Sjekker om bokstaven er et tall. I Ascii tabellen er tall mellom 48 til 57. 
            if([char]$midlertidig -ge 48 -and [char]$midlertidig -le 57){
                $sjekkTall = $true
            }
        }
        #Hvis sjekkStor er usann. 
        if($sjekkStor -eq $false){
            Write-Host "Du mangler stor bokstav i passordet" -ForegroundColor Red
            #sjekkPassord settes til usann siden passordet mangler minst storbokstav
            $sjekkPassord = $false
        }
        if($sjekkLiten -eq $false){
            Write-Host "Du mangler liten bokstav i passordet" -ForegroundColor Red
            #sjekkPassord settes til usann siden passordet mangler minst litenbokstav
            $sjekkPassord = $false
        }
        if($SjekkTall -eq $false){
            Write-Host "Du mangler tall i passordet" -ForegroundColor Red
            #sjekkPassord settes til usann siden passordet mangler minst tall
            $sjekkPassord = $false
        }
    }
    #Returnerer sann eller usann
    return $sjekkPassord
} 
