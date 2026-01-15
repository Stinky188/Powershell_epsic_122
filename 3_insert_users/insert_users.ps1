<#
SYNOPSIS
Ce script automatise la création d’utilisateurs dans Active Directory à partir d’un fichier CSV, en garantissant l’unicité des noms d’utilisateur et en structurant les comptes dans des unités d’organisation (OU) selon les départements.

DESCRIPTION
Le script importe les données utilisateurs depuis un CSV, adapte les noms d’utilisateur pour éviter les doublons dans AD, crée les comptes avec les propriétés essentielles, puis exporte la liste mise à jour des utilisateurs dans le même fichier CSV. La structure LDAP est construite dynamiquement pour s’adapter à l’environnement cible.

AUTRICE
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le CSV utilise le point-virgule (';') comme séparateur.
- Le script écrase le fichier CSV original, il est donc recommandé de faire une sauvegarde.
- Ce script requiert que le script "insert_OUs.ps1" ait été exécuté au préalable.
- Ce script ne doit pas être exécuté plus d'une fois, car les utilisateurs seront créés à double avec un chiffre pour les distinguer.
- Les noms affichés dans l'AD correspondent au nom d'utilisateur (première lettre du prénom + nom de famille).

EXEMPLE D'UTILISATION
3_insert_users/insert_users.ps1 -csvFilePath "happy_koalas_employees.csv"
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)

# Vérifie si le fichier source existe
if (-not (Test-Path $csvFilePath)) {
    Write-Host "Le fichier source '$Source' est introuvable." -ForegroundColor Red
    exit 1
}

# La validation du fichier CSV en amont permet d’éviter des erreurs lors de l’import des données.
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable, importation des donnees."
}
else {
    # Cette alerte prévient l’utilisateur d’un format incorrect, ce qui évite de lancer un traitement inutile.
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
}

# Le module Active Directory est indispensable pour manipuler les objets AD. Son chargement est obligatoire avant toute commande AD.
Import-Module ActiveDirectory -ErrorAction Stop

# L’import des données CSV avec le délimiteur ';' correspond au format attendu par l’organisation.
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

foreach ($User in $userData) {
    # Les propriétés utilisateur sont extraites explicitement pour garantir leur disponibilité et faciliter la lecture du code.
    $GivenName = [string]$User.FirstName
    $Surname = [string]$User.LastName
    $Username = [string]$User.UserName
    $emailDomain = [string]$User.emailDomain
    $Title = [string]$User.JobTitle
    $Department = [string]$User.Department
    $InitialPassword = [string]$User.Password
    $dn = [string]$User.dn
    $tld = [string]$User.tld

    Write-Output $Username

    # L’unicité du SamAccountName est cruciale pour éviter les conflits dans AD. Ce mécanisme garantit un nom unique en ajoutant un suffixe numérique.
    $count = 2
    while (Get-ADUser -Filter "SamAccountName -eq '$Username'") {
        $Username = '{0}{1}' -f $User.UserName, $count++
    }

    # Regrouper les propriétés dans un hashtable améliore la lisibilité et facilite la maintenance ou l’extension des paramètres utilisateur.
    $newUserInfo = @{
        SamAccountName        = $Username
        Name                  = $Username
        GivenName             = $GivenName
        Surname               = $Surname
        DisplayName           = "$Surname $GivenName"
        UserPrincipalName     = "$Username@$emailDomain"
        EmailAddress          = "$Username@$emailDomain"
        Enabled               = $True
        ChangePasswordAtLogon = $true
        Path                  = "OU=$Department,OU=OU,DC=$dn,DC=$tld"  # Construire dynamiquement le chemin LDAP permet d’adapter la création aux structures existantes.
        Company               = "$dn.$tld"
        AccountPassword       = (ConvertTo-SecureString $InitialPassword -AsPlainText -Force)
        Title                 = $Title
        Department            = $Department
        Description           = $Title
    }

    # La création de l’utilisateur AD est lancée avec le paramètre -Verbose pour faciliter le suivi en cas de problème.
    New-ADUser @newUserInfo -Verbose
}

# Liste des propriétés à récupérer pour l’export des utilisateurs, facilitant la sélection ciblée des informations.
$properties = @(
  'givenName',
  'surname',
  'sAMAccountName',
  'emailAddress',
  'title',
  'department'
)

# Extraire les informations de domaine à partir du CSV garantit la cohérence entre création et export.
$dn = [string]$userData.dn[0]
$tld = [string]$userData.tld[0]

# La requête Get-ADUser est filtrée sur l’OU spécifique pour limiter la portée et améliorer la performance.
# La sélection des propriétés est adaptée au besoin d’export et à la lisibilité du CSV final.
Get-ADUser -filter * -properties $properties -SearchBase "OU=OU,DC=$dn,DC=$tld" |
    Select-Object -Property @{
        Name = 'FirstName'; Expression = {$_.givenName}
    }, @{
        Name = 'LastName'; Expression = {$_.surname}
    }, @{
        Name = 'Username'; Expression = {$_.sAMAccountName}
    }, @{
        Name = 'Email'; Expression = {$_.emailAddress}
    }, @{
        Name = 'Department'; Expression = {$_.department}
    }, @{
        Name = 'JobTitle'; Expression = {$_.title}
    } | Export-CSV -path $csvFilePath -Delimiter ';' -Encoding utf8 -NoTypeInformation

# Réimporter le CSV permet d’ajouter des propriétés supplémentaires sans perdre les données existantes.
$reimport = Import-Csv -Path $csvFilePath -Delimiter ';'

foreach ($row in $reimport) { 
    # Ajouter les propriétés dn et tld garantit que ces informations de contexte restent associées à chaque utilisateur.
    $row | Add-Member -MemberType "NoteProperty" -Name dn -Value $dn -Force 
    $row | Add-Member -MemberType "NoteProperty" -Name tld -Value $tld -Force 
}

# Export final du CSV, prêt à être utilisé dans d’autres processus ou pour archivage.
$reimport | Export-CSV -path $csvFilePath -Delimiter ';' -Encoding utf8 -NoTypeInformation
