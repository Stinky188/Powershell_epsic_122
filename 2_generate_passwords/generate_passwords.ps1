<#
SYNOPSIS
Ce script génère des mots de passe aléatoires pour les utilisateurs listés dans un fichier CSV et ajoute ces mots de passe en tant que nouvelle colonne.

DESCRIPTION
Le script lit les données utilisateurs depuis un fichier CSV, génère un mot de passe sécurisé et aléatoire pour chaque utilisateur 
en utilisant une fonction personnalisable, puis exporte les données mises à jour dans le CSV. Il garantit que les mots de passe 
générés contiennent des ensembles de caractères obligatoires (majuscules, minuscules, chiffres, symboles) pour une meilleure sécurité.

AUTEUR
Alice Dale - alice.dale@eduvaud.ch

LIMITATIONS
- Le script suppose que le CSV utilise le point-virgule (';') comme séparateur.
- La longueur des mots de passe et les ensembles de caractères sont actuellement fixes mais pourraient être paramétrés.
- Le script écrase le fichier CSV original, il est donc recommandé de faire une sauvegarde.
- Aucune gestion d’erreur n’est implémentée pour l’accès au fichier ou les problèmes de format CSV.

EXEMPLES
# Générer des mots de passe pour les utilisateurs dans users.csv avec les paramètres par défaut
.\GeneratePasswords.ps1 -csvFilePath "C:\path\to\users.csv"

# La description de l’utilisation et les entrées/sorties attendues sont dans le fichier README.
#>

[CmdletBinding()]
param(
    [ValidateNotNullOrEmpty()]    
    [string]$csvFilePath = $csvinput
)

# Vérifie que le fichier d’entrée a une extension .csv pour éviter de traiter des formats non supportés.
if ([IO.Path]::GetExtension($csvFilePath) -match ".csv") {
    Write-Output "Le chemin pour le fichier .csv est valable"
}
else {
    # Avertit l’utilisateur rapidement pour éviter des erreurs plus tard liées à un type de fichier invalide.
    Write-Warning "Chemin invalide. Le nom du fichier doit se terminer en .csv"
}

# Importe les données utilisateurs depuis le fichier CSV en utilisant le délimiteur spécifié pour bien parser les champs.
$userData = Import-Csv -Path $csvFilePath -Delimiter ';'

# Cette fonction génère une chaîne de caractères aléatoire de la taille donnée.
# Elle garantit l’inclusion obligatoire de majuscules, minuscules, chiffres et symboles par conception.
Function Create-String([Int]$Size = 8, [Char[]]$CharSets = "ULNS", [Char[]]$Exclude) {
    $Chars = @()
    $TokenSet = @()

    # Met en cache les ensembles de caractères globalement pour éviter de les reconstruire à chaque appel, améliorant ainsi les performances.
    If (!$TokenSets) {
        $Global:TokenSets = @{
            U = [Char[]]'ABCDEFGHIJKLMNOPQRSTUVWXYZ'                                # Majuscules
            L = [Char[]]'abcdefghijklmnopqrstuvwxyz'                                # Minuscules
            N = [Char[]]'0123456789'                                                # Chiffres
            S = [Char[]]'!"#$%&''()*+,-./:;<=>?@[\]^_`{|}~'                         # Symboles
        }
    }

    # Construit la pool de caractères autorisés en excluant les caractères spécifiés pour conformité ou lisibilité.
    $CharSets | ForEach {
        $Tokens = $TokenSets."$_" | ForEach { If ($Exclude -cNotContains $_) { $_ } }
        If ($Tokens) {
            $TokensSet += $Tokens
            # Assure qu’au moins un caractère de chaque ensemble obligatoire est inclus en ajoutant un caractère garanti.
            If ($_ -cle [Char]"Z") { $Chars += $Tokens | Get-Random }
        }
    }

    # Remplit la longueur restante du mot de passe avec des caractères aléatoires issus de la pool combinée.
    While ($Chars.Count -lt $Size) { $Chars += $TokensSet | Get-Random }

    # Mélange les caractères obligatoires avec les autres pour éviter des motifs prévisibles.
    ($Chars | Sort-Object { Get-Random }) -Join ""
}

# Crée un alias pour faciliter l’appel de la fonction de génération de mot de passe.
Set-Alias Create-Password Create-String -Description "Generer une chaine aleatoire (mot de passe)"

# Pour chaque utilisateur dans le CSV, génère un nouveau mot de passe et l’ajoute comme propriété à l’objet utilisateur.
foreach ($row in $userData) { 
    $newPwd = Create-Password 8 ULNS
    # Ajoute le mot de passe généré comme nouvelle propriété nommée 'Password' pour l’export ultérieur.
    $row | Add-Member -MemberType "NoteProperty" -Name Password -Value $newPwd -Force 
}

# Exporte les données utilisateurs mises à jour dans le fichier CSV, en supprimant les guillemets pour simplifier la lisibilité.
$userData | Export-CSV -Path $csvFilePath -Delimiter ';' -NoTypeInformation
