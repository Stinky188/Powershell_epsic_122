<#
SYNOPSIS
Ce script identifie les comptes Active Directory expirés et non désactivés, puis les déplace dans une unité d’organisation (OU) dédiée nommée "Retired".

DESCRIPTION
Le script importe un fichier CSV pour récupérer les informations de domaine nécessaires à la construction du chemin LDAP. 
Il vérifie l’existence de l’OU "Retired" dans l’Active Directory et la crée si elle n’existe pas. 
Ensuite, il récupère tous les comptes expirés non désactivés et les déplace dans cette OU, facilitant ainsi la gestion et le suivi des comptes obsolètes.

AUTRICE
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le CSV utilise le point-virgule (';') comme séparateur.
- Le script écrase le fichier CSV original, il est donc recommandé de faire une sauvegarde.
- Ce script requiert que le script "insert_OUs.ps1" ait été exécuté au préalable.
- Ce script ne vérifie pas si les utilisateurs ont déjà été déplacés.

EXEMPLE D'UTILISATION
5_move_expired_users/move_expired_users.ps1 -csvFilePath "happy_koalas_employees.csv"
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)

# Valider que le fichier fourni est bien un CSV pour éviter les erreurs lors de l’import.
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
else {
    # Prévenir l’utilisateur en cas de format incorrect pour éviter un traitement inutile.
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
    exit
}

# Charger le module Active Directory pour utiliser les cmdlets associées.
Import-Module ActiveDirectory -ErrorAction Stop

# Importer les informations de domaine depuis le CSV, nécessaires à la construction des chemins LDAP.
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Récupérer tous les comptes AD expirés (non désactivés) pour traitement.
$expiredUsers = Search-ADAccount -AccountExpired

# Extraire les composants de domaine depuis le CSV pour construire le chemin LDAP.
$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]

# Définir le nom et le chemin complet de l’OU cible pour les comptes expirés.
$OUname = "Retired"
$OUparent = "OU=OU,DC=$dn,DC=$tld"
$OUfullPath = "OU=$OUname,$OUparent"

# Vérifier si l’OU "Retired" existe déjà pour éviter une duplication.
if (Get-ADOrganizationalUnit -Filter "distinguishedName -eq '$OUfullPath'") {
    Write-Host "$OUname already exists."
}
else {
    # Créer l’OU "Retired" sous l’OU parent spécifié pour organiser les comptes expirés.
    New-ADOrganizationalUnit -Name $OUname -Path $OUparent -ProtectedFromAccidentalDeletion $False
    Write-Host "Created Retired OU"
}

# Parcourir chaque compte expiré pour le déplacer dans l’OU "Retired".
foreach ($user in $expiredUsers) {
    # Afficher le SamAccountName pour suivi dans la console.
    $user.SamAccountName
    # Déplacer l’objet utilisateur dans l’OU cible pour centraliser la gestion des comptes expirés.
    $user | Move-ADObject -TargetPath $OUfullPath
    Write-Output "$($user.SamAccountName) - Moved"
}
