function Get-Menyvalg() {
    param([string[]]$menyvalg)

    [int]$i = 0

    Foreach($mulighet in $menyvalg) {
        Write-Host $i ": " $mulighet
        $i++
    }

    $valg = Read-Host -Prompt "Skriv inn valget ditt"
    $heltall = 0
    $gyldigIntValg = $true
    
    do {
        while (![bool]($valg -as [int] -is [int]) -or !$gyldigIntValg) {
            $i=0
            Foreach($mulighet in $menyvalg) {
                Write-Host $i ": " $mulighet
                $i++
            }
            Write-Host "Du skrev inn noe som ikke er et heltall mellom 0 og " ($menyvalg.Length - 1) -ForegroundColor Red
            $valg = Read-Host "Skriv inn valget ditt: "
            $gyldigIntValg = $true
        
        }
        $heltall = [math]::Round($valg)
        $valg=[double]$valg

        if (($valg -ne $heltall) -or ($valg -lt 0) -or ($valg -ge ($menyvalg.Length))) {
            $gyldigIntValg = $false
        }

    } while (!$gyldigIntValg)

    return [int]$valg
        
}