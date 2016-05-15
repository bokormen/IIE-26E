function Remove-Brukerrettigheter() {
    Clear-Host
    $bruker = Get-Epostkonto "Skriv inn navnet på brukeren som skal miste rettigheter til en annen konto (brukeren må ha en e-postkonto aktivert)"
    Clear-Host
    $konto = Get-Epostkonto "Skriv inn navnet på kontoen som $bruker skal miste rettighet til"
    Clear-Host

    $rettigheterSomKanMistes = Get-ListeOverGitteBrukerrettigher $bruker $konto

    $rettigheterSomKanMistes = [System.Collections.ArrayList]$rettigheterSomKanMistes.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    $rettigheterSomKanMistes.Add("Ønsker ikke å frata $bruker rettigheter til kontoen $konto") | Out-Null


    if($rettigheterSomKanMistes.Count -gt 1) {
        Write-Host "Rettigheter $bruker kan bli fratatt fra kontoen $konto :"
        $i = 0
        foreach($rettighet in $rettigheterSomKanMistes) {
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        Write-Host "$bruker kan ikke bli fratatt flere rettigheter til kontoen $konto `n"
        Pause
        Return
    }

    $erRetteVerdier = [boolean]$true
    $gamleRettigheter = ""

    do {

        $erRetteVerdier = [boolean]$true

        $gamleRettigheter = Read-Host "`n`nSkriv inn nummeret som står før rettigheten du ønsker å frata $bruker til kontoen $konto`nOm du ønsker å frata flere rettigheter, så kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene på rettigheten(e) du ønsker å frata"

        $gamleRettigheter.Trim(" ") | Out-Null

        $gamleRettigheter = [System.Collections.ArrayList]$gamleRettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        $temp = $gamleRettigheter | Get-Unique

        if($gamleRettigheter.Count -eq 0) {
            
            Write-Host "Du kan ikke bare trykke på enter, du måt gjøre et valg, om du øsnker å avslutte, kan du skrive inn" ($rettigheterSomKanMistes.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false

        } elseif($temp.count -eq $gamleRettigheter.Count) {

            foreach($valg in $gamleRettigheter) {
            
                if(![boolean]($valg -as [int] -is [int])) {

                    Write-Host "$valg er ikke et tall, du må liste opp rettighetene du ønsker å frata på nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    Break

                } else {

                    $valg = [int]$valg

                    if(($valg -lt 0) -or ($valg -ge $rettigheterSomKanMistes.Count)) {

                        Write-Host "$valg er ikke er tall mellom 0 og" ($rettigheterSomKanMistes.Count-1) ", du må skrive inn valgene på nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        Break

                    } elseif (($valg -eq ($rettigheterSomKanMistes.Count-1)) -and ($gamleRettigheter.Count -gt 1)) {

                        Write-Host "Du kan ikke legge til rettigheter, og samtidig gjøre valget:" $rettigheterSomKanMistes[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($rettigheterSomKanMistes.Count-2) "separert med komma, eller bare" ($rettigheterSomKanMistes.Count-1)  -ForegroundColor Red
                        $erRetteVerdier = $false
                        Break

                    }
                }
            }
        } else {

            Write-Host "Du kan kunn skrive inn unike verdier, separert med komma, du kan ikke liste opp en rettighet to ganger" -ForegroundColor Red
            $erRetteVerdier = $false

        }

    } while (!$erRetteVerdier)

    if($gamleRettigheter[0] -eq ($rettigheter.Count -1)) {
        return
    }
    
    # OBS OBS, dette er ikke en god "hack" da Name ikke nødvendigvis er en unik identifikator, men funksjonene som legger til rettigheter vil ikke ta imot Alias som en variabel
    $kontoNavn = Get-Mailbox $konto –ErrorAction SilentlyContinue | Select Name | Format-Table -HideTableHeaders | Out-String
    $kontoNavn = $kontoNavn.Trim().Replace("`n","").Replace("`r","")

    foreach($valg in $gamleRettigheter) {
        switch ($rettigheterSomKanMistes[[int]$valg]) {
            "FullAccess"{
                Remove-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights 'FullAccess' -InheritanceType 'All' -Confirm:$false | Out-Null
            }
            "SendAs"{
                Remove-ADPermission -Identity $kontoNavn -User $bruker -ExtendedRights 'Send-As' -InheritanceType 'All' -ChildObjectTypes $null -InheritedObjectType $null -Properties $null -Confirm:$false | Out-Null
            }
            "SendOnBehalfOf"{
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Remove=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $rettigheterSomKanMistes[[int]$valg] "ble forsøkt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    $rettigheterSomKanMistes = Get-ListeOverGitteBrukerrettigher $bruker $konto

    $rettigheterSomKanMistes = [System.Collections.ArrayList]$rettigheterSomKanMistes.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    Clear-Host
    Write-Host "Rettigheter er blitt fjernet, rettighetene $bruker forsatt har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheterSomKanMistes) {
        Write-Host "    - $rettighet"
    }
    Pause

    #Set-Mailbox -Identity $konto -GrantSendOnBehalfTo {Remove="$bruker"}
    #Remove-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights 'FullAccess' -InheritanceType 'All'
    #Remove-ADPermission -Identity $kontoNavn -User $bruker -ExtendedRights 'Send-As' -InheritanceType 'All' -ChildObjectTypes $null -InheritedObjectType $null -Properties $null 
}