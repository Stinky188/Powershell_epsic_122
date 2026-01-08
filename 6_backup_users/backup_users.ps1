[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)

# Validation du fichier CSV pour éviter les erreurs d'import
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
else {
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
    exit
}

# Le module Active Directory est nécessaire pour interagir avec AD
Import-Module ActiveDirectory -ErrorAction Stop

# Propriétés à récupérer pour le rapport AD
$properties = @(
    'givenName',
    'surname',
    'sAMAccountName',
    'emailAddress',
    'title',
    'department'
)

# Import des données utilisateurs depuis le CSV
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Extraction des informations de domaine depuis le CSV pour construire le chemin LDAP
$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]

# Construction dynamique de la liste des OU à partir des départements uniques dans le CSV
$uniqueDepartments = $userData | Select-Object -ExpandProperty Department -Unique

$OUs = foreach ($dept in $uniqueDepartments) {
    # Construire le chemin LDAP complet pour chaque département
    "OU=$dept,OU=OU,DC=$dn,DC=$tld"
}

# Récupération des utilisateurs AD dans chacun des OUs dynamiques
$ADReport = foreach ($OU in $OUs) {
    Get-ADUser -Filter * -Properties $properties -SearchBase $OU
}

# Répertoire de sauvegarde des exports
$path = "C:\backups\"
If (-not(test-path -PathType container $path)) {
    New-Item -ItemType Directory -Path $path
}

# Nom du fichier CSV et ZIP avec date
$csvOutputName = "$((Get-Date).ToString("yyyy-MM-dd"))_users"
$csvExtension = ".csv"
$zipExtension = ".zip"
$csvOutputPath = Join-Path $path "$csvOutputName$csvExtension"

# Export des données AD récupérées vers CSV avec renommage des colonnes pour clarté
$ADReport |
Select-Object -Property @{
    Name = 'FirstName'; Expression = { $_.givenName }
}, @{
    Name = 'LastName'; Expression = { $_.surname }
}, @{
    Name = 'Username'; Expression = { $_.sAMAccountName }
}, @{
    Name = 'Email'; Expression = { $_.emailAddress }
}, @{
    Name = 'Department'; Expression = { $_.department }
}, @{
    Name = 'JobTitle'; Expression = { $_.title }
} |
Export-CSV -Path $csvOutputPath -Delimiter ';' -NoTypeInformation

# Réimporter le CSV pour ajouter les propriétés dn et tld à chaque ligne
$reimport = Import-Csv -Path $csvOutputPath -Delimiter ';'

foreach ($row in $reimport) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $dn -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $tld -Force 
}

# Export final avec les nouvelles propriétés ajoutées
$reimport | Export-CSV -Path $csvOutputPath -Delimiter ';' -NoTypeInformation

# Création de l’archive ZIP contenant le CSV exporté
Compress-Archive -Path $csvOutputPath -DestinationPath (Join-Path $path $csvOutputName) -Force

# Suppression du fichier CSV temporaire après compression
Remove-Item $csvOutputPath -Recurse -Force

Write-Host "Sauvegarde compressee effectuee avec succes !" -ForegroundColor Green
Write-Host "Chemin = $path$csvOutputName$zipExtension"
