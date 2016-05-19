
#Funksjonen tar imot et brukernavn, og navnet på en e-postkonto, og returnerer en liste med rettigheter denne brukeren har til denne e-postkontoen. Funkjsonen forholder seg kun til rettighetene FullAccess, Send-As, og SendOnBehalfOf og tar ikke hensyn til arv
function Get-ListeOverGitteBrukerrettigher() {

    #parameterene som blir sendt til funksjonen får navn jeg kan bruke videre
    param([string]$bruker,[string]$epostkonto)


    # Initialiserer ArrayList-en som skal inneholde de forskjellige rettighetene brukeren har til e-postkontoen
    $Resultat = [System.Collections.ArrayList]@()

    
    # Denne bolken sjekker om brukeren har tilgangen FullAccess,
    # Utskriften fra funksjonen som sjekker for rettigheten behandles slik at vi sitter igjen med bare rettighetene brukeren har til e-postkontoen
    # Denne delen kan enkelt modifiseres til å sjekke for rettighetene DeleteItem, ReadPermission, ChangePermission, ChangeOwner ved å legge til flere ifsettniger som sjekker innholdet i arraylisten
    $ResultatMailboxPermission = [System.Collections.ArrayList]((Get-MailboxPermission -Identity $epostkonto -User $bruker | Select-Object AccessRights | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace('{','').Replace('}','').Replace("`n",", ").Replace("`r",", ").Trim()).Split(", ",[System.StringSplitOptions]::RemoveEmptyEntries)

    if($ResultatMailboxPermission.Contains("FullAccess")) {
        $Resultat.Add("FullAccess")  | Out-Null # Out-Null sørger for at utskriften fra denne kommandoen ikke blir en del av returverdien fra funksjonen
    }


    # Denne bolken sjekker om brukeren har tilgangen Send-As,
    # Utskriften fra funksjonen som sjekker for rettigheten behandles slik at vi sitter igjen med bare rettighetene brukeren har til e-postkontoen
    $ResultatSendAs = (Get-Mailbox -Identity $epostkonto | Get-ADPermission -User $bruker | where {($_.ExtendedRights -like “*Send-As*”)} | Select-Object ExtendedRights | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Replace('{','').Replace('}','').Replace("`n","").Replace("`r","").trim()
    
    if($ResultatSendAs -ne "") {
        $Resultat.Add("SendAs") | Out-Null
    }


    # Denne bolken sjekker om brukeren har tilgangen SendOnBehalfOf,
    # Utskriften fra funksjonen som sjekker for rettigheten behandles slik at vi sitter igjen med bare rettighetene brukeren har til e-postkontoen
    $ResultatSendOnBehalf = [System.Collections.ArrayList]((Get-Mailbox -resultsize unlimited | Where {($_.GrantSendOnBehalfTo -ne $null) -and ([string]$_.Alias -eq $epostkonto)} | Select-Object GrantSendOnBehalfTo | Format-Table -HideTableHeaders -Wrap | Out-String).Replace('{','').Replace('}','').Replace("`n","").Replace("`r","").Trim()).Split(",",[System.StringSplitOptions]::RemoveEmptyEntries)
    
    foreach ($element in $ResultatSendOnBehalf) {
        $temp = (Get-Mailbox $element.trim() | Select Alias | Format-Table -HideTableHeaders -AutoSize -Wrap | Out-String).Trim()

        if ($temp -eq $bruker) {
            $Resultat.Add("SendOnBehalfOf") | Out-Null # Out-Null sørger for at utskriften fra denne kommandoen ikke blir en del av returverdien fra funksjonen
        }
    }

    
    # Denne linjen forsikrer om at hver rettighet bare er listet en gang
    $Resultat = $Resultat | Select -Unique


    # Initialiserer returverdien, som er en string, har valgt å returnere en string, fordi PowerShell er litt sær når Array sendes mellom funksjoner
    $returverdi = ""

    # Rettighetene legges inn i stringen som skal returneres
    Foreach ($rettighet in $Resultat) {
        if ($rettighet -ne "") {
            $returverdi += "$rettighet,"
        }
    }

    # Hvis returverdien ikke er tom, inneholder den når et unødvendig komma på slutten, som fjernes i denne if settningen
    if ($returverdi-ne "") {
        $returverdi = $returverdi.Substring(0,($returverdi.Length-1))
    }

    # Funksjonen avsluttes
    return $returverdi

}