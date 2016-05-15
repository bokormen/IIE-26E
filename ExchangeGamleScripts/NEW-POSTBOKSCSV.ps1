#Oppretter en ny postboks fra en CSV-fil
Function New-PostboksCSV{
    #Henter ut domene
    $Domene = Get-ADDomain
    #Henter du forest navnet. Det inneholder domenenavnet
    $Forest = $domene.forest
    $Sti = Read-Host "Skriv inn sti til CSV-fil"
    #CSV-filen har parametrene fornavn, etternavn, ou og passord

    #Henter ut informasjonen som er i CSV-filen. Det som skiller de ulike argumentene er ;
    $Brukere = Import-CSV $sti -Delimiter ";"  
    #Går igjennom alle brukerene.
    foreach ($Bruker in $Brukere){   
        #Konverterer passordet over til sikker tekst
        $Passord = ConvertTo-SecureString $Bruker.Passord -AsPlainText -force
        #Henter ut etternavn
        $Etternavn = $Bruker.Etternavn 
        #Henter ut fornavn
        $Fornavn = $Bruker.Fornavn
        #Henter ut OU-sti
        $OU = $Bruker.OU
        #Får et unikt brukernavn
        [String]$Brukernavn = Set-Brukernavn $Fornavn $Etternavn
        #Tar bort mellomrom ol.
        $Brukernavn = $Brukernavn.Trim()
        
        
        #Oppretter fultnavn ut fra fornavn og etternavn
        $FultNavn = $Fornavn  + " " + $Etternavn
        #Oppretter postboks
        New-Mailbox -UserPrincipalName $brukernavn@$forest -Alias $Brukernavn –name $FultNavn -OrganizationalUnit $Forest/$OU -Password $Passord -FirstName $Fornavn -LastName $Etternavn -DisplayName $FultNavn -ResetPasswordOnNextLogon $false
    }
}

