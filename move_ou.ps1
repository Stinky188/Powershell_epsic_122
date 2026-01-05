# Import AD Module
Import-Module ActiveDirectory
 
# Import the data from CSV file and assign it to variable
$userData = Import-Csv -Path "C:\temp\shared_mailboxes.csv"

# Specify target OU where the users will be moved to
$TargetOU = "OU=SharedMailbox,OU=Exchange,OU=Company,DC=exoip,DC=local"
 
$userData | ForEach-Object {

    # Retrieve DistinguishedName of User
    $UserDistinguishedName = (Get-ADUser -Identity $_.SamAccountName).distinguishedName

    Write-Host "Moving Accounts....."

    # Move user to target OU. Remove the -WhatIf parameter after you tested.
    Move-ADObject -Identity $UserDistinguishedName -TargetPath $TargetOU -WhatIf
} 
Write-Host "Completed move"