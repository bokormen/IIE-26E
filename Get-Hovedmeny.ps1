function Get-Hovedmeny() {
    
    param([string]$fremtidigeValg,[string]$valgGjort)

    clear

    [bool]$isRetteParametere = $true
    
    $menyElementer = @("valg1","valg2","valg3","valg4","Tilbake","Til hovedmeny", "Avslutt")

    [int]$valg = 0

    $fremtidigeMenyValg = @()

    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","

    Write-Host "fremtidsvalg " $fremtidigeValgSplittet -ForegroundColor Cyan
    Write-Host "valg gjort " $valgGjortSplittet -ForegroundColor DarkCyan

    foreach ($int in $fremtidigeValgSplittet) {
        Write-Host "int: $int | Count" $fremtidigeValgSplittet.Count -ForegroundColor Gray
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    if(!$isRetteParametere) {
        $fremtidigeValg = ""
        $valgGjort = ""
        
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer bestående av tall, adskilt med komma.`nGår videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
    }

    if ($fremtidigeValg.Length -eq 0) {
        $valg = Get-Menyvalg $menyElementer
    } else {
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        $valg = [int]$fremtidigeMenyValg[0]
        
        if($fremtidigeMenyValg.Count -gt 1) {
            
            $fremtidigeValg = ""

            if ($fremtidigeMenyValg.Count -eq 2) {
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {

                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }

                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            $fremtidigeValg = ""
        }
    }

    Write-Host "valg gjort: "$valgGjort -ForegroundColor Yellow

    if ($valgGjort.Length -ge 1) {
        $valgGjort = $valgGjort + "," + [string]$valg
        write-host "valg gjort " $valgGjort -ForegroundColor DarkGreen
    } else {
        $valgGjort = [string]$valg
        write-host "valg gjort " $valgGjort -ForegroundColor Magenta
    }
    pause

    switch ([int]$valg) {
        0 {
            Write-Host "valg 0"
            Get-Hovedmeny "$fremtidigeValg" "$valgGjort"
        }
        1 {
            Write-Host "valg 1"
            Get-Hovedmeny "$fremtidigeValg" "$valgGjort"
        }
        2 {
            Write-Host "valg 2"
            Get-Hovedmeny "$fremtidigeValg" "$valgGjort"
        }
        3 {
            Write-Host "valg 3"
            Get-Hovedmeny "$fremtidigeValg" "$valgGjort"
        }
        4 { #Dette er Tilbake valget, og grunnen til at funksjonen kan ta inn to variabler
            Write-Host "valg 4"
            if ($valgGjort.Length -gt 1) {
                write-host "valg gjort: " $valgGjort -ForegroundColor Green
                $fremtidigeValg = ""
                $fremtidigeMenyValg = $valgGjort -split ","

                if($fremtidigeMenyValg.Count -gt 2) {
            
                $fremtidigeValg = ""

                if ($fremtidigeMenyValg.Count -eq 3) {
                   $fremtidigeValg = [string]$fremtidigeMenyValg[0]
                } else {

                    for ($i=($fremtidigeMenyValg.Count-3);$i -gt 0;$i--) {
                        $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i] + $fremtidigeValg
                    }

                    $fremtidigeValg = [string]$fremtidigeMenyValg[0] + $fremtidigeValg
                }

            }

                <#if ($fremtidigeMenyValg.Count -gt 2) {
                    for($i=0;$i -lt ($fremtidigeMenyValg.Count-3);$i++) {
                        $fremtidigeValg = "," + $fremtidigeMenyValg[$i] + $fremtidigeValg
                    }
                    $fremtidigeValg = [string]$fremtidigeMenyValg[$i++] + $fremtidigeValg
                }#>
                write-host "fermtidige valg: " $fremtidigeValg -ForegroundColor Green
                pause
                Get-Hovedmeny "$fremtidigeValg" ""
                
            } else {
                Get-Hovedmeny
            }
        }
        5 {
            Write-Host "valg 5"
            Get-Hovedmeny
        }
        6 {
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {
            
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            Pause

            Get-Hovedmeny
        }
    }
}