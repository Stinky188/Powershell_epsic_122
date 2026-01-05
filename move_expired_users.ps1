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

#Get expired AD accounts that are not disabled

$expiredUsers = Search-ADAccount -AccountExpired

$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]

$OUname = "Retired"
$OUparent = "OU=OU,DC=$dn,DC=$tld"
$OUfullPath = "OU=$OUname,$OUparent"

if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUfullPath'") {
  Write-Host "$OUname already exists."
} else {
  New-ADOrganizationalUnit -Name $OUname -Path $OUparent
  Write-Host "Created Retired OU"
}

foreach ($user in $expiredUsers) {
    $user.SamAccountName
    $user | Move-ADObject -TargetPath "OU=Retired,OU=OU,DC=$dn,DC=$tld"
    Write-Output "$($user.Username) - Moved"
} 