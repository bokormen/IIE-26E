#Oppretter en ny kontaktliste 
function Remove-Kontaktliste{

    [string]$navn = Read-Host "Skriv inn navn på distribusjonsgruppe"     
    if($navn -ne ""){ 
        #sjekker om kontaklisten finnes fra før 
        $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
        $sjekkNavn = Invoke-Command -ScriptBlock $scriptblock
    } 

    #Løkken går så lenge gruppen ikke finnes fra før
    while($sjekkNavn -eq $null -or $navn -eq ""){ 
             
        $navn = Read-Host "distribusjonsgruppen ser ikke ut til å eksistere. Skriv inn nytt navn på distribusjonsgruppe"             
        if($navn -ne ""){
            $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
            $sjekkNavn = Invoke-Command -ScriptBlock $scriptblock
        } 
    } 
    #Sletter en kontaktliste, legger utskriften i en variabel, slik at vi har kontroll på hva som blir skrevet ut
    $enVariabel = Remove-DistributionGroup $navn
    
    #Tester om gruppen fortsatt eksisterer  
    $scriptblock = [scriptblock]::Create("Get-DistributionGroup -Filter {name -eq `"$navn`"}")
    $eksistererGruppen = Invoke-Command -ScriptBlock $scriptblock

    if($eksistererGruppen -ne $null) {
        Write-Host "Det ser ut til å ha skjedd en feil, distribusjonsgruppen eksisterer fortsatt" -ForegroundColor Red
    }
}