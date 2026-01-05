#### NEED TO EXPORT USERS TO CSV FIRST, THE DUPLICATE USERNAMES ARE MAKING THIS FAIL.
#### SHOULD DO AN EXPORT RIGHT AFTER INSERT USERS SCRIPT


[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
Else {
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
}


# Import AD Module
Import-Module ActiveDirectory -ErrorAction Stop

# Merci de spécifier le chemin complet vers le fichier csv qui contient les informations pour les utilisateurs.
$csvFilePath

$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Function to set account expiration date for AD user
function Set-ADUserExpiryDate {
    param (
        [string]$username,
        [int]$daysToAdd
    )

    $user = Get-ADUser -Identity $Username -Properties Department, Title -ErrorAction SilentlyContinue

    if ($user.Department -eq "Production" -and $user.Title -eq "Assembler") {
        $expiryDate = (Get-Date).AddDays($daysToAdd)
        Set-ADAccountExpiration -Identity $username -DateTime $expiryDate
        Write-Host "Account expiration date set for $username : $expiryDate"
    }
}

# Loop through each user in the CSV and set the expiration date
foreach ($user in $userData) {
    Set-ADUserExpiryDate -username $user.Username -daysToAdd -1 -title
}


# Please ensure that your CSV file (Users.csv) has a header row with the column Username (case-sensitive) containing the usernames for which you want to set the expiration date.

# Note: Make sure to test scripts in a safe environment before applying them to a production Active Directory. Ensure that you have the necessary permissions to modify user account information.