function List-DeltPostboks() {
    Get-mailbox -RecipientTypeDetails sharedmailbox -Resultsize unlimited
}