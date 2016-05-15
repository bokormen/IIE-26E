#Funksjonen tar imot et brukernavn og formaterer det til små bokstaver og endrer æøå til eoa 
function Format-Brukernavn ($brukernavn){
    #setter brukernavn til små bokstaver
    $brukernavn=$brukernavn.ToLower()
    #Erstatter æøå med eoa
    $brukernavn=$brukernavn.replace('æ','e')
    $brukernavn=$brukernavn.replace('ø','o')
    $brukernavn=$brukernavn.replace('å','a')
    #Returnere det formatere brukernavnet    
    return $brukernavn
} 
