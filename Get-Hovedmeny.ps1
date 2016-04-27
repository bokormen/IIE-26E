function Get-Hovedmeny() {
    
    param([string]$fremtidigeValg,[string]$valgGjort)

    [bool]$isRetteParametere = $true
    
    $menyElementer = @("valg1","valg2","valg3","valg4","Tilbake","Til hovedmeny", "Avslutt")

    [int]$valg = 0

    $fremtidigeMenyValg = @()

    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","

    foreach ($int in $fremtidigeValgSplittet) {
        if(![bool]($int -as [int] -is [int])) {
            $isRetteParametere = $false
        }
    }

    foreach ($int in $valgGjortSplittet) {
        if(![bool]($int -as [int] -is [int])) {
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
        
        if($fremtidigeMenyValg.Length -gt 1) {
            
            $fremtidigeValg = ""

            for ($i=1;$i -lt ($fremtidigeMenyValg.Count - 1) ; $i++) {
                $fremtidigeValg += [string]$fremtidigeMenyValg[$i]
                $fremtidigeValg += ","
            }

            $fremtidigeValg += $fremtidigeMenyValg[-1]

        } else {
            $fremtidigeValg = ""
        }
    }

    if ($valgGjort -ge 1) {
        $valgGjort += ","
        $valgGjort += [string]$valg
    } else {
        $valgGjort = [string]$valg
    }

    switch ([int]$valg) {
        1 {
            Write-Host "valg 1"
            Get-Hovedmeny $fremtidigeValg $valgGjort
        }
        2 {
            Write-Host "valg 2"
            Get-Hovedmeny $fremtidigeValg $valgGjort
        }
        3{
            Write-Host "valg 3"
            Get-Hovedmeny $fremtidigeValg $valgGjort
        }
        4{ #Dette er Tilbake valget, og grunnen til at funksjonen kan ta inn to variabler
            Write-Host "valg 4"
            if ($valgGjort.Length -gt 1) {
                $fremtidigeValg = ""
                $fremtidigeMenyValg = $valgGjort -split ","
                if ($fremtidigeMenyValg.Count -gt 2) {
                    $i=0
                    for($i=0;$i -lt ($fremtidigeMenyValg.Count-3);$i++) {
                        $fremtidigeValg += $fremtidigeMenyValg[$i]
                        $fremtidigeValg += ","
                    }
                    $fremtidigeValg += $fremtidigeMenyValg[$i++]
                }
                Get-Hovedmeny $fremtidigeValg ""
                
            } else {
                Get-Hovedmeny
            }
        }
        5 {
            Write-Host "valg 5"
            Get-Hovedmeny
        }
        6{
            Clear
        }
        default {
            Write-Host "valg default"
            Get-Hovedmeny
        }
    }
}