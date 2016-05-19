function Get-MenyDemo() {
    
    # Paramterene, $fremtidsvalg inneholder valg som skal gj�res, mens $valgGjort inneholder en historikk, begge to er stringer som inneholder tall, adskilt med komma
    # Disse to parameterene brukes for � kunne tilby tilbake valget i menyen
    param([string]$fremtidigeValg,[string]$valgGjort)

    # Fjerner tidligere utskrift fra konsollen, slik at brukeren f�r en ryddig meny
    Clear-Host

    # Boolsk verdi som brukes for � kontrollere at parameterene som er gitt, kunn inneholder tall, adskilt med komma
    [bool]$isRetteParametere = $true
    
    # Dette er en array som inneholder teksten p� de forskjellige menyvalgene
    $menyElementer = @("valg1","valg2","valg3","valg4","Tilbake","Til hovedmeny", "Avslutt")

    # Dette er variablen som brukes for � lagre menyvalget brukeren gj�r
    [int]$valg = 0

    # Dette er variablen som brukes for � lagre valgene som skal gj�res i neste niv� av menyene
    $fremtidigeMenyValg = @()

    # Disse to variablene inneholder de to tilsendte variablene, men konveterer dem fra stringer til arrays for � gj�re dem enkelere � jobbe med
    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","

    Write-Host "fremtidsvalg " $fremtidigeValgSplittet -ForegroundColor Cyan
    Write-Host "valg gjort " $valgGjortSplittet -ForegroundColor DarkCyan

    # Denne l�kken g�r igjennom innholdet i $fremtidigeValtSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $fremtidigeValgSplittet) {
        Write-Host "int: $int | Count" $fremtidigeValgSplittet.Count -ForegroundColor Gray
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Denne l�kken g�r igjennom innholdet i $valgGjortSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Hvis et element i $valgGjortSplittet eller $fremtidigeValtSplittet ikke er et tall, s� vil koden videre g� utifra at det ikke er sendt ved noen paramentere til menyen, og det skrives ut en advarsel om dette
    if(!$isRetteParametere) {
        #Parameterene "nullstilles"
        $fremtidigeValg = ""
        $valgGjort = ""
        
        #det skrives ut en advarsel, og programmet settes p� pause, slik at brukeren f�r anledning til � lese feilmeldingen f�r den viskes vekk av en CLear-Host senere i skriptet
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer best�ende av tall, adskilt med komma.`nG�r videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
        Pause
    }

    # Denne ifsettnigen sjekket om det er sendt ved en liste med valg som skal gj�res, hvis listen er tom, s� sp�r den brukeren om hvilket valg som skal gj�res
    # Hvis listen med valg som skal gj�res ikke er tom, hentes valget ut fra listen, og fjernes fra listen
    if ($fremtidigeValg.Length -eq 0) {
        # sp�r brukeren som hvilket valg som skal bli gjort
        $valg = Get-Menyvalg $menyElementer
    } else {
        # Gj�r stringen, som inneholder valgene som skal gj�res, om til en array som er enklere � jobbe videre med
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        # Henter ut valget som skal gj�res
        $valg = [int]$fremtidigeMenyValg[0]
        
        # I denne ifsettnigen fjernes valget som er gjort, og resten av arrayen gj�res om til en string som kan sendes videre,
        # hvis arrayen kun inneholder et element, s� gj�res stringen som skal sendes videre om til en tom string
        if($fremtidigeMenyValg.Count -gt 1) {
            
            # Gj�r stringen som skal sendes videre tom, s� den kun inneholder de valgene som skal gj�res n�r de senere valgene legges til
            $fremtidigeValg = ""

            # Legger til de fremtidige valgene som skal gj�res
            if ($fremtidigeMenyValg.Count -eq 2) {
                # Hvis det barae er et valg, s� legges dette valget inn i stringen
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {
                #Hvis det er flere valg som skal gj�res, s� legges de f�rste valgene inn foran i stringen, med et komma foran, f�r det siste legges til uten et komma f�r seg
                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    #De f�rste valgene legges inn, fra siste valget som skal gj�res, til neest siste valget som senere skal gj�res, tallene legges til i starten stringer som skal innholde fremtidige valg
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }
                # Siste valget som skal gj�res i fremtiden legges inn, uten at det legges til et komma foran
                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            # Hvis listen over fremtidige valg kunn inneholdt et element, s� sendes det med en tom string videre
            $fremtidigeValg = ""
        }
    }

    Write-Host "valg gjort: "$valgGjort -ForegroundColor Yellow

    # Valget som er gjort i denne menyen legges til i historikken som sendes videre, dette gj�rers som nevnt tidligere, slik at tilbakefunksjonaliteten skal fungere
    if ($valgGjort.Length -ge 1) {
        #Hvis historikken allerede inneholder et element, s� legges vaglet for denne menyen til i starten av stringen, men et komma mellom valget, og stringen som inneholder hostorikken
        $valgGjort = $valgGjort + "," + [string]$valg
        write-host "valg gjort " $valgGjort -ForegroundColor DarkGreen
    } else {
        # Hvis det ikke er gjort noen tidligere valg, s� legges valget som er gjort i denne menyen inn i en string som ikke skal inneholde noe annet
        $valgGjort = [string]$valg
        write-host "valg gjort " $valgGjort -ForegroundColor Magenta
    }
    # TODO Skal fjernes i en egentlig meny, er til for feils�king
    pause

    # Valget som er gjort sl�es opp i denne switch funksjonen, og valgets tilh�rende kode utf�res
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
        4 { # Dette er Tilbake valget, og grunnen til at funksjonen kan ta inn to variabler
            Write-Host "valg 4"

            # Stringen som inneholder historikken splittes opp, og plasseres i en array for � gj�re det lettere � bearbeide den
            $fremtidigeMenyValg = $valgGjort -split ","

            # Det gj�res en sjekk p� hvor mange valg som er gjort til n�, hvis det bare er gjort et, s� sendes man rett tilbake til hovedmenyen
            if ($fremtidigeMenyValg.Count -gt 1) {
                write-host "valg gjort: " $valgGjort -ForegroundColor Green
                
                # Stringen som skal inneholde de fremtidige valgene som skal gj�res for � komme til menyen et hakk lengre opp i menyhireakiet en gjellende meny
                $fremtidigeValg = ""

                # I denne if settningen legges alle utenom de to siste valgene som er gjort (valget som f�rt frem til gjellende meny, og valget om � g� tilbake) inn i en string som forteller hvilke valg som skal gj�res for � komme til forrige meny
                if($fremtidigeMenyValg.Count -gt 2) {
                    
                    # Stringen som inneholder valgene som skal gj�res, t�mmes f�r den fylles opp igjen
                    $fremtidigeValg = ""

                    # Fremtidige valg legges inn i stringen
                    if ($fremtidigeMenyValg.Count -eq 3) {
                        # Hvis det bare er et valg som skal gj�res, legges den rett inn i stringen, uten � legge til noe komma i tilleg
                       $fremtidigeValg = [string]$fremtidigeMenyValg[0]
                    } else {
                        # Hvis det skal gj�res flere valg, s� legges de f�rest inn i starten av stringen, med et komma foran seg
                        for ($i=($fremtidigeMenyValg.Count-3);$i -gt 0;$i--) {
                            # Valgene legges inn i starten av stringen, og det legges til et komma f�rst i stringen
                            $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i] + $fremtidigeValg
                        }
                        # Siste valget legges inn uten et komma
                        $fremtidigeValg = [string]$fremtidigeMenyValg[0] + $fremtidigeValg
                    }
                }
                write-host "fermtidige valg: " $fremtidigeValg -ForegroundColor Green
                pause
                # Valgene som skal gj�res for � g� tilbake til forrige meny sendes til hovedmenyen, med en tom historikk
                Get-Hovedmeny "$fremtidigeValg" ""
                
            } else {
                # Hvis det bare et gjort et valg, s� skal brukeren sendes til hovedmenyen
                Get-Hovedmeny
            }
        }
        5 {
            Write-Host "valg 5"
            # Hvis brukeren �nsker � g� tilbake til hovedmenyen, s� sendes man tilbake til hovedmenyen, uten historikken om hvilke valg som er gjort til n�
            Get-Hovedmeny
        }
        6 {
            # Hvis man �nsker � avslutte, s� fjernes innholdet i konsollvinduet, og whilel�kken som s�rger for � vise menyen hver gang en funksjon har kj�rt ferdig, avsluttes, slik at skriptet avsluttes
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {# Skulle koden som sjekket om valget som er sendt inn slippe igjennom et valg som ikke stemmer, s� skrives det ut en advarsel og koden sender brukeren tilbake til hovedmenyen
            # Det skrives ut en feilmelding i r�dt
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            # Menyelementene det kunne velges mellom vises og, disse skrives ut i gul skrift
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            # Skriptet settes p� pause slik at brukeren kan f� med seg feilmeldingen som er skrevet ut
            Pause

            Get-Hovedmeny
        }
    }
}