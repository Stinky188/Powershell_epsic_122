<#
SYNOPSIS
Ce script permet de définir une date d'expiration sur les comptes Active Directory d'utilisateurs spécifiques, 
en fonction de leur département et de leur titre, à partir d'une liste d'utilisateurs importée depuis un fichier CSV.

DESCRIPTION
Le script importe un fichier CSV contenant les noms d'utilisateur, puis pour chaque utilisateur, il vérifie dans Active Directory 
si son département et son titre correspondent aux critères spécifiés. Si c'est le cas, il applique une date d'expiration au compte, 
fixée à un nombre de jours donné à partir de la date actuelle. Cette approche facilite la gestion ciblée des comptes temporaires ou sensibles.

AUTRICE
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le CSV utilise le point-virgule (';') comme séparateur.
- Le script écrase le fichier CSV original, il est donc recommandé de faire une sauvegarde.

EXEMPLE D'UTILISATION
4_update_expiration_date/update_expiration_date.ps1 -csvFilePath "happy_koalas_employees.csv" -DepartmentToCheck "Production" -TitleToCheck "Assembler" 
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput,

    [Parameter(Mandatory = $true)]
    [string]$DepartmentToCheck,

    [Parameter(Mandatory = $true)]
    [string]$TitleToCheck,

    [Parameter(Mandatory = $true)]
    [int]$DaysToAdd
)

# Vérifie si le fichier source existe
if (-not (Test-Path $csvFilePath)) {
    Write-Host "Le fichier source '$Source' est introuvable." -ForegroundColor Red
    exit 1
}

# Valider le format du fichier en amont évite des erreurs inutiles lors de l'import des données.
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
else {
    # Informer l'utilisateur d'un chemin incorrect évite d'exécuter un traitement sur un fichier invalide.
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
    exit
}

# Le module ActiveDirectory est indispensable pour manipuler les comptes AD, 
# son chargement préalable est nécessaire pour utiliser les cmdlets associées.
Import-Module ActiveDirectory -ErrorAction Stop

# Importer les utilisateurs depuis le CSV avec le séparateur ';' correspond au format attendu.
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Fonction dédiée pour appliquer la date d'expiration uniquement aux utilisateurs répondant aux critères.
function Set-ADUserExpiryDate {
    param (
        [string]$username,
        [int]$daysToAdd,
        [string]$department,
        [string]$title
    )

    # Récupérer l'utilisateur AD avec les propriétés nécessaires permet de vérifier précisément ses attributs.
    $user = Get-ADUser -Identity $username -Properties Department, Title -ErrorAction SilentlyContinue

    # Si l'utilisateur n'existe pas, on évite de continuer pour limiter les erreurs.
    if ($null -eq $user) {
        Write-Warning "Utilisateur $username introuvable dans AD."
        return
    }

    # La condition cible uniquement les comptes qui correspondent aux critères pour appliquer la politique d'expiration.
    if ($user.Department -eq $department -and $user.Title -eq $title) {
        # Calculer la date d'expiration en ajoutant le nombre de jours spécifié à la date actuelle.
        $expiryDate = (Get-Date).AddDays($daysToAdd)
        # Appliquer la date d'expiration sur le compte AD, ce qui automatise la désactivation future.
        Set-ADAccountExpiration -Identity $username -DateTime $expiryDate
        Write-Host "Date d'expiration definie pour $username : $expiryDate"
    }
}

# Parcourir chaque utilisateur importé pour appliquer la fonction avec les paramètres dynamiques.
foreach ($user in $userData) {
    Set-ADUserExpiryDate -username $user.Username -daysToAdd $DaysToAdd -department $DepartmentToCheck -title $TitleToCheck
}
