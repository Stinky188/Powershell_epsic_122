<#
SYNOPSIS
Ce script importe des utilisateurs depuis un fichier CSV, ajoute les informations de domaine, 
puis prépare la structure des Unités d’Organisation (OU) dans Active Directory avant la création des comptes.

UTILITÉ
Automatiser la préparation des données et la création des OUs dans AD en fonction des départements utilisateurs, 
en assurant que la structure AD reflète bien l’organisation décrite dans le CSV.

AUTRICE
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le CSV utilise le point-virgule comme délimiteur.
- Le script écrase le fichier CSV original, il est donc recommandé de faire une sauvegarde.

EXEMPLE D'UTILISATION
1_insert_OUs/insert_OUs.ps1 -csvFilePath "happy_koalas_employees.csv"

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

# Vérifier que le fichier d’entrée est bien un CSV pour éviter de traiter un format incompatible.
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
else {
    # Stopper l’exécution si le fichier n’est pas un CSV, car la suite du script dépend de ce format.
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
    exit
}

# Le module Active Directory est indispensable pour manipuler les objets AD. Son chargement est obligatoire avant toute commande AD.
Import-Module ActiveDirectory -ErrorAction Stop
try {
    $adDomain = (Get-ADDomain).DNSRoot
    Write-Host "Domaine AD detecte : $adDomain"
}
catch {
    Write-Error "Impossible de recuperer le domaine AD : $($_.Exception.Message)"
    exit 1
}

$domainParts = $adDomain.Split('.')
$domainName = $domainParts[0]
$topLevelDomain = $domainParts[1]

# Importer les données utilisateurs en respectant le délimiteur ';' spécifique au format attendu.
try {
    $userData = Import-Csv -Path $csvFilePath -Delimiter ';'
}
catch {
    Write-Error "Erreur lors de l'import du fichier CSV, il est peut-etre read-only ou corrompu : $($_.Exception.Message)"
    exit 1
}

# Ajouter les informations de domaine et TLD à chaque utilisateur pour simplifier les traitements ultérieurs.
foreach ($row in $userData) { 
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $domainName -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $topLevelDomain -Force 
}

# Réécrire le CSV avec les nouvelles informations afin que les prochaines étapes disposent de toutes les données nécessaires.
# Cette étape écrase le fichier d’origine, il est conseillé d’avoir une sauvegarde stockée autre part.
$userData | Export-CSV -Path $csvFilePath -Delimiter ';' -Encoding utf8 -NoTypeInformation

# Charger le module ActiveDirectory pour utiliser les cmdlets AD.
# L’option -ErrorAction Stop permet de bloquer le script immédiatement en cas de problème, évitant des erreurs silencieuses.
Import-Module ActiveDirectory -ErrorAction Stop

# Recharger le csv pour s’assurer d’avoir la version la plus récente.
try {
    $userData = Import-Csv -Path $csvFilePath -Delimiter ';'
}
catch {
    Write-Error "Erreur lors de l'import du fichier CSV, il est peut-etre read-only ou corrompu : $($_.Exception.Message)"
    exit 1
}

foreach ($organisationalUnit in $userData) {
    $ou = [string]$organisationalUnit.Department
    $dn = [string]$organisationalUnit.dn
    $tld = [string]$organisationalUnit.tld
}

# Vérifier si une OU racine nommée "OU" existe déjà pour éviter les doublons.
if (Get-ADOrganizationalUnit -Filter "Name -eq 'OU'") {
    Write-Host "L'OU a la racine a deja ete cree."
}
else {
    # Créer l’OU racine sans protection contre suppression accidentelle pour permettre la suppression facile en cas de problèmes.
    New-ADOrganizationalUnit -Name "OU" -ProtectedFromAccidentalDeletion $False
    Write-Host "Creation de l'OU a la racine."
}

# Créer les OUs enfants correspondant aux départements, en évitant la création de doublons.
try {
    foreach ($ou in $userData.Department | Select-Object -Unique) {
        if (Get-ADOrganizationalUnit -Filter "Name -eq '$ou'") {
            Write-Host "L'OU $ou a deja ete cree."
        }
        else {
            New-ADOrganizationalUnit -Name $ou -Path "OU=OU,DC=$dn,DC=$tld" -ProtectedFromAccidentalDeletion $False
            Write-Host "Creation de l'OU $ou."
        }
    }
}   
catch {
    Write-Error "Erreur lors de la creation de l'OU racine, il y a peut-etre un probleme de droits sur l'AD : $($_.Exception.Message)"
    exit 1
}
