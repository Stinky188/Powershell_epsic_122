<#
SYNOPSIS
Ce script permet de définir une date d'expiration sur les comptes Active Directory d'utilisateurs spécifiques, 
en fonction de leur département et de leur titre, à partir d'une liste d'utilisateurs importée depuis un fichier CSV.

DESCRIPTION
Le script importe un fichier CSV contenant les noms d'utilisateur, puis pour chaque utilisateur, il vérifie dans Active Directory 
si son département et son titre correspondent aux critères spécifiés. Si c'est le cas, il applique une date d'expiration au compte, 
fixée à un nombre de jours donné à partir de la date actuelle. Cette approche facilite la gestion ciblée des comptes temporaires ou sensibles.

AUTHOR
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le fichier CSV contient une colonne 'Username' correspondant au SamAccountName.
- Aucune gestion avancée des erreurs n'est encore implémentée pour les cas où le fichier CSV est mal formé ou inaccessible.
- Le script ne gère pas les fuseaux horaires pour la date d'expiration.
- Les critères de département et titre sont sensibles à la casse et doivent correspondre exactement.

EXAMPLES
# Exemple d'utilisation :
.\SetUserExpiry.ps1 -csvFilePath "C:\Users\Admin\users.csv" -DepartmentToCheck "Production" -TitleToCheck "Assembler" -DaysToAdd 30
# Cela définira une date d'expiration à 30 jours pour les utilisateurs du département 'Production' ayant le titre 'Assembler'.
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

# Confirmation visuelle du fichier CSV utilisé, utile pour le suivi et le débogage.
Write-Output "Utilisation du fichier CSV : $csvFilePath"

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
    else {
        # Informer que l'utilisateur ne correspond pas aux critères permet de suivre le traitement.
        Write-Host "Utilisateur $username ne correspond pas aux criteres Departement='$department' et Titre='$title'."
    }
}

# Parcourir chaque utilisateur importé pour appliquer la fonction avec les paramètres dynamiques.
foreach ($user in $userData) {
    Set-ADUserExpiryDate -username $user.Username -daysToAdd $DaysToAdd -department $DepartmentToCheck -title $TitleToCheck
}
