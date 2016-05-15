#Funksjonen tar inn fornavn og etternavn og lager et brukernavn ut av de første 3 bokstavene i hver.
function Set-Brukernavn($fornavn, $etternavn) {
    #Setter midlertidig variabelen til $null slik at den ikke inneholder noe fra tidligere.
    $MidlertidigBrukernavn = $null
    $sjekk = $true

    #If-testene under sjekker om lengden på fornavn og etternavn. Hvis etternavnet er på to bokstaver blir brukernavent på to bokstaver i stedet for tre
    if($fornavn.length -le 2){
        $brukernavn = $fornavn.substring(0,2) 
    }else{
        $brukernavn = $fornavn.substring(0,3)
    }
    if($etternavn.length -le 2){
        $brukernavn += $etternavn.substring(0,2) 
    }else{
        $brukernavn += $etternavn.substring(0,3)
    }
    #Telleren bli satt til en. Den skal brukes hvis brukernavnet allerede er i bruk
    $teller = 1
    #Bruker Format-Brukernavn
    $navn = Format-Brukernavn($brukernavn)
    $MidlertidigBrukernavn = $navn
    do{
        #Sjekker om brukernavnet er i bruk. Hvis brukernavn ikke finnes er resultatet
        $null
        $finnes = Get-ADUser -Filter {SamAccountName -eq $MidlertidigBrukernavn}
        #Hvis $finnes er lik $null
        if($finnes -eq $null){
            $sjekk = $false
            $navn = $MidlertidigBrukernavn
        }else{
            #Hvis det er to like brukernavn vil teller bli lagt til slutten av
            brukernavnet for å skille de.
            $MidlertidigBrukernavn = $navn + $teller 
            #inkrementerer teller slik at en får et annet brukernavn neste gang.
            $teller +=1
        }
    }while($sjekk -eq $true)
    return $navn
} 
