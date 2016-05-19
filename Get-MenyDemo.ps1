function Get-MenyDemo() {
    
    # Paramterene, $fremtidsvalg inneholder valg som skal gjøres, mens $valgGjort inneholder en historikk, begge to er stringer som inneholder tall, adskilt med komma
    # Disse to parameterene brukes for å kunne tilby tilbake valget i menyen
    param([string]$fremtidigeValg,[string]$valgGjort)

    # Fjerner tidligere utskrift fra konsollen, slik at brukeren får en ryddig meny
    Clear-Host

    # Boolsk verdi som brukes for å kontrollere at parameterene som er gitt, kunn inneholder tall, adskilt med komma
    [bool]$isRetteParametere = $true
    
    # Dette er en array som inneholder teksten på de forskjellige menyvalgene
    $menyElementer = @("valg1","valg2","valg3","valg4","Tilbake","Til hovedmeny", "Avslutt")

    # Dette er variablen som brukes for å lagre menyvalget brukeren gjør
    [int]$valg = 0

    # Dette er variablen som brukes for å lagre valgene som skal gjøres i neste nivå av menyene
    $fremtidigeMenyValg = @()

    # Disse to variablene inneholder de to tilsendte variablene, men konveterer dem fra stringer til arrays for å gjøre dem enkelere å jobbe med
    $fremtidigeValgSplittet = $fremtidigeValg -split ","
    $valgGjortSplittet = $valgGjort -split ","

    Write-Host "fremtidsvalg " $fremtidigeValgSplittet -ForegroundColor Cyan
    Write-Host "valg gjort " $valgGjortSplittet -ForegroundColor DarkCyan

    # Denne løkken går igjennom innholdet i $fremtidigeValtSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $fremtidigeValgSplittet) {
        Write-Host "int: $int | Count" $fremtidigeValgSplittet.Count -ForegroundColor Gray
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($fremtidigeValgSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Denne løkken går igjennom innholdet i $valgGjortSplittet, og kontrollerer at alle elementene i arrayen er tall
    foreach ($int in $valgGjortSplittet) {
        if((![bool]($int -as [int] -is [int])) -or (($int -eq "") -and ($valgGjortSplittet.Count -gt 1))) {
            $isRetteParametere = $false
        }
    }

    # Hvis et element i $valgGjortSplittet eller $fremtidigeValtSplittet ikke er et tall, så vil koden videre gå utifra at det ikke er sendt ved noen paramentere til menyen, og det skrives ut en advarsel om dette
    if(!$isRetteParametere) {
        #Parameterene "nullstilles"
        $fremtidigeValg = ""
        $valgGjort = ""
        
        #det skrives ut en advarsel, og programmet settes på pause, slik at brukeren får anledning til å lese feilmeldingen før den viskes vekk av en CLear-Host senere i skriptet
        Write-Host "Parameterene som ble gitt, var ikke 0-2 stringer bestående av tall, adskilt med komma.`nGår videre som om det ikke ble gitt noen parametere" -ForegroundColor Red
        Pause
    }

    # Denne ifsettnigen sjekket om det er sendt ved en liste med valg som skal gjøres, hvis listen er tom, så spør den brukeren om hvilket valg som skal gjøres
    # Hvis listen med valg som skal gjøres ikke er tom, hentes valget ut fra listen, og fjernes fra listen
    if ($fremtidigeValg.Length -eq 0) {
        # spør brukeren som hvilket valg som skal bli gjort
        $valg = Get-Menyvalg $menyElementer
    } else {
        # Gjør stringen, som inneholder valgene som skal gjøres, om til en array som er enklere å jobbe videre med
        $fremtidigeMenyValg = $fremtidigeValg -split ","
        
        # Henter ut valget som skal gjøres
        $valg = [int]$fremtidigeMenyValg[0]
        
        # I denne ifsettnigen fjernes valget som er gjort, og resten av arrayen gjøres om til en string som kan sendes videre,
        # hvis arrayen kun inneholder et element, så gjøres stringen som skal sendes videre om til en tom string
        if($fremtidigeMenyValg.Count -gt 1) {
            
            # Gjør stringen som skal sendes videre tom, så den kun inneholder de valgene som skal gjøres når de senere valgene legges til
            $fremtidigeValg = ""

            # Legger til de fremtidige valgene som skal gjøres
            if ($fremtidigeMenyValg.Count -eq 2) {
                # Hvis det barae er et valg, så legges dette valget inn i stringen
               $fremtidigeValg = [string]$fremtidigeMenyValg[1]
            } else {
                #Hvis det er flere valg som skal gjøres, så legges de første valgene inn foran i stringen, med et komma foran, før det siste legges til uten et komma før seg
                for ($i=($fremtidigeMenyValg.Count-1);$i -gt 1;$i--) {
                    #De første valgene legges inn, fra siste valget som skal gjøres, til neest siste valget som senere skal gjøres, tallene legges til i starten stringer som skal innholde fremtidige valg
                    $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i]+ $fremtidigeValg
                }
                # Siste valget som skal gjøres i fremtiden legges inn, uten at det legges til et komma foran
                $fremtidigeValg = [string]$fremtidigeMenyValg[1] + $fremtidigeValg
            }

        } else {
            # Hvis listen over fremtidige valg kunn inneholdt et element, så sendes det med en tom string videre
            $fremtidigeValg = ""
        }
    }

    Write-Host "valg gjort: "$valgGjort -ForegroundColor Yellow

    # Valget som er gjort i denne menyen legges til i historikken som sendes videre, dette gjørers som nevnt tidligere, slik at tilbakefunksjonaliteten skal fungere
    if ($valgGjort.Length -ge 1) {
        #Hvis historikken allerede inneholder et element, så legges vaglet for denne menyen til i starten av stringen, men et komma mellom valget, og stringen som inneholder hostorikken
        $valgGjort = $valgGjort + "," + [string]$valg
        write-host "valg gjort " $valgGjort -ForegroundColor DarkGreen
    } else {
        # Hvis det ikke er gjort noen tidligere valg, så legges valget som er gjort i denne menyen inn i en string som ikke skal inneholde noe annet
        $valgGjort = [string]$valg
        write-host "valg gjort " $valgGjort -ForegroundColor Magenta
    }
    # TODO Skal fjernes i en egentlig meny, er til for feilsøking
    pause

    # Valget som er gjort slåes opp i denne switch funksjonen, og valgets tilhørende kode utføres
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

            # Stringen som inneholder historikken splittes opp, og plasseres i en array for å gjøre det lettere å bearbeide den
            $fremtidigeMenyValg = $valgGjort -split ","

            # Det gjøres en sjekk på hvor mange valg som er gjort til nå, hvis det bare er gjort et, så sendes man rett tilbake til hovedmenyen
            if ($fremtidigeMenyValg.Count -gt 1) {
                write-host "valg gjort: " $valgGjort -ForegroundColor Green
                
                # Stringen som skal inneholde de fremtidige valgene som skal gjøres for å komme til menyen et hakk lengre opp i menyhireakiet en gjellende meny
                $fremtidigeValg = ""

                # I denne if settningen legges alle utenom de to siste valgene som er gjort (valget som ført frem til gjellende meny, og valget om å gå tilbake) inn i en string som forteller hvilke valg som skal gjøres for å komme til forrige meny
                if($fremtidigeMenyValg.Count -gt 2) {
                    
                    # Stringen som inneholder valgene som skal gjøres, tømmes før den fylles opp igjen
                    $fremtidigeValg = ""

                    # Fremtidige valg legges inn i stringen
                    if ($fremtidigeMenyValg.Count -eq 3) {
                        # Hvis det bare er et valg som skal gjøres, legges den rett inn i stringen, uten å legge til noe komma i tilleg
                       $fremtidigeValg = [string]$fremtidigeMenyValg[0]
                    } else {
                        # Hvis det skal gjøres flere valg, så legges de førest inn i starten av stringen, med et komma foran seg
                        for ($i=($fremtidigeMenyValg.Count-3);$i -gt 0;$i--) {
                            # Valgene legges inn i starten av stringen, og det legges til et komma først i stringen
                            $fremtidigeValg =  "," + [string]$fremtidigeMenyValg[$i] + $fremtidigeValg
                        }
                        # Siste valget legges inn uten et komma
                        $fremtidigeValg = [string]$fremtidigeMenyValg[0] + $fremtidigeValg
                    }
                }
                write-host "fermtidige valg: " $fremtidigeValg -ForegroundColor Green
                pause
                # Valgene som skal gjøres for å gå tilbake til forrige meny sendes til hovedmenyen, med en tom historikk
                Get-Hovedmeny "$fremtidigeValg" ""
                
            } else {
                # Hvis det bare et gjort et valg, så skal brukeren sendes til hovedmenyen
                Get-Hovedmeny
            }
        }
        5 {
            Write-Host "valg 5"
            # Hvis brukeren ønsker å gå tilbake til hovedmenyen, så sendes man tilbake til hovedmenyen, uten historikken om hvilke valg som er gjort til nå
            Get-Hovedmeny
        }
        6 {
            # Hvis man ønsker å avslutte, så fjernes innholdet i konsollvinduet, og whileløkken som sørger for å vise menyen hver gang en funksjon har kjørt ferdig, avsluttes, slik at skriptet avsluttes
            Clear-Host
            Break exchangeAdministrasjon
        }
        default {# Skulle koden som sjekket om valget som er sendt inn slippe igjennom et valg som ikke stemmer, så skrives det ut en advarsel og koden sender brukeren tilbake til hovedmenyen
            # Det skrives ut en feilmelding i rødt
            Write-Host "$valg er ikke et alternativ i denne menyen, returnerer til hovedmenyen" -ForegroundColor Red
            # Menyelementene det kunne velges mellom vises og, disse skrives ut i gul skrift
            $i = 0
            Foreach($element in $menyElementer) {
                Write-Host $i ": " $element -ForegroundColor Yellow
                $i++
            }
            # Skriptet settes på pause slik at brukeren kan få med seg feilmeldingen som er skrevet ut
            Pause

            Get-Hovedmeny
        }
    }
}