# Kilde: http://www.codetwo.com/kb/how-to-connect-to-exchange-server-via-powershell/
# Kilde: http://www.network-lab.net/2014/12/remote-powershell-to-exchange-2013.html

function Start-RemoteExchangeSession() {
    $UserCredentials = Get-Credential -Credential exchange@iie-26e

    $SessionOpt = New-PSSessionOption -SkipCACheck:$true -SkipCNCheck:$true -SkipRevocationCheck:$true

    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://158.38.56.180/Powershell/ -Credential $UserCredentials -AllowRedirection -SessionOption $SessionOpt -Authentication Basic

    Import-PSSession $Session
}