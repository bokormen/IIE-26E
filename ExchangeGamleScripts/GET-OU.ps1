#Funksjonen skriver ut alle OU-ene i domenet
function Get-OU{
    #Henter ut alle OU-ene i domenet. Alle egenskapene bli hentet ut
    $OU = Get-ADOrganizationalUnit -Filter * -Properties *
    #Oppretter en teller som skal brukes til utskriften for brukeren.
    $teller = 0
    foreach ($i in $OU.DistinguishedName){
        <#
        legger en teller forann utskriften slik at brukeren av scriptet slipper å skrive inn heile stien til OU-en.
        I steden for kan brukeren bare skrive tallet forann OU-stien
        #>
        Write-Host $teller : $i
        $teller++
    }
    #Returnerer alle Ou-ene med alle egenskaper
    return $OU
}
