#Oppretter en ny postboks
function New-Postboks{
    $fornavn = Read-Host "Hva er fornavnet til brukeren?"
    #sjekker om lengden på fornavn er lengre enn 2
    while ($fornavn.length -lt 2){
        $fornavn = Read-Host "Fornavnet må inneholde minst to bokstaver. Skriv inn på
        nytt"
    }
    $etternavn = Read-Host "Hva er etternavnet til brukeren?"
    #sjekker om lengden på etternavn er lengre enn 2
    while ($etternavn.length -lt 2){
        $etternavn = Read-Host "Etternavnet må inneholde minst to bokstaver. Skriv inn
        på nytt"
    }
    #Oppretter fultnavn ut fra fornavn og etternavn
    $FultNavn = $Fornavn  + " " + $Etternavn
    #Får et unikt brukernavn
    [string]$Brukernavn = Set-Brukernavn $fornavn $etternavn
    #Tar bort mellomrom ol.
    $Brukernavn = $Brukernavn.Trim()
    #Henter ut domene
    $Domene = Get-ADDomain
    #Henter du forest navnet. Det inneholder domenenavnet
    $Forest = $Domene.forest

    #Skriver ut alle OU-ene
    $OU = Get-OU
    do{
        $sjekkInt = $false
        $valgOU = $null
        #Try-Catch er der for å sjekke om brukeren har skrevet inn et gyldig tall
        try{
            #Konverterer fra streng til int
            [int]$ValgOU = Read-Host "Velg OU-en du ønsker å legge brukeren til (eks 
	      1)"
        }catch{
            Write-Host "Ugyldig input" -ForegroundColor Red
            $sjekkInt = $true
        }
    }while (($ValgOU -gt $OU.length-1) -or ($ValgOU -eq "") -or $sjekkInt -eq $true)
  

    do{
        #Sjekker om passordet som er skrevet inn er like.
        do{
            $Passord = Read-Host "Skriv inn passord til brukeren" 
            $Passord2 = Read-Host "Gjenta passord" 

            if($Passord -ne $Passord2){
            Write-Host "Passordene smmsvarer ikke" -ForegroundColor Red
            }
        }while($Passord -ne $Passord2)
        #sjekker om passordet oppfyller de kravene vi har satt til passord
        $sjekkPassord = Confirm-Passord $Passord
    }while($sjekkPassord -eq $false)
    #konverterer passord over til sikker tekst
    $Passord = ConvertTo-SecureString $Passord -AsPlainText -force

    #Oppretter postboks
    New-Mailbox -UserPrincipalName $Brukernavn@$Forest -Alias $Brukernavn –name $FultNavn -OrganizationalUnit $OU[$ValgOU].CanonicalName -Password $Passord -FirstName $Fornavn -LastName $Etternavn -DisplayName $FultNavn -ResetPasswordOnNextLogon $false
    
    Write-Host "$FultNavn fikk en postboks" -ForegroundColor Green
}
