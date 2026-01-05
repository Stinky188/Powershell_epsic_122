#### NEED TO EXPORT USERS TO CSV FIRST, THE DUPLICATE USERNAMES ARE MAKING THIS FAIL. (This is now done since I've added the export to csv at the end of the last script)


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


