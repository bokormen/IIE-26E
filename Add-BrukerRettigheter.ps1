function Add-Brukerrettigheter() {
    Clear-Host
    $bruker = Get-Epostkonto "Skriv inn navnet p� brukeren som skal f� rettigheter til en annen konto (brukeren m� ha en e-postkonto aktivert)"
    Clear-Host
    $konto = Get-Epostkonto "Skriv inn navnet p� kontoen som $bruker skal f� rettighet til"
    Clear-Host

    $rettigheter = Get-ListeOverGitteBrukerrettigher $bruker $konto

    $rettigheter = [System.Collections.ArrayList]$rettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    $tilgjengeligeRettigher = [System.Collections.ArrayList]@("FullAccess","SendAs","SendOnBehalfOf","�nsker ikke � legge til en ny rettighet")

    foreach ($rettighet in $rettigheter) {
        $tilgjengeligeRettigher.Remove($rettighet) | Out-Null
    }

    
    if($rettigheter.Count -gt 0) {
        Write-Host "Rettigheter $bruker allerede har til kontoen $konto :"
        foreach($rettighet in $rettigheter) {
            Write-Host "    - $rettighet"
        }
    }

    if($tilgjengeligeRettigher.Count -gt 1) {
        Write-Host "`n`nRettigheter $bruker kan bli gitt til kontoen $konto :"
        $i = 0
        foreach($rettighet in $tilgjengeligeRettigher) {
            Write-Host "    $i $rettighet"
            $i++
        }
    } else {
        Write-Host "`n`n$bruker kan ikke bli gitt flere rettigheter til kontoen $konto `n"
        Pause
        Return
    }

    $erRetteVerdier = [boolean]$true
    $nyeRettigheter = ""

    do {

        $erRetteVerdier = [boolean]$true

        $nyeRettigheter = Read-Host "`n`nSkriv inn nummeret som st�r f�r rettigheten du �nsker � gi $bruker til kontoen $konto`nOm du �nsker � tildele flere rettigheter, s� kan du liste opp flere nummer, adskilt med ,`nSkriv inn nummerene p� rettigheten(e) du �nsker � gi"

        $nyeRettigheter.Trim(" ") | Out-Null

        $nyeRettigheter = [System.Collections.ArrayList]$nyeRettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

        $temp = $nyeRettigheter | Get-Unique

        if($nyeRettigheter.Count -eq 0) {
            
            Write-Host "Du kan ikke bare trykke p� enter, du m�t gj�re et valg, om du �snker � avslutte, kan du skrive inn" ($tilgjengeligeRettigher.Count-1) -ForegroundColor Red
            $erRetteVerdier = $false

        } elseif($temp.count -eq $nyeRettigheter.Count) {

            foreach($valg in $nyeRettigheter) {
            
                if(![boolean]($valg -as [int] -is [int])) {

                    Write-Host "$valg er ikke et tall, du m� liste opp rettighetene du �nsker � tildele p� nytt" -ForegroundColor Red
                    $erRetteVerdier = $false
                    Break

                } else {

                    $valg = [int]$valg

                    if(($valg -lt 0) -or ($valg -ge $tilgjengeligeRettigher.Count)) {

                        Write-Host "$valg er ikke er tall mellom 0 og" ($tilgjengeligeRettigher.Count-1) ", du m� skrive inn valgene p� nytt, og holde deg innenfor de verdiene som er gitt" -ForegroundColor Red
                        $erRetteVerdier = $false
                        Break

                    } elseif (($valg -eq ($tilgjengeligeRettigher.Count-1)) -and ($nyeRettigheter.Count -gt 1)) {

                        Write-Host "Du kan ikke legge til rettigheter, og samtidig gj�re valget:" $tilgjengeligeRettigher[-1] -ForegroundColor Red
                        Write-Host "Skriv inn verdier mellom 0 og" ($tilgjengeligeRettigher.Count-2) "separert med komma, eller bare" ($tilgjengeligeRettigher.Count-1)  -ForegroundColor Red
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

    if($nyeRettigheter[0] -eq ($tilgjengeligeRettigher.Count -1)) {
        return
    }
    
    # OBS OBS, dette er ikke en god "hack" da Name ikke n�dvendigvis er en unik identifikator, men funksjonene som legger til rettigheter vil ikke ta imot Alias som en variabel
    $kontoNavn = Get-Mailbox $konto �ErrorAction SilentlyContinue | Select Name | Format-Table -HideTableHeaders | Out-String
    $kontoNavn = $kontoNavn.Trim().Replace("`n","").Replace("`r","")

    foreach($valg in $nyeRettigheter) {
        switch ($tilgjengeligeRettigher[[int]$valg]) {
            "FullAccess"{
                Add-MailboxPermission -Identity $kontoNavn -User $bruker -AccessRights "FullAccess" | Out-Null
            }
            "SendAs"{
                Add-ADPermission -Identity $kontoNavn -User $bruker -Extendedrights "Send-As" | Out-Null
            }
            "SendOnBehalfOf"{
                $scriptblock = [scriptblock]::Create("Set-Mailbox -Identity $konto -GrantSendOnBehalfTo @{Add=`"$bruker`"}")
                Invoke-Command -ScriptBlock $scriptblock | Out-Null
            }
            default {
                Write-Host "Det har skjedd en feil, informer presonen som vedlikeholder skriptet om dette," $tilgjengeligeRettigher[[int]$valg] "ble fors�kt valg, og finnes ikke" -ForegroundColor Red
            }
        }
    }

    $rettigheter = Get-ListeOverGitteBrukerrettigher $bruker $konto

    $rettigheter = [System.Collections.ArrayList]$rettigheter.Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)

    Clear-Host
    Write-Host "Rettigheter er blitt lagt til, rettighetene $bruker n� har til kontoen $konto :" -ForegroundColor Green
    foreach($rettighet in $rettigheter) {
        Write-Host "    - $rettighet"
    }
    Pause



    #Set-Mailbox $konto -GrantSendOnBehalfTo {Add="$bruker"}
    #Add-ADPermission $konto -User $bruker -Extendedrights "Send-As"
    #Add-MailboxPermission $konto -User $bruker -AccessRights "FullAccess"
}