#Funsksjonen setter mulighet for en bruker å sende på vegne av en annen 
function Add-SendPaVegneAv($navn, $bruker){  
    Set-Mailbox $navn -GrantSendOnBehalfTo $bruker -ErrorVariable err  
#Hvis en ikke får feilmelding vil en få en utskrift som sier at operasjonen er vellykket. 
    if($err.length -eq 0){ 
        Write-Host "$bruker kan nå sende på vegne av $navn" -ForegroundColor Green 
    } 
}  
