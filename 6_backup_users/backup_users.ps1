<#
SYNOPSIS
Ce script permet de faire une sauvegarde de l'état de l'AD.

DESCRIPTION
Le script permet d’exporter les informations des utilisateurs AD listés dans un fichier CSV. 
Il crée un fichier CSV contenant les données, puis compresse ce fichier dans une archive ZIP sous C:\backups\.

AUTRICE
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le CSV spécifié dans les paramètres utilise le point-virgule (';') comme séparateur.
- Ce script requiert que le script "insert_OUs.ps1" ait été exécuté au préalable.

EXEMPLE D'UTILISATION
6_backup_users/backup_users.ps1 -csvFilePath "happy_koalas_employees.csv"
# Référez-vous au README backup_users.md pour des informations sur l'automatisation de ce script.

VERSION DU SCRIPT
1.0
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)

# Vérifie si le fichier source existe
if (-not (Test-Path $csvFilePath)) {
    Write-Host "Le fichier source '$csvFilePath' est introuvable." -ForegroundColor Red
    exit 1
}

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

# Propriétés à récupérer pour le csv d'export de l'AD
$properties = @(
    'givenName',
    'surname',
    'sAMAccountName',
    'emailAddress',
    'title',
    'department'
)

# Importation du CSV pour avoir les informations sur le nom de l'AD et les départements dans lesquels extraire des informations
try {
    $userData = Import-Csv -Path $csvFilePath -Delimiter ';'
}
catch {
    Write-Error "Erreur lors de l'import du fichier CSV, il est peut-être read-only ou corrompu : $($_.Exception.Message)"
    exit 1
}

# Extraction des informations de domaine depuis le CSV pour construire le chemin LDAP
$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]

# Construction dynamique de la liste des OU à partir des départements uniques dans le CSV
$uniqueDepartments = $userData | Select-Object -ExpandProperty Department -Unique

$OUs = foreach ($dept in $uniqueDepartments) {
    # Construire le chemin LDAP complet pour chaque département
    "OU=$dept,OU=OU,DC=$dn,DC=$tld"
}

# Récupération des utilisateurs AD dans chacun des OUs
try {
    $ADReport = foreach ($OU in $OUs) {
        Get-ADUser -Filter * -Properties $properties -SearchBase $OU
    }
}
catch {
    Write-Error "Erreur lors de la récuperation des utilisateurs AD : $($_.Exception.Message)"
    exit 1
}

# Répertoire de sauvegarde des exports, si ce dossier n'existe pas, on le crée
$path = "C:\backups\"
try {
    If (-not(test-path -PathType container $path)) {
    New-Item -ItemType Directory -Path $path
    }
}
catch {
    Write-Error "Erreur lors de la création du dossier de sauvegarde '$path' : $($_.Exception.Message)"
    exit 1
}

# Nom du fichier CSV et ZIP avec date. Ces variables seront utilisées pour savoir où exporter le csv et en informer l'utilisateur
$csvOutputName = "$((Get-Date).ToString("yyyy-MM-dd"))_users"
$csvExtension = ".csv"
$zipExtension = ".zip"
$csvOutputPath = Join-Path $path "$csvOutputName$csvExtension"

# Export des données AD récupérées vers CSV avec renommage des colonnes pour qu'elles correspondent au csv original
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
Export-CSV -Path $csvOutputPath -Delimiter ';' -Encoding utf8 -NoTypeInformation

# Réimporter le CSV pour ajouter les propriétés dn et tld à chaque ligne
$reimport = Import-Csv -Path $csvOutputPath -Delimiter ';'

foreach ($row in $reimport) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $dn -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $tld -Force 
}

# Export final avec les nouvelles propriétés ajoutées
$reimport | Export-CSV -Path $csvOutputPath -Delimiter ';' -Encoding utf8 -NoTypeInformation

# Création de l’archive ZIP contenant le CSV exporté
try {
    Compress-Archive -Path $csvOutputPath -DestinationPath (Join-Path $path $csvOutputName) -Force
}
catch {
    Write-Error "Erreur lors de la compression du fichier CSV : $($_.Exception.Message)"
    exit 1
}

# Suppression du fichier CSV temporaire après compression
try {
    Remove-Item $csvOutputPath -Recurse -Force
}
catch {
    Write-Warning "Erreur lors de la suppression du fichier CSV temporaire : $($_.Exception.Message)"
}


Write-Host "Sauvegarde compressée effectuée avec succès !" -ForegroundColor Green
Write-Host "Chemin = $path$csvOutputName$zipExtension"
