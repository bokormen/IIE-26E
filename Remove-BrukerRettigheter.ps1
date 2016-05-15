function Remove-Brukerrettigheter() {
    #Set-Mailbox $konto -GrantSendOnBehalfTo {Remove="$bruker"}
    #Remove-MailboxPermission $konto -User $bruker -AccessRights 'FullAccess' -InheritanceType 'All'
    #Remove-ADPermission $konto -User $bruker -ExtendedRights 'Send-As' -InheritanceType 'All' -ChildObjectTypes $null -InheritedObjectType $null -Properties $null 
}